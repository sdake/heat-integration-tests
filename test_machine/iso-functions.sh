
ISO_IMAGE=Fedora-${GUEST_VERSION}-${ARCH}-DVD.iso
IMAGE_DIR=/var/lib/libvirt/images


get_iso() {
    if [ ! -f ${IMAGE_DIR}/${ISO_IMAGE} ]; then
        echo "Downloading Fedora $GUEST_VERSION $ARCH ISO..." 1>&2

        pushd $IMAGE_DIR
        wget http://archive.fedoraproject.org/pub/fedora/linux/releases/${GUEST_VERSION}/Fedora/${ARCH}/iso/${ISO_IMAGE}
        popd
    fi
}
