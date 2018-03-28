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

CURRENT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
TEMPLATES=$CURRENT_DIR/templates
RESOURCES=$CURRENT_DIR/resources

cd $PROJECTS_PATH

# main project folder
# check for folder existence
mkdir $PROJECT_NAME
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
cp -R $RESOURCES/. $PROJECT_NAME


generate "{ name: $PROJECT_NAME }" $TEMPLATES/project.mustache project.yml
generate "{ name: $PROJECT_NAME }" $TEMPLATES/Info.mustache $PROJECT_NAME/Info.plist

# generate xcode project file
echo "Generate xcodeproj file..."
xcodegen # default to `project.yml`


# install pods
pod init
pod install

# configure submodules
# git submodule add --name common git@github.com:TouchInstinct/$COMMON_REPO_NAME.git
# git submodule add --name build-scripts git@github.com:TouchInstinct/BuildScripts.git
#
# git submodule update --init

# do some stuff with provision profiles

# enable shared scheme

# final clean up
#### rm $PROJECT_CONFIG_FILENAME
#### rm $PROJECT_XCODEGEN_FILENAME

# commit state
#### git commit -m "Setup project configuration"
