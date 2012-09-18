# Provides a get_source function for retrieving the latest version of Heat
# from GitHub

get_source() {
    local dest_dir="$1"

    echo "Cloning heat-api from GitHub..." 1>&2

    if [ -z "$dest_dir" ]; then
        echo "Error: Destination directory must be provided" 1>&2
        exit 1
    fi

    if [ -d $dest_dir ]; then sudo rm -rf $dest_dir; fi
    git clone -q git://github.com/heat-api/heat.git $dest_dir

    pushd $dest_dir
    echo "Cloned version $(git describe --always) from GitHub."
    popd
}
