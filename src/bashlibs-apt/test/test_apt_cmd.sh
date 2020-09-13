#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include config.sh
include apt_cmd.sh

setUp() {
    var_to_function apt_bin apt
}

test_apt_quiet_flags() {
    returns \
        "--quiet=2" \
        "apt_quiet_flags"
}

test_apt_noninteractive_flag() {
    returns \
        "DEBIAN_FRONTEND=noninteractive" \
        "apt_noninteractive_flag"
}

test_apt_force() {
    returns \
        "DEBIAN_FRONTEND=noninteractive apt -y --force-yes --quiet=2" \
        "apt_force"
}

test_apt_cmd_fix_install() {
    returns \
        "DEBIAN_FRONTEND=noninteractive apt -y --force-yes --quiet=2 install" \
        "apt_cmd_fix_install"
}

test_apt_cmd_install_package() {
    returns \
        "DEBIAN_FRONTEND=noninteractive apt -y --force-yes --quiet=2 install my-package" \
        "apt_cmd_install_package my-package"
}

test_apt_cmd_update() {
    returns \
        "DEBIAN_FRONTEND=noninteractive apt -y --force-yes --quiet=2 update" \
        "apt_cmd_update"
}

test_apt_cmd_upgrade() {
    returns \
        "DEBIAN_FRONTEND=noninteractive apt -y --force-yes --quiet=2 upgrade" \
        "apt_cmd_upgrade"
}

test_apt_cmd_autoremove() {
    returns \
        "DEBIAN_FRONTEND=noninteractive apt -y --force-yes --quiet=2 autoremove" \
        "apt_cmd_autoremove"
}

test_apt_cmd_clean() {
    returns \
        "DEBIAN_FRONTEND=noninteractive apt -y --force-yes --quiet=2 clean" \
        "apt_cmd_clean"
}

# load shunit2
source /usr/share/shunit2/shunit2
