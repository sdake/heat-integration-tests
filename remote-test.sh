#!/bin/bash

# Script to provision a remote machine and run a test on it

. config.sh
. test_machine/config.sh

. beaker-provision.sh
. remote-functions.sh

if [ -z "$MACHINE" ]; then
    echo "Specify the MACHINE to provision in setup.sh" >&2
    exit 1
fi

delete_host_key $MACHINE

provision_machine $MACHINE
wait_for_networking $MACHINE
wait_for_ssh $MACHINE

set_up
run_test

release_machine $MACHINE
