# Project path
readonly PROJECT_PATH=${1}

xcodebuild \
	-quiet \
	-scheme CodeLint \
	-project ${PROJECT_PATH} \
	-destination 'generic/platform=macOS' \
	analyze

if test $? -eq 0
    then echo "Code linting was finished successfully!"
else
    echo "There is the error with code linting!"
    exit 1
fi