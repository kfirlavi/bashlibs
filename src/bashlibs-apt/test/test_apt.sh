#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include config.sh
include apt.sh

test_setup_apt_warning_to_user() {
    returns "you need to run setup_apt, before using any of the apt functions" \
        "apt_bin"
}

test_setup_apt_set_new_apt() {
    var_to_function which apt
    setup_apt
    returns "apt" "apt_bin"
}

test_setup_apt_set_apt_get() {
    which() {
        local bin=$1
        
        [[ $bin == apt ]] \
            && echo -n

        [[ $bin == apt-get ]] \
            && echo apt-get
    }
    setup_apt
    returns "apt-get" "apt_bin"
}

test_setup_apt_warn_apt_not_found() {
    which() { echo; }
    eexit() { echo $@; }
    returns "Can not find apt or apt-get support in the system" "setup_apt"
}

# load shunit2
source /usr/share/shunit2/shunit2
