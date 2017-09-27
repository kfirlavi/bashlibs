#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include apt.sh

test_apt_get_quiet_flags() {
    returns \
        "--quiet=2" \
        "apt_get_quiet_flags"
}

test_apt_get_force() {
    returns \
        "apt-get -y --force-yes --quiet=2" \
        "apt_get_force"
}

# load shunit2
source /usr/share/shunit2/shunit2
