#! /bin/sh

set -euo pipefail

logInfo () {
    echo "\033[32m$1\033[0m" >&2
}

logWarning () {
    echo "\033[33m$1\033[0m" >&2
}

logError () {
    echo "\033[31m$1\033[0m" >&2
}

logInfo $TRAVIS_COMMIT_MESSAGE
logInfo "RFCI_TASK = $RFCI_TASK"
readonly RFSTAGE="$1"
logInfo "RFSTAGE = $RFSTAGE"

# Run test
# $1 scheme
# $2 destination
XC_Test() {
    xcodebuild test -enableCodeCoverage YES -workspace "$RFWorkspace" -scheme "$1" -destination "$2" ONLY_ACTIVE_ARCH=NO GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcpretty
}

# Run macOS test
XC_TestMac() {
    xcodebuild test -enableCodeCoverage YES -workspace "$RFWorkspace" -scheme "Test-macOS" GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcpretty
}

# Run watchOS build
XC_TestWatch() {
    xcodebuild build -workspace "$RFWorkspace" -scheme "Target-watchOS" ONLY_ACTIVE_ARCH=NO | xcpretty
}

STAGE_SETUP() {
    gem install cocoapods --no-document
}

STAGE_MAIN() {
    if [ "$RFCI_TASK" = "POD_LINT" ]; then
        if [[ "$TRAVIS_COMMIT_MESSAGE" = *"[skip lint]"* ]]; then
            logWarning "Skip pod lint"
        else
            logInfo "TRAVIS_BRANCH = $TRAVIS_BRANCH"

            # Modify podspec, add shadow.m
            # Replace 'MBAppKit/**/*' => 'Test/Shared/shadow.m',\1
            sed -i.bak "s/\[\('MBAppKit\/\*\*\/\*\)/\['Test\/Shared\/shadow.m',\1/" "MBAppKit.podspec"

            # Always allow warnings as third-party dependencies generate unavoidable warnings.
            pod lib lint --fail-fast --allow-warnings
        fi

    elif [ "$RFCI_TASK" = "Xcode9" ]; then
        pod install
        XC_Test "Test-iOS" "platform=iOS Simulator,name=iPhone X,OS=11.3"
        XC_Test "Test-iOS" "platform=iOS Simulator,name=iPhone 5,OS=9.0"
    else
        logError "Unexpected CI task: $RFCI_TASK"
    fi
}

STAGE_SUCCESS() {
    if [ "$RFCI_TASK" = "Xcode9" ]; then
        curl -s https://codecov.io/bash | bash -s
    fi
}

STAGE_FAILURE() {
    if [[ "$RFCI_TASK" == Xcode* ]]; then
        cat -n ~/Library/Logs/DiagnosticReports/xctest*.crash
    fi
}

"STAGE_$RFSTAGE"
