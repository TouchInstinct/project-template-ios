#!/bin/sh

function generate {
  PARAMS=$1
  TEMPLATE_PATH=$2
  RESULT_PATH=$3

  echo $PARAMS > data.yml
  mustache data.yml $TEMPLATE_PATH > $RESULT_PATH
  rm data.yml
}

PROJECT_NAME=$1
PROJECTS_PATH=$2
COMMON_REPO_NAME=$3
DEPLOYMENT_TARGET="10.0"

CURRENT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
TEMPLATES=$CURRENT_DIR/templates

cd $PROJECTS_PATH

# main project folder
# check for folder existence
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

echo "Clean up folders and files..."
rm -rf $PROJECT_NAME
rm -rf $(ls)

# TEST, REMOVE THIS LINE
git init

# source code project folder
echo "Recreate sources folders..."
mkdir $PROJECT_NAME

# copy files
cp -R $CURRENT_DIR/sources/. $PROJECT_NAME

generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache $PROJECT_NAME/Info.plist
generate "{project_name: $PROJECT_NAME, deployment_target: $DEPLOYMENT_TARGET}" $TEMPLATES/project.mustache project.yml

# generate xcode project file
echo "Generate xcodeproj file..."
xcodegen # default to `project.yml`

# creating .gitkeep
for folder in Analytics Cells Controllers Extensions Generated Models Networking Protocols Realm Resources/Localization Services Views; do
  touch $PROJECT_NAME/$folder/.gitkeep
done

# install pods
generate "{project_name: $PROJECT_NAME, deployment_target: $DEPLOYMENT_TARGET}" $TEMPLATES/Podfile.mustache Podfile
pod install

cp $TEMPLATES/gitignore .gitignore
cp $TEMPLATES/gitattributes .gitattributes

# configure submodules
git submodule add git@github.com:TouchInstinct/$COMMON_REPO_NAME.git common
git submodule add git@github.com:TouchInstinct/BuildScripts.git build-scripts

git submodule update --init

# enable shared scheme

# final clean up
#### rm "project.yml"

# commit state
git commit -m "Setup project configuration"
