#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include package_build.sh

oneTimeSetUp() {
    TEST_PROJECT_PATH=/tmp/test_project

    mkdir -p $TEST_PROJECT_PATH
    echo "project (bashlibs-build-utils)" \
        > $TEST_PROJECT_PATH/CMakeLists.txt
    echo "project (bashlibs-build-utils)" \
        > $TEST_PROJECT_PATH/.CMakeLists.txt.swp
    echo "$(app_version)" \
        > $TEST_PROJECT_PATH/version
}

oneTimeTearDown() {
    [[ -d $TEST_PROJECT_PATH ]] \
        && [[ $TEST_PROJECT_PATH =~ /tmp/ ]] \
        && rm -f $TEST_PROJECT_PATH/* \
        && rm -f $TEST_PROJECT_PATH/.CMakeLists.txt.swp \
        && rmdir $TEST_PROJECT_PATH
}

progname() {
    echo test_progname
}

progdir() {
    echo /tmp/test_progname
}

project_path() {
    echo $TEST_PROJECT_PATH
}

app_version() {
    echo 0.4.5
}

vinfo() {
    true
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
    returns "bashlibs-build-utils-0.4.5-Linux.deb" \
        "cmake_deb_filename"
}

target_build_host() {
    echo mytesthost
}

test_host() {
    returns "mytesthost" "host"
}

test_package_types() {
    return_value_should_include "deb" \
        "package_types"
    return_value_should_include "tbz" \
        "package_types"
}

test_valid_package_type() {
    return_true "valid_package_type deb"
    return_true "valid_package_type tbz"
    return_false "valid_package_type rpm"
}

test_dir_project_name() {
    returns "test_project" \
        "dir_project_name"
}

test_tbz_filename_prefix() {
    returns "bashlibs-build-utils-0.4.5-Source" \
        "tbz_filename_prefix"
}

test_tbz_filename() {
    returns "bashlibs-build-utils-0.4.5-Source.tar.bz2" \
        "tbz_filename"
}

test_top_dir() {
    returns "tmp" "top_dir /tmp/bbb/aaa"
    returns "ccc" "top_dir /ccc/bbb/aaa"
    returns "ccc" "top_dir /ccc"
}

test_dir_in_tmp() {
    return_true "dir_in_tmp /tmp/bbb/aaa"
    return_true "dir_in_tmp /tmp/bbb/tmp"
    return_false "dir_in_tmp /bbb/tmp"
}

test_is_directory() {
    return_true "is_directory /tmp"
    return_true "is_directory $TEST_PROJECT_PATH"
    return_false "is_directory $TEST_PROJECT_PATH/CMakeLists.txt"
}

test_clean_dir_in_tmp() {
    mkdir -p /tmp/bbb
    touch /tmp/bbb/aaa

    directory_should_exist /tmp/bbb
    file_should_exist /tmp/bbb/aaa

    clean_dir_in_tmp /tmp/bbb

    file_shouldnt_exist /tmp/bbb/aaa
    directory_shouldnt_exist /tmp/bbb
}

test_clean_tmp_dirs() {
    mkdir -p $(tmp_dir)
    touch $(tmp_dir)/aaa

    directory_should_exist $(tmp_dir)
    file_should_exist $(tmp_dir)/aaa

    clean_tmp_dir

    file_shouldnt_exist $(tmp_dir)/aaa
    directory_shouldnt_exist $(tmp_dir)
}

test_workdir() {
    returns "/tmp/test_progname/bashlibs-build-utils-0.4.5-Source" \
        "workdir"
}

test_copy_sources_to_workdir() {
    copy_sources_to_workdir
    file_should_exist $(workdir)/CMakeLists.txt
    file_should_exist $(workdir)/version
    file_shouldnt_exist $(workdir)/.CMakeLists.txt.swp
}

test_local_distfiles_directory() {
    returns "/tmp/gentoo/distfiles" \
        "local_distfiles_directory"
    directory_should_exist "/tmp/gentoo/distfiles"
}

test_tar_sources() {
    local tarfile=$(local_distfiles_directory)/$(tbz_filename)

    tar_sources
    return_true "file $tarfile | grep -q -i tar"
    return_true "tar tf $tarfile | grep -q CMakeLists.txt"
    return_true "tar tf $tarfile | grep -q version"
}

# load shunit2
source /usr/share/shunit2/shunit2
