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

test_dir_is_empty() {
    local dir=$(mktemp -d)

    touch $dir/a
    return_false "dir_is_empty $dir"

    rm -f $dir/a
    return_true "dir_is_empty $dir"

    rmdir $dir
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

test_clean_path() {
    returns "/a"   "clean_path /a"
    returns "/a/b" "clean_path /a/b"
    returns "/a"   "clean_path /a/"
    returns "/a"   "clean_path ///a//////"
    returns "/a"   "clean_path ////a"
    returns "/a/b" "clean_path ////a//////b///"
}

test_top_dir() {
    returns "/first" "top_dir /first"
    returns "/first" "top_dir /first/second"
    returns "/first" "top_dir /first/tmp/second"
    returns "/first" "top_dir /first/second/tmp"
    returns "/tmp"   "top_dir /tmp"
    returns "/tmp"   "top_dir /tmp/"
    returns "/tmp"   "top_dir //tmp/tmp"
    returns "/tmp"   "top_dir /////tmp////tmp"
}

test_directory_is_in_tmp() {
    return_false "directory_is_in_tmp /first"
    return_false "directory_is_in_tmp /first/second"
    return_false "directory_is_in_tmp /first/tmp/second"
    return_false "directory_is_in_tmp /first/second/tmp"
    return_false "directory_is_in_tmp /tmp"
    return_false "directory_is_in_tmp ///tmp"
    return_false "directory_is_in_tmp /tmp/"
    return_false "directory_is_in_tmp ////tmp////"

    return_true "directory_is_in_tmp /tmp/first"
    return_true "directory_is_in_tmp /tmp/first/second"
    return_true "directory_is_in_tmp /tmp/tmp"
    return_true "directory_is_in_tmp //tmp/tmp"
    return_true "directory_is_in_tmp /////tmp////tmp"
}

test_is_dir_under_base_dir() {
    return_false "is_dir_under_base_dir  /tm/abc              /tmp"
    return_false "is_dir_under_base_dir  /tmp                 /tmp"
    return_false "is_dir_under_base_dir  /tmp/                /tmp"
                                                      
    return_true  "is_dir_under_base_dir  /a/b                 /a"
    return_true  "is_dir_under_base_dir  /a/b/c               /a/b"
    return_true  "is_dir_under_base_dir  //tmp///a/b///c////  ////tmp////" 
    return_true  "is_dir_under_base_dir  ////tmp//a///        /tmp/"               
    return_true  "is_dir_under_base_dir  /tmp/b/c             /tmp"
}

test_safe_delete_directory_from_tmp() {
    local dir=$(create_progname_tmp_dir)

    return_true "dir_exist $dir"
    return_true "safe_delete_directory_from_tmp $dir"
    return_false "dir_exist $dir"

    dir=/tmp/dir_dont_exist
    return_false "dir_exist $dir"
    return_false "safe_delete_directory_from_tmp $dir"

    local saved_dir=$(pwd)
    cd ~
    mkdir -p dir_not_in_tmp
    cd dir_not_in_tmp
    dir=$(pwd)
    return_true "dir_exist $dir"
    return_false "safe_delete_directory_from_tmp $dir"
    return_false "safe_delete_directory_from_tmp /dir_not_in_tmp/a"
    return_false "safe_delete_directory_from_tmp /dir_not_in_tmp"

    rmdir $dir
    cd $saved_dir > /dev/null 2>&1
}

test_create_progname_tmp_dir() {
    local dir=$(create_progname_tmp_dir)

    directory_should_exist $dir

    safe_delete_directory_from_tmp $dir
}


# load shunit2
source /usr/share/shunit2/shunit2
