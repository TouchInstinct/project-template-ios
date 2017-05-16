#!/bin/sh

read PROJECT_NAME

echo $PROJECT_NAME | liftoff

cd $PROJECT_NAME

git submodule add --name code-quality https://github.com/TouchInstinct/code-quality-ios code-quality

ln -s code-quality/.swiftlint.yml .swiftlint.yml
ln -s code-quality/.tailor.yml .tailor.yml
ln -s code-quality/cpd_script.php cpd_script.php
