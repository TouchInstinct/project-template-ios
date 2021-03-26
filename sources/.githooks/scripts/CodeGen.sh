# Project path
readonly PROJECT_PATH=${1}

xcodebuild \
	-quiet \
	-scheme CodeGen \
	-project ${PROJECT_PATH} \
	-destination 'generic/platform=macOS' \
	archive

if test $? -eq 0
    then echo "Code generation was finished successfully!"
else
    echo "There is the error with code generation!"
    exit 1
fi