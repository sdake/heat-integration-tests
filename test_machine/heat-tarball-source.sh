# Provides a get_source function for extracting source code from a tarball

get_source() {
    local dest_dir="$1"

    echo "Extracting heat-api from tarball..." >&2

    if [ -z "$dest_dir" ]; then
        echo "Error: Destination directory must be provided" >&2
        exit 1
    fi

    if [ -d $dest_dir ]; then sudo rm -rf $dest_dir; fi
    mkdir -p $dest_dir
    tar -xzf heat.tgz -C $dest_dir
}
