#!/bin/sh

PROJECT_NAME=$1
PROJECTS_PATH=$2
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TEMPLATES=$CURRENT_DIR/templates

cd $PROJECTS_PATH

# main project folder
# check for folder existence
mkdir $PROJECT_NAME
cd $PROJECT_NAME

echo "Clean up folders and files..."
rm -rf $PROJECT_NAME
rm -rf $(ls)

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


# generate yml project file
PROJECT_CONFIG_FILENAME="project-config.yml"
PROJECT_XCODEGEN_FILENAME="project.yml"
# create yml-definition project
cat <<EOF >$PROJECT_CONFIG_FILENAME
  { name: $PROJECT_NAME }
EOF
# feed to template for yml file & generate yml code for xcodegen

mustache $PROJECT_CONFIG_FILENAME $TEMPLATES/project.mustache > $PROJECT_XCODEGEN_FILENAME


# generate xcode project file
xcodegen --spec $PROJECT_XCODEGEN_FILENAME


# install pods
pod init
pod install

# expand scripts

# configure submodules

# do some stuff with provision profiles

# enable shared scheme

# final clean up
rm $PROJECT_CONFIG_FILENAME
rm $PROJECT_XCODEGEN_FILENAME


# echo $PROJECT_NAME | liftoff
#
# cd $PROJECT_NAME
#
# git submodule add --name  git@github.com:TouchInstinct/$PROJECT_NAME-common.git
# git submodule add --name code-quality git@github.com:TouchInstinct/code-quality-ios.git
# git submodule add --name code-quality git@github.com:TouchInstinct/code-quality-ios.git
#
# git commit --amend -m "Project Started"
