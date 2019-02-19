#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh
include os_detection.sh

create_root_path() {
    set_root_path /tmp
    mkdir -p $(release_file_dir)
}

clean_root_path() {
    safe_delete_directory_from_tmp $(release_file_dir)
    unset_root_path
}

create_ubuntu_lsb_release_file() {
    clean_root_path
    create_root_path

	cat <<- EOF > $(ubuntu_release_file)
	DISTRIB_ID=Ubuntu
	DISTRIB_RELEASE=12.10
	DISTRIB_CODENAME=quantal
	DISTRIB_DESCRIPTION="Ubuntu 12.10"
	EOF
}

create_gentoo_release_file() {
	cat <<- EOF > $(gentoo_release_file)
	Gentoo Base System release 2.2
	EOF
}

switch_distro_to_ubuntu() {
    clean_root_path
    create_root_path
    create_ubuntu_lsb_release_file
}

switch_distro_to_gentoo() {
    clean_root_path
    create_root_path
    create_gentoo_release_file
}

test_release_file_dir() {
    unset_root_path
    returns "/etc" "release_file_dir"
    set_root_path /tmp
    returns "/tmp/etc" "release_file_dir"
}

test_is_ubuntu() {
    switch_distro_to_ubuntu
    return_true "is_ubuntu"

    switch_distro_to_gentoo
    return_false "is_ubuntu"
}

test_ubuntu_version() {
    switch_distro_to_ubuntu
    returns '12.10' "ubuntu_version"

    switch_distro_to_gentoo
    returns_empty "ubuntu_version"
}

test_ubuntu_version_msb() {
    switch_distro_to_ubuntu
    returns 12 "ubuntu_version_msb 12.04"

}

test_ubuntu_version_lsb() {
    switch_distro_to_ubuntu
    returns 04 "ubuntu_version_lsb 12.04"

}

test_is_ubuntu_version_equal_to() {
    switch_distro_to_ubuntu
    return_true "is_ubuntu_version_equal_to 12.10"
    return_false "is_ubuntu_version_equal_to 9.04"
}

test_is_ubuntu_newer_then() {
    switch_distro_to_ubuntu
    return_true "is_ubuntu_newer_then 9.04 $UBUNTU_DISTRO_FILE"
    return_true "is_ubuntu_newer_then 12.04 $UBUNTU_DISTRO_FILE"
    return_false "is_ubuntu_newer_then 12.10 $UBUNTU_DISTRO_FILE"
}

test_is_ubuntu_newer_or_equal_to() {
    switch_distro_to_ubuntu
    return_true "is_ubuntu_newer_or_equal_to 9.04 $UBUNTU_DISTRO_FILE"
    return_true "is_ubuntu_newer_or_equal_to 12.04 $UBUNTU_DISTRO_FILE"
    return_true "is_ubuntu_newer_or_equal_to 12.10 $UBUNTU_DISTRO_FILE"
    return_false "is_ubuntu_newer_or_equal_to 13.10 $UBUNTU_DISTRO_FILE"
}

test_is_gentoo() {
    switch_distro_to_gentoo
    return_true "is_gentoo"

    switch_distro_to_ubuntu
    return_false "is_gentoo"
}

test_distro_name() {
    switch_distro_to_ubuntu
    returns ubuntu "distro_name"

    switch_distro_to_gentoo
    returns gentoo "distro_name"
}

test_ubuntu_distro_number() {
    returns 19.04 "ubuntu_distro_number disco"
    returns 18.04 "ubuntu_distro_number bionic"
    returns 16.04 "ubuntu_distro_number xenial"
    returns 15.04 "ubuntu_distro_number vivid"
    returns  4.10 "ubuntu_distro_number warty"
}

test_ubuntu_distro_name() {
    returns disco  "ubuntu_distro_name 19.04"
    returns bionic "ubuntu_distro_name 18.04"
    returns xenial "ubuntu_distro_name 16.04"
    returns vivid  "ubuntu_distro_name 15.04"
    returns warty  "ubuntu_distro_name  4.10"
}

# load shunit2
source /usr/share/shunit2/shunit2
