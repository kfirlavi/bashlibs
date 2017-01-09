#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include sysfs.sh

tempfile() {
    echo /tmp/sysfs_test_tmpfile
}

setUp() {
    echo -n > $(tempfile)
}

tearDown() {
    rm -f $(tempfile)
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
