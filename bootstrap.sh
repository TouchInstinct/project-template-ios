#!/bin/sh

# set -x # debug

function generate {
  PARAMS=$1
  TEMPLATE_PATH=$2
  RESULT_PATH=$3

  echo $PARAMS > data.yml
  mustache data.yml $TEMPLATE_PATH > $RESULT_PATH
  rm data.yml
}

# define variables
readonly PROJECTS_PATH=$1
readonly PROJECT_NAME=$2
readonly PROJECT_NAME_WITH_PREFIX=$2-ios
readonly COMMON_REPO_NAME=${3:-$2-common}
readonly DEPLOYMENT_TARGET="12.0"
readonly CURRENT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
readonly TEMPLATES=$CURRENT_DIR/templates
readonly MATCH_PASSWORD=`pwgen 8 1`
readonly GIT_URL="git@github.com:TouchInstinct/${PROJECT_NAME_WITH_PREFIX}.git"

cd $PROJECTS_PATH

# main project folder
echo "Clean up folders and files except .git folder..."
mkdir -p $PROJECT_NAME_WITH_PREFIX
cd $PROJECT_NAME_WITH_PREFIX

# remove project folder for sources and remove all files except .git folder
rm -rf $PROJECT_NAME
rm -rf $(ls)

# create git if not exists
if [ ! -d .git ]; then
  git init
  git remote add origin ${GIT_URL}
  git fetch
  git checkout -t origin/master
else
  echo "Git exists..."
fi

# source code project folder
echo "Create sources folders..."
mkdir -p $PROJECT_NAME

# copy and generate source files
cp -R $CURRENT_DIR/sources/project/. $PROJECT_NAME
cp -R $CURRENT_DIR/sources/fastlane/. fastlane

# create each empty folder in location from file, except Resources, Models and Appearance, all folders with files inside
for folder in `cat $CURRENT_DIR/foldernames.txt`; do
    echo "Creating $folder ..."
    mkdir -p $PROJECT_NAME/$folder
done

# install required gems & brews
cp $CURRENT_DIR/sources/Gemfile Gemfile
cp $CURRENT_DIR/sources/Gemfile.lock Gemfile.lock
cp $CURRENT_DIR/sources/Brewfile Brewfile

gem install bundler
bundle install

brew bundle

# create info plist
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache $PROJECT_NAME/Info.plist

# generate services
readonly DATE_SERVICE_NAME="DateFormattingService"
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/dateformatservice.mustache $PROJECT_NAME/Services/"$PROJECT_NAME$DATE_SERVICE_NAME".swift

readonly NUMBER_SERVICE_NAME="NumberFormattingService"
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/numberformatservice.mustache $PROJECT_NAME/Services/"$PROJECT_NAME$NUMBER_SERVICE_NAME".swift

readonly TABLE_CONTENT_CONTROLLER_NAME="TableContentController"
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/tablecontentcontroller.mustache $PROJECT_NAME/Controllers/"$PROJECT_NAME$TABLE_CONTENT_CONTROLLER_NAME".swift


# generate file for generate xcodeproj
readonly LOWERCASED_PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
generate "{project_name: $PROJECT_NAME, deployment_target: $DEPLOYMENT_TARGET, project_name_lowecased: $LOWERCASED_PROJECT_NAME}" \
  $TEMPLATES/project.mustache \
  project.yml

# generate xcode project file
echo "Generate xcodeproj file..."
xcodegen --spec project.yml

# conifgure build_phases folder
cp -r $CURRENT_DIR/sources/build_phases ./build_phases

generate "{project_name: $PROJECT_NAME}" $TEMPLATES/build_phases/code_lint_folders.mustache build_phases/code_lint_folders.xcfilelist

# creating .gitkeep in each folder to enforce git stash this folder
for folder in `cat $CURRENT_DIR/foldernames.txt`; do
  touch $PROJECT_NAME/$folder/.gitkeep
done

# install pods
generate "{project_name: $PROJECT_NAME, deployment_target: $DEPLOYMENT_TARGET}" $TEMPLATES/Podfile.mustache Podfile
bundle exec pod install --repo-update

# configure git files
cp $TEMPLATES/gitignore .gitignore
cp $TEMPLATES/gitattributes .gitattributes

# configure git hooks
cp -r $CURRENT_DIR/sources/.githooks .githooks

generate "{project_name: $PROJECT_NAME}" $TEMPLATES/githooks/post-merge.mustache .githooks/post-merge
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/githooks/pre-commit.mustache .githooks/pre-commit

chmod +x .githooks/post-merge
chmod +x .githooks/pre-commit

git config --local core.hooksPath .githooks

# configure fastlane

generate "{git_url: \"$GIT_URL\", match_password: $MATCH_PASSWORD}" $TEMPLATES/fastlane/Matchfile.mustache fastlane/Matchfile

generate "{project_name: $PROJECT_NAME, project_name_lowecased: $LOWERCASED_PROJECT_NAME}" $TEMPLATES/fastlane/configurations.yaml.mustache fastlane/configurations.yaml

# configure rambafile
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Rambafile.mustache Rambafile
bundle exec generamba template install

# configure README.md
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/README.mustache README.md

# configure submodules
git submodule add git@github.com:TouchInstinct/$COMMON_REPO_NAME.git common
git submodule add git@github.com:TouchInstinct/BuildScripts.git build-scripts

git submodule update --init

# final clean up
rm project.yml

# install additional brews
cp $CURRENT_DIR/additional/Brewfile Brewfile
brew bundle

#copy package for firebase
cp $CURRENT_DIR/sources/package.json package.json

#yarn
yarn install

# copy setup, install and update commands
cp $CURRENT_DIR/sources/setup.command setup.command
cp $CURRENT_DIR/sources/install_dependencies.command install_dependencies.command
cp $CURRENT_DIR/sources/update_dependencies.command update_dependencies.command

# commit
git checkout -b feature/setup_project
git add .
git commit -m "Setup project configuration"

# open workspace
open $PROJECT_NAME.xcworkspace
