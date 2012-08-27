#!/bin/bash

# Script for running the Heat integration test and reporting the result

HEAT_DIR=heat
TEST_RESULT=1

cd `dirname $0`

. get-source.sh

run_test() {
    echo "Install integration test environment..." 1>&2

    pushd $HEAT_DIR
    bash -c "$(./tools/rst2script.sed ./docs/GettingStarted.rst)"
    TEST_RESULT=$?
    popd
}

install_test_deps() {
    echo "Install test dependencies..." 1>&2

    pushd $HEAT_DIR
    yum -y install `sed '/^$/d;/^\#/d' ./tools/test-requires-rpm`
    popd
}

clean_up() {
    echo "Cleaning up..." 1>&2

    pushd $HEAT_DIR
    ./tools/uninstall-heat -y -r ''
    popd
}

get_source $HEAT_DIR
run_test
install_test_deps
#clean_up

if [ "${TEST_RESULT}" -ne 0 ]; then
    echo "FAILED :("
else
    echo "PASSED :)"
fi

exit $TEST_RESULT
