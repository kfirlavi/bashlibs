#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include package_build.sh

oneTimeSetUp() {
    TEST_PROJECT_PATH=/tmp/test_project

    mkdir -p $TEST_PROJECT_PATH
    echo "project (bashlibs-build-utils)" \
        > $TEST_PROJECT_PATH/CMakeLists.txt
    echo "0.0.9" \
        > $TEST_PROJECT_PATH/version
}

oneTimeTearDown() {
    [[ -d $TEST_PROJECT_PATH ]] \
        && [[ $TEST_PROJECT_PATH =~ /tmp/ ]] \
        && rm -f $TEST_PROJECT_PATH/* \
        && rmdir $TEST_PROJECT_PATH
}

progname() {
    echo test_progname
}

project_path() {
    echo $TEST_PROJECT_PATH
}

test_cmake_project_name() {
    returns "bashlibs-build-utils" \
        "cmake_project_name"
}

test_tmp_dir() {
    returns "/tmp/test_progname" \
        "tmp_dir"
}

test_create_dir_if_needed() {
    local dir=/tmp/test_dir_24235

    return_false "[[ -d $dir ]]"
    create_dir_if_needed $dir > /dev/null 2>&1
    return_true "[[ -d $dir ]]"
    create_dir_if_needed $dir > /dev/null 2>&1
    return_true "[[ -d $dir ]]"

    rmdir $dir
}

test_print_ruler() {
    returns "********************************************************************************" \
        "print_ruler"

    returns "****" \
        "print_ruler '*' 4"

    returns "++++++" \
        "print_ruler '+' 6"
}

test_gap() {
    returns "start_gap stop_gap" \
        "echo start_gap$(gap 1)stop_gap"

    returns "start_gap          stop_gap" \
        "echo start_gap$(gap 10)stop_gap"
}

test_print_header_midline() {
    returns "*    123456789     *" \
        "strip_colors \"$(print_header_midline 123456789 yellow '*' blue 20)\""
    returns "*     1234567890    *" \
        "strip_colors \"$(print_header_midline 1234567890 yellow '*' blue 20)\""
}

test_cmake_deb_filename() {
    returns "bashlibs-build-utils-0.0.9-Linux.deb" \
        "cmake_deb_filename"
}

target_build_host() {
    echo mytesthost
}

test_host() {
    returns "mytesthost" "host"
}

# load shunit2
source /usr/share/shunit2/shunit2
