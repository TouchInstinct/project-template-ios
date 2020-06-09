#!/bin/sh

function generate {
  PARAMS=$1
  TEMPLATE_PATH=$2
  RESULT_PATH=$3

  echo $PARAMS > data.yml
  mustache data.yml $TEMPLATE_PATH > $RESULT_PATH
  rm data.yml
}

# define variables
PROJECTS_PATH=$1
PROJECT_NAME=$2
PROJECT_NAME_WITH_PREFIX=$2-ios
COMMON_REPO_NAME=${3:-$2-common}
DEPLOYMENT_TARGET="12.0"
CURRENT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
TEMPLATES=$CURRENT_DIR/templates

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
  git remote add origin git@github.com:TouchInstinct/$PROJECT_NAME_WITH_PREFIX.git
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

# create each empty folder in location from file, except Resources, all folders with files inside
for folder in `cat $CURRENT_DIR/foldernames.txt`; do
    echo "Creating $folder ..."
    mkdir -p $PROJECT_NAME/$folder
done

# install required gems & brews
cp $CURRENT_DIR/sources/Gemfile Gemfile
cp $CURRENT_DIR/sources/Gemfile.lock Gemfile.lock
cp $CURRENT_DIR/sources/Brewfile Brewfile
bundle install
brew bundle

# create info plist
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache $PROJECT_NAME/Info.plist

# generate services
DATE_SERVICE_NAME="DateFormattingService"
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/dateformatservice.mustache $PROJECT_NAME/Services/"$PROJECT_NAME$DATE_SERVICE_NAME".swift

NUMBER_SERVICE_NAME="NumberFormattingService"
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/numberformatservice.mustache $PROJECT_NAME/Services/"$PROJECT_NAME$NUMBER_SERVICE_NAME".swift

TABLE_CONTENT_CONTROLLER_NAME="TableContentController"
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/tablecontentcontroller.mustache $PROJECT_NAME/Controllers/"$PROJECT_NAME$TABLE_CONTENT_CONTROLLER_NAME".swift


# generate file for generate xcodeproj
LOWERCASED_PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
generate "{project_name: $PROJECT_NAME, deployment_target: $DEPLOYMENT_TARGET, project_name_lowecased: $LOWERCASED_PROJECT_NAME}" \
  $TEMPLATES/project.mustache \
  project.yml

# generate xcode project file
echo "Generate xcodeproj file..."
xcodegen --spec project.yml

# creating .gitkeep in each folder to enforce git stash this folder
for folder in `cat $CURRENT_DIR/foldernames.txt`; do
  touch $PROJECT_NAME/$folder/.gitkeep
done

# install pods
generate "{project_name: $PROJECT_NAME, deployment_target: $DEPLOYMENT_TARGET}" $TEMPLATES/Podfile.mustache Podfile
pod repo update
pod install

# configure git files
cp $TEMPLATES/gitignore .gitignore
cp $TEMPLATES/gitattributes .gitattributes

# configure rambafile
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Rambafile.mustache Rambafile
generamba template install

# configure README.md
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/README.mustache README.md

# configure submodules
git submodule add git@github.com:TouchInstinct/$COMMON_REPO_NAME.git common
git submodule add git@github.com:TouchInstinct/BuildScripts.git build-scripts

git submodule update --init

# final clean up
rm Gemfile*
rm Brewfile*
rm project.yml

# commit
git checkout -b feature/setup_project
git add .
git commit -m "Setup project configuration"

# open workspace
open -a Xcode $PROJECT_NAME.xcworkspace
