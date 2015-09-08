#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_cmake.sh
include directories.sh

oneTimeSetUp() {
    TEST_DIR=$(mktemp -d)

    mkdir -p $TEST_DIR/{proj1,proj2,common/{proj3,proj4}}
    echo "project (proj1)" > $TEST_DIR/proj1/CMakeLists.txt
    echo "project (proj2)" > $TEST_DIR/proj2/CMakeLists.txt
    echo "project (proj3)" > $TEST_DIR/common/proj3/CMakeLists.txt
    echo "project (proj4)" > $TEST_DIR/common/proj4/CMakeLists.txt

    mkdir $TEST_DIR/proj2/src
    touch $TEST_DIR/proj2/src/CMakeLists.txt
}

oneTimeTearDown() {
    safe_delete_directory_from_tmp \
        $TEST_DIR
}

test_all_cmake_project_files() {
    return_value_should_include \
        "$TEST_DIR/proj1/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"

    return_value_should_include \
        "$TEST_DIR/proj2/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"

    return_value_should_include \
        "$TEST_DIR/common/proj3/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"

    return_value_should_include \
        "$TEST_DIR/common/proj4/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"

    return_value_shouldnt_include \
        "$TEST_DIR/proj2/src/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"
}

# load shunit2
source /usr/share/shunit2/shunit2
