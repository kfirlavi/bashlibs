#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh

test_dir_exist() {
    local dir=$(mktemp -d)

    return_true "dir_exist $dir"
    rmdir $dir
    return_false "dir_exist $dir"
}

test_create_dir_if_needed() {
    local dir=$(mktemp -d)
    rmdir $dir

    return_false "dir_exist $dir"
    create_dir_if_needed $dir > /dev/null 2>&1
    return_true "dir_exist $dir"
    create_dir_if_needed $dir > /dev/null 2>&1
    return_true "dir_exist $dir"

    rmdir $dir
}


# load shunit2
source /usr/share/shunit2/shunit2
