#!/bin/bash

script_dir=$(dirname $0)

. ${script_dir}/test_machine/config.sh
. ${script_dir}/test_machine/iso-functions.sh

get_iso
