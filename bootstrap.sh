#!/bin/sh

PROJECT_NAME=$1
PROJECTS_PATH=$2
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd $PROJECTS_PATH

# main project folder
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# source code project folder
mkdir $PROJECT_NAME
cd $PROJECT_NAME

for folder in `cat $CURRENT_DIR/foldernames.txt`; do
    echo "Creating $folder ..."
    mkdir $folder
    touch $folder/.gitkeep
done

cd ..

# generate yml project file
cat <<EOF >project.yml
name: $PROJECT_NAME
options:
  bundleIdPrefix: ru.touchin.$PROJECT_NAME
targets:
  $PROJECT_NAME:
    type: application
    platform: iOS
    deploymentTarget: "10.0"
    sources: [$PROJECT_NAME]
EOF

# generate xcode project file
xcodegen --spec project.yml

# install pods

# expand scripts

# configure submodules

# do some stuff with provision profiles

# enable shared scheme



# echo $PROJECT_NAME | liftoff
#
# cd $PROJECT_NAME
#
# git submodule add --name code-quality git@github.com:TouchInstinct/code-quality-ios.git
#
# ln -s code-quality/.swiftlint.yml .swiftlint.yml
# ln -s code-quality/cpd_script.php cpd_script.php
#
# git add .swiftlint.yml
# git add cpd_script.php
#
# git commit --amend -m "Initial commit"
