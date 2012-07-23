#!/bin/bash

# Script for configuring a fresh server to run the integration test and
# installing the scripts to do so.

. config.sh
. integration-functions.sh

if [[ ${EUID} -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

config_yum
install_packages
start_daemons
get_iso

configure_test_user
install_test_scripts $GET_SOURCE_SCRIPT
