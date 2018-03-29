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
COMMON_REPO_NAME=$3
DEPLOYMENT_TARGET="10.0"
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
else
  echo "Git exists..."
fi

# source code project folder
echo "Create sources folders..."
mkdir -p $PROJECT_NAME

# copy and generate source files
cp -R $CURRENT_DIR/sources/project/. $PROJECT_NAME
cp -R $CURRENT_DIR/sources/fastlane/. fastlane
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache $PROJECT_NAME/Info.plist

# generate file for generate xcodeproj
generate "{project_name: $PROJECT_NAME, deployment_target: $DEPLOYMENT_TARGET}" $TEMPLATES/project.mustache project.yml

# generate xcconfig files
mkdir -p Configs
LOWERCASED_PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
generate "{project_name: $PROJECT_NAME, identifier: "ru.touchin.$LOWERCASED_PROJECT_NAME"}" $TEMPLATES/configuration.mustache Configs/StandardDebug.xcconfig
generate "{project_name: $PROJECT_NAME, identifier: "ru.touchin.$LOWERCASED_PROJECT_NAME"}" $TEMPLATES/configuration.mustache Configs/StandardRelease.xcconfig

generate "{project_name: $PROJECT_NAME, identifier: "com.touchin.$LOWERCASED_PROJECT_NAME"}" $TEMPLATES/configuration.mustache Configs/EnterpriseDebug.xcconfig
generate "{project_name: $PROJECT_NAME, identifier: "com.touchin.$LOWERCASED_PROJECT_NAME"}" $TEMPLATES/configuration.mustache Configs/EnterpriseRelease.xcconfig

# generate xcode project file
echo "Generate xcodeproj file..."
xcodegen --spec project.yml

# creating .gitkeep in each folder to enforce git stash this folder
for folder in Analytics Cells Controllers Extensions Generated Models Networking Protocols Realm Resources/Localization Services Views; do
  touch $PROJECT_NAME/$folder/.gitkeep
done

# install pods
generate "{project_name: $PROJECT_NAME, deployment_target: $DEPLOYMENT_TARGET}" $TEMPLATES/Podfile.mustache Podfile
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
rm "project.yml"

# commit
git add .
git commit -m "Setup project configuration"
