#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh
include config.sh
include sysfs.sh

setUp() {
    create_workdir
    var_to_function tempfile $(workdir)/proc/sys/test_file
    mkdir -p $(dirname $(tempfile))
    echo -n > $(tempfile)
}

tearDown() {
    remove_workdir
    true
}

test_sysfs_root_path() {
    returns "/proc/sys" "sysfs_root_path"
    returns "/tmp/proc/sys" "sysfs_root_path /tmp"
}

test_sysfs_set_value() {
    sysfs_set_value $(tempfile) abc
    returns "abc" "cat $(tempfile)"

    sysfs_set_value $(tempfile) abc efg 123
    returns "abc efg 123" "cat $(tempfile)"

    return_true "sysfs_set_value /none/exist/path abc | grep -q Error:"
}

test_sysfs_option_on() {
    sysfs_option_on $(tempfile)
    returns "1" "cat $(tempfile)"
}

test_sysfs_option_off() {
    sysfs_option_off $(tempfile)
    returns "0" "cat $(tempfile)"
}

# load shunit2
source /usr/share/shunit2/shunit2
