#!/bin/bash

# Script to provision a remote machine and run a test on it

. config.sh
. test_machine/config.sh

. beaker-provision.sh
. remote-functions.sh

if [ -z "$MACHINE" ]; then
    echo "Specify the MACHINE to provision in setup.sh" >&2
    exit 2
fi

check_result() {
    local result=$1

    if [ $result -ne 0 ]; then
        release_machine $MACHINE
        exit 2
    fi
}

delete_host_key $MACHINE

provision_machine $MACHINE
check_result $?

wait_for_networking $MACHINE && wait_for_ssh $MACHINE
check_result $?

set_up
check_result $?

run_test
TEST_RESULT=$?

release_machine $MACHINE

exit $TEST_RESULT
