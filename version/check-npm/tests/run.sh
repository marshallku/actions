#!/bin/bash
# shellcheck disable=SC2317

set -e

# Setup
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$TEST_DIR/.." && pwd)"
PACKAGE_DIR="$TEST_DIR/package"
FAILED_TESTS=0

export GITHUB_OUTPUT="$TEST_DIR/github_output.txt"

# Utility functions
git_command() {
    git "$@" >/dev/null 2>&1
}

run_check() {
    bash "$SCRIPT_DIR/scripts/check-version.sh"
}

update_version() {
    local new_version="$1"
    jq ".version = \"$new_version\"" "$PACKAGE_DIR/package.json" >tmp.json && mv tmp.json "$PACKAGE_DIR/package.json"
    git_command add package.json
    git_command commit -m "Update version" || true
}

assert_version() {
    local expected
    local actual
    expected="$1"
    actual=$(tail -n 1 "$GITHUB_OUTPUT")
    if [ "$actual" == "$expected" ]; then
        echo "Test passed"
    else
        echo "Test failed"
        echo "Expected: $expected"
        echo "Actual: $actual"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Test lifecycle functions
before_each() {
    cd "$PACKAGE_DIR"
    update_version "1.0.0"
    current_version=$(jq -r .version package.json)
    if [ "$current_version" != "1.0.0" ]; then
        echo "Error: Version not set correctly in before_each"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    git_command init
    git_command add package.json
    git_command commit -m "Initial commit"
}

after_each() {
    rm -rf .git
    sed -i '$ d' "$GITHUB_OUTPUT"
}

after_all() {
    echo "Cleaning up after all tests..."
    cd "$PACKAGE_DIR"
    update_version "1.0.0"
    cd "$TEST_DIR"
    rm -rf "$PACKAGE_DIR/.git"
    rm -f "$GITHUB_OUTPUT"
}

# Test cases
test_no_version_change() {
    before_each
    echo "DUMMY" >dummy.txt
    git_command add dummy.txt
    git_command commit -m "Dummy commit"
    run_check
    assert_version "version="
    rm -f dummy.txt
    after_each
}

test_version_upgrade() {
    before_each
    update_version "1.0.1"
    run_check
    assert_version "version=1.0.1"
    after_each
}

test_version_downgrade() {
    before_each
    update_version "0.9.9"
    run_check
    assert_version "version=0.9.9"
    after_each
}

# Test runner
run_tests() {
    local test_functions
    test_functions=$(declare -F | awk '{print $3}' | grep '^test_')
    for test_function in $test_functions; do
        echo "Running $test_function"
        $test_function
    done
}

# Main execution
run_tests
after_all

if [ $FAILED_TESTS -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "$FAILED_TESTS test(s) failed."
    exit 1
fi
