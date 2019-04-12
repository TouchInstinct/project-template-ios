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
PROJECT_TYPE=$1
PROJECTS_PATH=$2
PROJECT_NAME=$3

case $PROJECT_TYPE in
  project)
    PROJECT_NAME_WITH_PREFIX=$3-ios
    SCRIPT_MISC_FILES_DIR="project"
    ;;
  library)
    PROJECT_NAME_WITH_PREFIX=$3
    SCRIPT_MISC_FILES_DIR="library"
    ;;
  *)
    echo "Please specify project type: \"project\" or \"library\""
    exit 1
    ;;
esac

DEPLOYMENT_TARGET_IOS="9.0"
DEPLOYMENT_TARGET_WATCH_OS="2.0"
DEPLOYMENT_TARGET_TV_OS="9.0"
SWIFT_VERSION="5.0"
XCODE_VERSION="10.2"
CURRENT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
TEMPLATES=$CURRENT_DIR/$SCRIPT_MISC_FILES_DIR/templates
SOURCES=$CURRENT_DIR/$SCRIPT_MISC_FILES_DIR/sources
COMMON_SOURCES=$CURRENT_DIR/common/sources

FOLDERNAMES=$CURRENT_DIR/$SCRIPT_MISC_FILES_DIR/foldernames.txt

LOWERCASED_PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')

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

# copy and generate source files
case $PROJECT_TYPE in
  project)
    # source code project folder
    echo "Create sources folders..."
    mkdir -p $PROJECT_NAME

    cp -R $SOURCES/project/. $PROJECT_NAME
    cp -R $SOURCES/fastlane/. fastlane

    generate "{project_name_lowecased: $LOWERCASED_PROJECT_NAME}" $SOURCES/fastlane/configurations.mustache fastlane/configurations.yaml

    # create each empty folder in location from file, except Resources, all folders with files inside
    for folder in `cat $FOLDERNAMES`; do
        echo "Creating $folder ..."
        mkdir -p $PROJECT_NAME/$folder
    done
    ;;
  library)
    # create each empty folder in location from file, except Resources, all folders with files inside
    for folder in `cat $FOLDERNAMES`; do
        echo "Creating $folder ..."
        mkdir -p Sources/$folder
    done
  ;;
esac

# install required gems & brews
cp $SOURCES/Gemfile Gemfile
cp $SOURCES/Gemfile.lock Gemfile.lock
cp $COMMON_SOURCES/Brewfile Brewfile
bundle install
brew bundle

case $PROJECT_TYPE in
  project)
    # create info plist
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache $PROJECT_NAME/Info.plist

    # generate services
    DATE_SERVICE_NAME="DateFormattingService"
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/dateformatservice.mustache $PROJECT_NAME/Services/"$PROJECT_NAME$DATE_SERVICE_NAME".swift

    NUMBER_SERVICE_NAME="NumberFormattingService"
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/numberformatservice.mustache $PROJECT_NAME/Services/"$PROJECT_NAME$NUMBER_SERVICE_NAME".swift

    TABLE_CONTENT_CONTROLLER_NAME="TableContentController"
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/tablecontentcontroller.mustache $PROJECT_NAME/Controllers/"$PROJECT_NAME$TABLE_CONTENT_CONTROLLER_NAME".swift
  ;;
  library)
    # create info plists
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache Sources/Info-iOS.plist
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache Sources/Info-iOS-Extension.plist
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache Sources/Info-watchOS.plist
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Info.mustache Sources/Info-tvOS.plist

    # generate public header
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/PublicHeader.mustache Sources/$PROJECT_NAME.h

    # copy example class
    cp $TEMPLATES/ExampleClass.swift Sources/Classes/ExampleClass.swift

    # generate podspec
    generate "{
      project_name: $PROJECT_NAME,
      deployment_target_ios: $DEPLOYMENT_TARGET_IOS,
      deployment_target_watch_os: $DEPLOYMENT_TARGET_WATCH_OS,
      deployment_target_tv_os: $DEPLOYMENT_TARGET_TV_OS,
      swift_version: $SWIFT_VERSION,
      xcode_version: $XCODE_VERSION
    }" $TEMPLATES/podspec.mustache $PROJECT_NAME.podspec

    # copy licence
    cp $TEMPLATES/LICENSE LICENSE
  ;;
esac

# generate file for generate xcodeproj
generate "{
  project_name: $PROJECT_NAME,
  deployment_target_ios: $DEPLOYMENT_TARGET_IOS,
  deployment_target_watch_os: $DEPLOYMENT_TARGET_WATCH_OS,
  deployment_target_tv_os: $DEPLOYMENT_TARGET_TV_OS,
  swift_version: $SWIFT_VERSION,
  xcode_version: $XCODE_VERSION,
  project_name_lowecased: $LOWERCASED_PROJECT_NAME}" \
  $TEMPLATES/project.mustache \
  project.yml

# install carthage
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Cartfile.mustache Cartfile
carthage bootstrap

# generate xcode project file
echo "Generate xcodeproj file..."
xcodegen --spec project.yml

carting update -f list

# creating .gitkeep in each folder to enforce git stash this folder
case $PROJECT_TYPE in
  project)
    for folder in `cat $FOLDERNAMES`; do
      touch $PROJECT_NAME/$folder/.gitkeep
    done
    ;;
  library)
    for folder in `cat $FOLDERNAMES`; do
      touch Sources/$folder/.gitkeep
    done
  ;;
esac

# install pods
generate "{
  project_name: $PROJECT_NAME,
  deployment_target_ios: $DEPLOYMENT_TARGET_IOS,
  deployment_target_watch_os: $DEPLOYMENT_TARGET_WATCH_OS,
  deployment_target_tv_os: $DEPLOYMENT_TARGET_TV_OS
}" $TEMPLATES/Podfile.mustache Podfile
pod repo update
pod install

# configure git files
cp $TEMPLATES/gitignore .gitignore
cp $TEMPLATES/gitattributes .gitattributes

# configure README.md
generate "{project_name: $PROJECT_NAME}" $TEMPLATES/README.mustache README.md

# configure submodules
git submodule add git@github.com:TouchInstinct/BuildScripts.git build-scripts

case $PROJECT_TYPE in
  project)
    # configure rambafile
    generate "{project_name: $PROJECT_NAME}" $TEMPLATES/Rambafile.mustache Rambafile
    generamba template install
    COMMON_REPO_NAME=$PROJECT_NAME-common
    git submodule add git@github.com:TouchInstinct/$COMMON_REPO_NAME.git common
    ;;
esac

git submodule update --init

# final clean up
rm Gemfile*
rm Brewfile*
rm project.yml

# generate models, strings, etc
xcodebuild -workspace $PROJECT_NAME.xcworkspace -scheme $PROJECT_NAME -configuration StandardDebug -sdk iphonesimulator

# commit
git checkout -b feature/setup_project
git add .
git commit -m "Setup project configuration"

# open workspace
open -a Xcode $PROJECT_NAME.xcworkspace
