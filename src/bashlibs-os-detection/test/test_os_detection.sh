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

create_debian_release_file() {
    clean_root_path
    create_root_path

	cat <<- EOF > $(ubuntu_release_file)
	PRETTY_NAME="Debian GNU/Linux trixie/sid"
	NAME="Debian GNU/Linux"
	VERSION_CODENAME=trixie
	ID=debian
	HOME_URL="https://www.debian.org/"
	SUPPORT_URL="https://www.debian.org/support"
	BUG_REPORT_URL="https://bugs.debian.org/"
	EOF
}

create_ubuntu_release_file() {
    clean_root_path
    create_root_path

	cat <<- EOF > $(ubuntu_release_file)
	NAME="Ubuntu"
	VERSION="20.04.6 LTS (Focal Fossa)"
	ID=ubuntu
	ID_LIKE=debian
	PRETTY_NAME="Ubuntu 20.04.6 LTS"
	VERSION_ID="20.04"
	HOME_URL="https://www.ubuntu.com/"
	SUPPORT_URL="https://help.ubuntu.com/"
	BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
	PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
	VERSION_CODENAME=focal
	UBUNTU_CODENAME=focal
	EOF
}

create_gentoo_release_file() {
	cat <<- EOF > $(gentoo_release_file)
	Gentoo Base System release 2.2
	EOF
}

switch_distro_to_debian() {
    clean_root_path
    create_root_path
    create_debian_release_file
}

switch_distro_to_ubuntu() {
    clean_root_path
    create_root_path
    create_ubuntu_release_file
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

test_is_debian() {
    switch_distro_to_debian
    return_true "is_debian"

    switch_distro_to_gentoo
    return_false "is_debian"
}

test_is_ubuntu() {
    switch_distro_to_ubuntu
    return_true "is_ubuntu"

    switch_distro_to_gentoo
    return_false "is_ubuntu"
}

test_ubuntu_version() {
    switch_distro_to_ubuntu
    returns '20.04' "ubuntu_version"

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
    return_true "is_ubuntu_version_equal_to 20.04"
    return_false "is_ubuntu_version_equal_to 9.04"
}

test_is_ubuntu_newer_then() {
    switch_distro_to_ubuntu
    return_true "is_ubuntu_newer_then 9.04 $UBUNTU_DISTRO_FILE"
    return_true "is_ubuntu_newer_then 12.04 $UBUNTU_DISTRO_FILE"
    return_false "is_ubuntu_newer_then 22.10 $UBUNTU_DISTRO_FILE"
}

test_is_ubuntu_newer_or_equal_to() {
    switch_distro_to_ubuntu
    return_true "is_ubuntu_newer_or_equal_to 9.04 $UBUNTU_DISTRO_FILE"
    return_true "is_ubuntu_newer_or_equal_to 12.04 $UBUNTU_DISTRO_FILE"
    return_true "is_ubuntu_newer_or_equal_to 12.10 $UBUNTU_DISTRO_FILE"
    return_false "is_ubuntu_newer_or_equal_to 23.10 $UBUNTU_DISTRO_FILE"
}

test_is_gentoo() {
    switch_distro_to_gentoo
    return_true "is_gentoo"

    switch_distro_to_ubuntu
    return_false "is_gentoo"
}

test_distro_name() {
    switch_distro_to_debian
    returns debian "distro_name"

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
