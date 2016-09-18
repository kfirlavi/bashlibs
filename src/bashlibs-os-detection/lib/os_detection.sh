include code_clarity.sh

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

ubuntu_release_file() {
    echo $(release_file_dir)/lsb-release
}

gentoo_release_file() {
    echo $(release_file_dir)/gentoo-release
}

is_ubuntu() {
    [[ -f $(ubuntu_release_file) ]] \
        && grep -q Ubuntu $(ubuntu_release_file)
}

is_gentoo() {
    [[ -f $(gentoo_release_file) ]] \
        && grep -q Gentoo $(gentoo_release_file)
}

ubuntu_version() {
    is_ubuntu \
        && grep DISTRIB_RELEASE $(ubuntu_release_file) \
            | cut -d '=' -f 2
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
    is_ubuntu \
        && echo ubuntu
    is_gentoo \
        && echo gentoo
}
