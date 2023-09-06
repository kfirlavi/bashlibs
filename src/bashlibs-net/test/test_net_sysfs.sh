#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh
include config.sh
include net_sysfs.sh

oneTimeSetUp() {
    create_workdir
    mkdir -p $(sysfs_root_path $(workdir))/net/{core,ipv4}

    var_to_function core_tempfile $(sysfs_root_path $(workdir))/net/core/core_param
    echo -n > $(core_tempfile)

    var_to_function ipv4_tempfile $(sysfs_root_path $(workdir))/net/ipv4/ipv4_param
    echo -n > $(ipv4_tempfile)
}

oneTimeTearDown() {
    remove_workdir
    true
}

test_sysfs_net_root_path() {
    returns "/proc/sys/net" "sysfs_net_root_path"
    returns "/tmp/proc/sys/net" "sysfs_net_root_path /tmp"

    var_to_function \
        sysfs_net_root_path \
        $(sysfs_root_path $(workdir))/net
}

test_sysfs_set_net() {
    sysfs_set_net core core_param value1 value2
    returns "value1 value2" "cat $(core_tempfile)"
}

test_sysfs_set_net_core() {
    sysfs_set_net_core core_param value3
    returns "value3" "cat $(core_tempfile)"
}

test_sysfs_set_net_ipv4() {
    sysfs_set_net_ipv4 ipv4_param value4
    returns "value4" "cat $(ipv4_tempfile)"
}

# load shunit2
source /usr/share/shunit2/shunit2
