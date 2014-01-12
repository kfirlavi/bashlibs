#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh

test_create_dir_if_needed() {
    local dir=/tmp/test_dir_24235

    return_false "[[ -d $dir ]]"
    create_dir_if_needed $dir > /dev/null 2>&1
    return_true "[[ -d $dir ]]"
    create_dir_if_needed $dir > /dev/null 2>&1
    return_true "[[ -d $dir ]]"

    rmdir $dir
}


# load shunit2
source /usr/share/shunit2/shunit2
