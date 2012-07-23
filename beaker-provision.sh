# Functions to provision a test machine using beaker

fedora_distro_id() {
    bkr distro-trees-list --name Fedora-${HOST_VERSION} --arch $ARCH | grep 'ID:' | cut -d: -f 2
}

provision_machine() {
    local machine="$1"

    echo "Attempting to provision machine $machine with Beaker" >&2

    local distro=`fedora_distro_id`
    echo "Distro Id: $distro"

    bkr system-reserve $machine
    bkr system-provision --distro `fedora_distro_id` $machine

    sleep 20
    wait_for_networking $machine
    sleep 10
    wait_for_reboot $machine
}

release_machine() {
    local machine="$1"

    echo "Releasing machine $machine with Beaker" >&2

    bkr system-release $machine
}
