#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include package_build.sh
include directories.sh

oneTimeSetUp() {
    TEST_PROJECT_PATH=/tmp/test_project

    mkdir -p $TEST_PROJECT_PATH
    echo "project (bashlibs-build-utils)" \
        > $TEST_PROJECT_PATH/CMakeLists.txt
    echo "project (bashlibs-build-utils)" \
        > $TEST_PROJECT_PATH/.CMakeLists.txt.swp
    echo "$(app_version)" \
        > $TEST_PROJECT_PATH/version

    mkdir -p /tmp/local_distfiles_directory
    local_distfiles_directory() {
        echo /tmp/local_distfiles_directory
    }

}

oneTimeTearDown() {
    safe_delete_directory_from_tmp \
        $TEST_PROJECT_PATH

    safe_delete_directory_from_tmp \
        $(progdir)

    safe_delete_directory_from_tmp \
        /tmp/local_distfiles_directory

    unset -f \
        local_distfiles_directory

    true
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

test_tar_sources() {
    local tarfile=$(local_distfiles_directory)/$(tbz_filename)

    tar_sources
    return_true "file $tarfile | grep -q -i tar"
    return_true "tar tf $tarfile | grep -q CMakeLists.txt"
    return_true "tar tf $tarfile | grep -q version"
}

# load shunit2
source /usr/share/shunit2/shunit2
