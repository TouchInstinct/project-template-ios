#!/bin/sh

PROJECT_NAME=$1
PROJECTS_PATH=$2
COMMON_REPO_NAME=$3

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
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
cd $PROJECT_NAME

for folder in `cat $CURRENT_DIR/foldernames-test.txt`; do
    echo "Creating $folder ..."
    mkdir $folder
    touch $folder/.gitkeep
done

cd ..

# copy files
cp $RESOURCES/AppDelegate.swift $PROJECT_NAME/AppDelegate.swift
cp $RESOURCES/Info.plist $PROJECT_NAME/Info.plist
cp -R $RESOURCES/Assets.xcassets $PROJECT_NAME/Resources/Assets.xcassets

function generate {
  PARAMS=$1
  TEMPLATE_PATH=$2
  RESULT_PATH=$3

  echo $PARAMS > data.yml
  mustache data.yml $TEMPLATE_PATH > $RESULT_PATH
  rm data.yml
}

PROJECT_XCODEGEN_FILENAME="project.yml"
generate "{ name: $PROJECT_NAME }" $TEMPLATES/project.mustache $PROJECT_XCODEGEN_FILENAME

# generate xcode project file
echo "Generate xcodeproj file..."
xcodegen --spec $PROJECT_XCODEGEN_FILENAME


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
