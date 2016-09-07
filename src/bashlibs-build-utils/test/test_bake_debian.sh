#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_debian.sh

test_apt_get_params() {
    returns \
    "--assume-yes --force-yes --allow-unauthenticated -f" \
    "apt_get_params"
}

test_apt_get_cmd() {
    returns \
    "DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --force-yes --allow-unauthenticated -f" \
    "apt_get_cmd"
}

test_should_install_pre_compiled_depend() {
    local PRE_COMPILE_DEPEND=
    return_false "should_install_pre_compiled_depend"

    local PRE_COMPILE_DEPEND=1
    return_true "should_install_pre_compiled_depend"
}

# load shunit2
source /usr/share/shunit2/shunit2
