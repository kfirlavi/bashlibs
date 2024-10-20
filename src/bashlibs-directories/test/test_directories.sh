#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh

setUp() {
    create_workdir
}

tearDown() {
    remove_workdir
    true
}

test_dir_exist() {
    local dir=$(workdir)

    return_true "dir_exist $dir"
    rmdir $dir
    return_false "dir_exist $dir"

    return_false "dir_exist"
}

test_dir_is_empty() {
    local dir=$(workdir)

    touch $dir/a
    return_false "dir_is_empty $dir"

    rm -f $dir/a
    return_true "dir_is_empty $dir"
}

test_create_dir_if_needed() {
    local dir=$(workdir)/abc

    return_false "dir_exist $dir"
    returns "$dir" "create_dir_if_needed $dir"
    return_true "dir_exist $dir"
    returns "$dir" "create_dir_if_needed $dir"
    return_true "dir_exist $dir"
}

test_create_dir_if_needed_quiet() {
    local dir=$(workdir)/abc

    return_false "dir_exist $dir"
    returns_empty "create_dir_if_needed $dir quiet"
    return_true "dir_exist $dir"
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

test_dir_size() {
    dd \
        if=/dev/zero \
        of=$(workdir)/a \
        bs=1K \
        count=1500 \
            > /dev/null 2>&1

    returns "1.5M" "dir_size $(workdir)"
}

test_empty_dir() {
    mkdir -p $(workdir)/a/b/c
    mkdir -p $(workdir)/.a/.b/.c
    touch $(workdir)/d
    touch $(workdir)/a/b/c/e
    touch $(workdir)/.a/.b/.c/f

    empty_dir $(workdir)

    return_true "dir_is_empty $(workdir)"
}

test_empty_dirs() {
    mkdir -p $(workdir)/a/b/c
    mkdir -p $(workdir)/.a/.b/.c
    touch $(workdir)/a/b/c/e
    touch $(workdir)/.a/.b/.c/f

    empty_dirs \
        $(workdir)/a \
        $(workdir)/.a

    return_true "dir_is_empty $(workdir)/a"
    return_true "dir_is_empty $(workdir)/.a"
}

test_create_progname_tmp_dir() {
    local dir=$(create_progname_tmp_dir)

    directory_should_exist $dir

    safe_delete_directory_from_tmp $dir
}

test_create_workdir() {
    create_workdir

    directory_should_exist $(workdir)
}

test_remove_workdir() {
    remove_workdir

    directory_shouldnt_exist $(workdir)
}

# load shunit2
source /usr/share/shunit2/shunit2
