#!/bin/sh

PROJECT_NAME=$1
PROJECTS_PATH=$2
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd $PROJECTS_PATH

# clean up
rm -rf $PROJECT_NAME

# main project folder
mkdir $PROJECT_NAME
cd $PROJECT_NAME


# source code project folder
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
cp $CURRENT_DIR/templates/project.mustache project.mustache
  # create yml-definition project
cat <<EOF >$PROJECT_CONFIG_FILENAME
  { name: $PROJECT_NAME }
EOF
  # feed to template for yml file & generate yml code for xcodegen
mustache $PROJECT_CONFIG_FILENAME project.mustache > project.yml


# generate xcode project file
xcodegen --spec project.yml


# install pods

# expand scripts

# configure submodules

# do some stuff with provision profiles

# enable shared scheme

# final clean up


# echo $PROJECT_NAME | liftoff
#
# cd $PROJECT_NAME
#
# git submodule add --name  git@github.com:TouchInstinct/$PROJECT_NAME-common.git
# git submodule add --name code-quality git@github.com:TouchInstinct/code-quality-ios.git
# git submodule add --name code-quality git@github.com:TouchInstinct/code-quality-ios.git
#
# git commit --amend -m "Project Started"
