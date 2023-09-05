include code_clarity.sh
include ssh.sh

set_root_path() {
    local dir=$1

    _ROOT_PATH=$dir
}

unset_root_path() {
    _ROOT_PATH=
}

release_file_dir() {
    echo $_ROOT_PATH/etc
}

debian_release_file() {
    echo $(release_file_dir)/os-release
}

ubuntu_release_file() {
    echo $(release_file_dir)/os-release
}

gentoo_release_file() {
    echo $(release_file_dir)/gentoo-release
}

is_debian() {
    [[ -f $(debian_release_file) ]] \
        && grep -q 'ID=debian' $(debian_release_file)
}

is_ubuntu() {
    [[ -f $(ubuntu_release_file) ]] \
        && grep -q 'ID=ubuntu' $(ubuntu_release_file)
}

is_gentoo() {
    [[ -f $(gentoo_release_file) ]] \
        && grep -q Gentoo $(gentoo_release_file)
}

ubuntu_version() {
    is_ubuntu \
        && grep VERSION_ID $(ubuntu_release_file) \
            | cut -d '"' -f 2
}

ubuntu_version_msb() {
    local version=$1

    echo $version \
        | cut -d '.' -f 1
}

ubuntu_version_lsb() {
    local version=$1

    echo $version \
        | cut -d '.' -f 2
}

is_ubuntu_version_equal_to() {
    local version=$1

    [[ $version == $(ubuntu_version) ]]
}

is_ubuntu_newer_then() {
    local version=$1
    local os_ver=$(ubuntu_version)
    local os_ver_msb=$(ubuntu_version_msb $os_ver)
    local os_ver_lsb=$(ubuntu_version_lsb $os_ver)
    local version_msb=$(ubuntu_version_msb $version)
    local version_lsb=$(ubuntu_version_lsb $version)

    (( $version_msb > $os_ver_msb )) \
        && return 1

    (( $version_msb < $os_ver_msb )) \
        && return 0

    (( $version_lsb >= $os_ver_lsb )) \
        && return 1 \
        || return 0
}

is_ubuntu_newer_or_equal_to() {
    local version=$1

    is_ubuntu_newer_then $version \
        && return 0

    is_ubuntu_version_equal_to $version \
        && return 0

    return 1
}

distro_name() {
    is_debian \
        && echo debian
    is_ubuntu \
        && echo ubuntu
    is_gentoo \
        && echo gentoo
}

ubuntu_distro_number() {
    local distro_name=$1

    grep $distro_name $(libraries_path)/ubuntu_naming.sh \
        | awk '{print $2}'
}

ubuntu_distro_name() {
    local distro_number=$1

    grep " $distro_number" $(libraries_path)/ubuntu_naming.sh \
        | awk '{print $1}'
}

os_detection_remote() {
    local user=$1; shift
    local host=$1; shift
    local os_detection_command=$@
    local f=os_detection.sh

    rsync \
        __BASHLIBS_LIB_DIR__/$f \
        $user@$host:/tmp/

    run_on_host $user $host \
        "source /tmp/$f > /dev/null 2>&1; $os_detection_command" 
}
