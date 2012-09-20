#!/bin/bash

# Script for running the Heat integration test and reporting the result

HEAT_DIR=heat
TEST_RESULT=1

cd `dirname $0`

. get-source.sh

run_getting_started() {
    echo "Install integration test environment..." 1>&2

    pushd $HEAT_DIR
    bash -c "$(./tools/rst2script.sed ./docs/GettingStarted.rst)"
    TEST_RESULT=$?
    popd
}

install_test_deps() {
    echo "Install test dependencies..." 1>&2

    pushd $HEAT_DIR
    sudo yum -q -y install `sed '/^$/d;/^\#/d' ./tools/test-requires-rpm`
    popd
}

configure_floating_ips() {
    local pub_if=lo

    sudo openstack-config --set /etc/nova/nova.conf DEFAULT public_interface $pub_if
    sudo systemctl restart openstack-nova-network.service

    sudo nova-manage floating create 10.0.1.125/28

    sudo iptables -t nat -I POSTROUTING -s 10.0.0.0/20 -j MASQUERADE -o $pub_if
}

run_tests() {
    pushd $HEAT_DIR
    source ~/.openstack/keystonerc
    ./run_tests.sh -a "tag=func,tag=F17"
    TEST_RESULT=$?
    if [ "${TEST_RESULT}" -ne 0 ]; then
        cat run_tests.err.log >&2
    fi
    popd
}

clean_up() {
    echo "Cleaning up..." 1>&2

    pushd $HEAT_DIR
    ./tools/uninstall-heat -y -r ''
    popd
}

get_source $HEAT_DIR
run_getting_started

if [ "${TEST_RESULT}" = 0 ]; then
    install_test_deps
    configure_floating_ips
    run_tests
fi

#clean_up

if [ "${TEST_RESULT}" -ne 0 ]; then
    echo "FAILED :("
else
    echo "PASSED :)"
fi

exit $TEST_RESULT
