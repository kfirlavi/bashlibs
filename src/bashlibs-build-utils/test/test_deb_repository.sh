#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include deb_repository.sh

oneTimeSetUp() {
    TEST_PROJECT_PATH=/tmp/test_project

    mkdir -p $TEST_PROJECT_PATH
    echo "project (bashlibs-build-utils)" \
        > $TEST_PROJECT_PATH/CMakeLists.txt
    echo "0.0.9" \
        > $TEST_PROJECT_PATH/version

    PACKAGES_DIR=$TEST_PROJECT_PATH/packages

    mkdir -p $PACKAGES_DIR
    touch $PACKAGES_DIR/Packages.gz
    touch $PACKAGES_DIR/bashlibs-base-0.0.4-Linux.deb
    touch $PACKAGES_DIR/bashlibs-base-0.0.5-Linux.deb
    touch $PACKAGES_DIR/bashlibs-base-0.0.10-Linux.deb
    touch $PACKAGES_DIR/bashlibs-cmake-macros-0.0.25-Linux.deb
}

oneTimeTearDown() {
    [[ -d $TEST_PROJECT_PATH ]] \
        && [[ $TEST_PROJECT_PATH =~ /tmp/ ]] \
        && rm -Rf $TEST_PROJECT_PATH
}

progdir() {
    echo /tmp/test_project/bin
}

progname() {
    echo test_progname
}

target_architecture() {
    echo x86_64
}

test_repository_dir() {
    returns "/tmp/test_project/debian/bashlibs-repository/amd64" \
        "repository_dir"
}

test_repository_binary_dir() {
    returns "/tmp/test_project/debian/bashlibs-repository/amd64/binary" \
        "repository_binary_dir"
}

test_repository_architecture() {
    target_architecture() { echo armv7l;}
    returns "armhf" "repository_architecture"

    target_architecture() { echo i686;}
    returns "i386" "repository_architecture"

    target_architecture() { echo i386;}
    returns "i386" "repository_architecture"

    target_architecture() { echo x86_64;}
    returns "amd64" "repository_architecture"
}

test_deb_archive_dir() {
    returns "/tmp/test_project/debian/deb-archive/amd64" \
        "deb_archive_dir"
}

test_copy_deb_to_repository() {
    touch /tmp/mydeb.deb

    return_false "[[ -f /tmp/test_project/debian/bashlibs-repository/amd64/binary/mydeb.deb ]]"

    copy_deb_to_repository /tmp/mydeb.deb

    return_true "[[ -f /tmp/test_project/debian/bashlibs-repository/amd64/binary/mydeb.deb ]]"
}

test_uniq_packages() {
    local dir=$PACKAGES_DIR

    return_value_should_include "bashlibs-base" \
        "uniq_packages $dir"
    return_value_should_include "bashlibs-cmake-macros" \
        "uniq_packages $dir"
}

test_package_name_part() {
    returns "bashlibs-base" \
        "package_name bashlibs-base-0.0.4-Linux.deb 3-"

    returns "0.0.4" \
        "package_version bashlibs-base-0.0.4-Linux.deb 2"

    returns "Linux.deb" \
        "package_postfix bashlibs-base-0.0.4-Linux.deb 1"
}

test_package_name() {
    returns "bashlibs-base" \
        "package_name bashlibs-base-0.0.4-Linux.deb"

    returns "bashlibs" \
        "package_name bashlibs-0.0.4-Linux.deb"
}

test_package_version() {
    returns "0.0.4" \
        "package_version bashlibs-base-0.0.4-Linux.deb"

    returns "0.0.1" \
        "package_version bashlibs-0.0.1-Linux.deb"

    returns "3423.87.10" \
        "package_version bashlibs-base-3423.87.10-Linux.deb"
}

test_package_postfix() {
    returns "Linux.deb" \
        "package_postfix bashlibs-base-0.0.4-Linux.deb"
}

test_packages_versions() {
    returns "0.0.2 0.0.1" \
        "packages_versions bashlibs-base-0.0.2-Linux.deb bashlibs-base-0.0.1-Linux.deb"
}

test_sort_versions() {
    returns "0.0.1 0.0.2" \
        "sort_versions 0.0.2 0.0.1"

    returns "0.0.1 0.0.2 0.4.33 0.5.6 1.20.2 10.0.0 11.2.98" \
        "sort_versions 0.0.2 0.0.1 11.2.98 1.20.2 0.5.6 10.0.0 0.4.33"
}

test_max_version() {
    returns "0.0.2" \
        "max_version 0.0.2 0.0.1"

    returns "11.2.98" \
        "max_version 0.0.2 0.0.1 11.2.98 1.20.2 0.5.6 10.0.0 0.4.33"
}

test_all_versions_of_pacakge() {
    local dir=$PACKAGES_DIR

    return_value_should_include "bashlibs-base-0.0.4-Linux.deb" \
        "all_versions_of_pacakge $dir/bashlibs-base"
    return_value_should_include "$dir/bashlibs-base-0.0.5-Linux.deb" \
        "all_versions_of_pacakge $dir/bashlibs-base"
    return_value_should_include "$dir/bashlibs-base-0.0.10-Linux.deb" \
        "all_versions_of_pacakge $dir/bashlibs-base"
}

test_package_by_version() {
    local dir=$PACKAGES_DIR

    return_value_should_include "$dir/bashlibs-base-0.0.5-Linux.deb" \
        "package_by_version $dir/bashlibs-base 0.0.5"

}

test_newest_package() {
    local dir=$PACKAGES_DIR

    returns "$dir/bashlibs-base-0.0.10-Linux.deb" \
        "newest_package $dir/bashlibs-base"

    returns "$dir/bashlibs-cmake-macros-0.0.25-Linux.deb" \
        "newest_package $dir/bashlibs-cmake-macros"
}

test_copy_newest_debs_to_repository() {
    local dir=$PACKAGES_DIR
    mkdir -p $(deb_archive_dir)
    touch $(deb_archive_dir)/bashlibs-base-0.0.4-Linux.deb
    touch $(deb_archive_dir)/bashlibs-base-0.0.5-Linux.deb
    touch $(deb_archive_dir)/bashlibs-base-0.0.10-Linux.deb
    touch $(deb_archive_dir)/bashlibs-cmake-macros-0.0.25-Linux.deb

    copy_newest_debs_to_repository
    return_value_should_include "bashlibs-base-0.0.10-Linux.deb" \
        "ls -1 $(repository_binary_dir)"
    return_value_should_include "bashlibs-cmake-macros-0.0.25-Linux.deb" \
        "ls -1 $(repository_binary_dir)"
}

# load shunit2
source /usr/share/shunit2/shunit2
