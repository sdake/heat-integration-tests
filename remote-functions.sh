# Functions for running tests on provisioned machines

wait_for_networking() {
    local server="$1"

    local retries=49
    while ! ping -q -c 1 $server && ((retries-- > 0)); do
        echo "Waiting for host networking..." >&2
        sleep 5
    done

    if [ ! $retries -ge 0 ]; then
        echo "Timed out." >&2
        false
    else
        true
    fi
}

wait_for_reboot() {
    local server="$1"

    local retries=49
    while ping -q -c 1 $server && ((retries-- > 0)); do
        echo "Waiting for host reboot..." >&2
        sleep 15
    done

    if [ ! $retries -ge 0 ]; then
        echo "Timed out." >&2
        false
    else
        true
    fi
}

wait_for_ssh() {
    local server="$1"

    local retries=49
    while ! ssh -o StrictHostKeyChecking=no ${SSH_KEY_FILE:+"-i"} $SSH_KEY_FILE ${SSH_USER:-root}@${MACHINE} uptime && ((retries-- > 0)); do
        echo "Waiting for host SSH service..." >&2
        sleep 5
    done

    if [ ! $retries -ge 0 ]; then
        echo "Timed out." >&2
        false
    else
        true
    fi
}

delete_host_key() {
    local machine="$1"

    if [ -e ~/.ssh/known_hosts ] && [ -n "$machine" ]; then
        echo "Deleting $machine from SSH known hosts file..." >&2
        sed -i -e "/^${machine}/ d" ~/.ssh/known_hosts
    fi
}

set_up() {
    echo "Copying scripts to test machine..." >&2

    local files="${script_dir}/test_machine/*.sh"
    if [ -n "${SOURCE_TARBALL}" ] && [ -e "$SOURCE_TARBALL" ]; then
        files="${files} ${SOURCE_TARBALL}"
    fi
    scp ${SSH_KEY_FILE:+"-i"} $SSH_KEY_FILE ${files} ${SSH_USER:-root}@${MACHINE}:

    if [ "${ALLOW_ISO_COPY:0:1}" = "y" ] && [ -e ${IMAGE_DIR}/${ISO_IMAGE} ]; then
        echo "Copying Fedora ISO to test machine..." >&2
        scp ${SSH_KEY_FILE:+"-i"} $SSH_KEY_FILE ${IMAGE_DIR}/${ISO_IMAGE} ${SSH_USER:-root}@${MACHINE}:${IMAGE_DIR}
    fi

    if [ $? = 0 ]; then
        echo "Configuring test machine..." >&2
        ssh -t -t ${SSH_KEY_FILE:+"-i"} $SSH_KEY_FILE ${SSH_USER:-root}@${MACHINE} ./integration-setup.sh
    else
        false
    fi
}

run_test() {
    echo "Running remote test..." >&2

    ssh -t -t ${SSH_KEY_FILE:+"-i"} $SSH_KEY_FILE ${SSH_USER:-root}@${MACHINE} sudo -u $TEST_USER /home/${TEST_USER}/heat-test.sh
}

make_tarball() {
    tar -cz * >${SOURCE_TARBALL:?}
}
