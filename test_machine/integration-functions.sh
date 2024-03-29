# Functions for configuring a box to run the integration tests

HOME_DIR=/home/${TEST_USER}

config_yum() {
    # F16 requires OpenStack Preview repo
    if [ `yum info fedora-release | grep ^Version | cut -d: -f 2` = 16 ]; then
        REPO=fedora-openstack-preview.repo

        echo "Configuring yum OpenStack Preview repo..." 1>&2

        pushd /etc/yum.repos.d
        if [ ! -f $REPO ]; then
                wget http://repos.fedorapeople.org/repos/apevec/openstack-preview/$REPO
        fi
        popd
    fi
}

install_packages() {
    echo "Installing essential packages..." 1>&2

    yum -q -y install libvirt git

    # Oz requirements for installation from source
    yum -q -y install oz make rpm-build
    yum -q -y erase oz
}

start_daemons() {
    echo "Starting essential daemons..." 1>&2

    systemctl start libvirtd.service
    # this is a hack to force udev rules to be applied to /dev/kvm
    # https://bugzilla.redhat.com/show_bug.cgi?id=860658
    udevadm trigger
}

configure_test_user() {
    echo "Configuring $TEST_USER user..." 1>&2

    getent passwd $TEST_USER >/dev/null || useradd $TEST_USER -m -d $HOME_DIR -s /sbin/nologin
    if [ ! -f /etc/sudoers.d/${TEST_USER} ]; then
        echo -e "$TEST_USER ALL=(root) NOPASSWD: ALL" > /etc/sudoers.d/${TEST_USER}
        chmod 0440 /etc/sudoers.d/${TEST_USER}
    fi
    if [ ! -f ${HOME_DIR}/.ssh/id_rsa ]; then
        sudo -u $TEST_USER ssh-keygen -q -t rsa -N '' -f ${HOME_DIR}/.ssh/id_rsa
    fi
}

install_test_scripts() {
    local source_script="$1"

    echo "Installing test scripts..."
    install -o $TEST_USER -g $TEST_USER heat-test.sh ${HOME_DIR}/
    if [ -n "$source_script" ]; then
        install -o $TEST_USER -g $TEST_USER $source_script -m 644 ${HOME_DIR}/get-source.sh
    fi
    if [ -e $SOURCE_TARBALL ]; then
        install -o $TEST_USER -g $TEST_USER $SOURCE_TARBALL ${HOME_DIR}/
    fi
}
