if which swiftlint >/dev/null; then
    ${PODS_ROOT}/SwiftLint/swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi