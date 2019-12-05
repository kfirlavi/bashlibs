#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_cmake.sh
include directories.sh

setUp() {
    TEST_DIR=$(mktemp -d)

    mkdir -p $TEST_DIR/{proj1,proj2,common/{proj3,proj4,proj5},ignored/{proj6,proj7,tmp/proj8}}
    echo "project (proj1)" > $TEST_DIR/proj1/CMakeLists.txt
    echo "project (proj2)" > $TEST_DIR/proj2/CMakeLists.txt
    echo "project (proj3)" > $TEST_DIR/common/proj3/CMakeLists.txt
    echo "project (proj4)" > $TEST_DIR/common/proj4/CMakeLists.txt
    echo "project (proj5)" > $TEST_DIR/common/proj5/CMakeLists.txt
    touch $TEST_DIR/common/proj5/.bake_ignore_below
    echo "project (proj6)" > $TEST_DIR/ignored/proj6/CMakeLists.txt
    echo "project (proj7)" > $TEST_DIR/ignored/proj7/CMakeLists.txt
    echo "project (proj7)" > $TEST_DIR/ignored/tmp/proj8/CMakeLists.txt
    touch $TEST_DIR/ignored/.bake_ignore_below

    mkdir $TEST_DIR/proj2/src
    touch $TEST_DIR/proj2/src/CMakeLists.txt
}

tearDown() {
    safe_delete_directory_from_tmp \
        $TEST_DIR
}

test_all_cmake_files() {
    return_value_should_include \
        "$TEST_DIR/proj1/CMakeLists.txt" \
        "all_cmake_files $TEST_DIR"

    return_value_should_include \
        "$TEST_DIR/proj2/CMakeLists.txt" \
        "all_cmake_files $TEST_DIR"

    return_value_should_include \
        "$TEST_DIR/common/proj3/CMakeLists.txt" \
        "all_cmake_files $TEST_DIR"

    return_value_should_include \
        "$TEST_DIR/common/proj4/CMakeLists.txt" \
        "all_cmake_files $TEST_DIR"

    return_value_should_include \
        "$TEST_DIR/proj2/src/CMakeLists.txt" \
        "all_cmake_files $TEST_DIR"
}

test_cmakefile_should_be_ignored() {
    return_false "cmakefile_should_be_ignored $TEST_DIR/common/proj4/CMakeLists.txt"

    return_true  "cmakefile_should_be_ignored $TEST_DIR/common/proj5/CMakeLists.txt"
    return_true  "cmakefile_should_be_ignored $TEST_DIR/ignored/proj6/CMakeLists.txt"
    return_true  "cmakefile_should_be_ignored $TEST_DIR/ignored/proj7/CMakeLists.txt"
    return_true  "cmakefile_should_be_ignored $TEST_DIR/ignored/tmp/proj8/CMakeLists.txt"
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

    return_value_shouldnt_include \
        "$TEST_DIR/common/proj5/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"

    return_value_shouldnt_include \
        "$TEST_DIR/ignored/proj6/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"

    return_value_shouldnt_include \
        "$TEST_DIR/ignored/proj7/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"

    return_value_shouldnt_include \
        "$TEST_DIR/ignored/tmp/proj8/CMakeLists.txt" \
        "all_cmake_project_files $TEST_DIR"

    cd $TEST_DIR
    
    return_value_shouldnt_include \
        "./ignored/tmp/proj8/CMakeLists.txt" \
        "all_cmake_project_files ."

    return_value_should_include \
        "./common/proj4/CMakeLists.txt" \
        "all_cmake_project_files ."


    cd - > /dev/null
}

test_cmake_project_file() {
    returns \
        "$TEST_DIR/proj1/CMakeLists.txt" \
        "cmake_project_file proj1 $TEST_DIR"

    returns \
        "$TEST_DIR/proj2/CMakeLists.txt" \
        "cmake_project_file proj2 $TEST_DIR"

    returns \
        "$TEST_DIR/common/proj3/CMakeLists.txt" \
        "cmake_project_file proj3 $TEST_DIR"

    returns_empty \
        "cmake_project_file non_exist_project_name $TEST_DIR"
}

test_cmake_project_path() {
    returns \
        "$TEST_DIR/proj1" \
        "cmake_project_path proj1 $TEST_DIR"

    returns \
        "$TEST_DIR/proj2" \
        "cmake_project_path proj2 $TEST_DIR"

    returns \
        "$TEST_DIR/common/proj3" \
        "cmake_project_path proj3 $TEST_DIR"

    returns_empty \
        "cmake_project_path non_exist_project_name $TEST_DIR"
}

test_project_exist() {
    return_true \
        "project_exist proj1 $TEST_DIR"

    return_true \
        "project_exist proj2 $TEST_DIR"

    return_true \
        "project_exist proj3 $TEST_DIR"

    return_true \
        "project_exist proj4 $TEST_DIR"

    return_false \
        "project_exist non_exist_project_name $TEST_DIR"

    return_false \
        "project_exist $TEST_DIR"
}

test_extract_project_name_from_cmake_file() {
    returns \
        "proj1" \
        "extract_project_name_from_cmake_file \
            $TEST_DIR/proj1/CMakeLists.txt"

    returns \
        "proj2" \
        "extract_project_name_from_cmake_file \
            $TEST_DIR/proj2/CMakeLists.txt"

    returns \
        "proj3" \
        "extract_project_name_from_cmake_file \
            $TEST_DIR/common/proj3/CMakeLists.txt"

    returns_empty \
        "extract_project_name_from_cmake_file \
            $TEST_DIR/proj2/src/CMakeLists.txt"
}

test_extract_project_name_from_path() {
    returns \
        "proj1" \
        "extract_project_name_from_path \
            $TEST_DIR/proj1"

    returns \
        "proj2" \
        "extract_project_name_from_path \
            $TEST_DIR/proj2"

    returns \
        "proj3" \
        "extract_project_name_from_path \
            $TEST_DIR/common/proj3"

    returns_empty \
        "extract_project_name_from_path \
            $TEST_DIR/proj2/src"
}

test_cmake_file() {
    returns "/aaa/CMakeLists.txt" "cmake_file /aaa"
}

test_cmake_file_exist() {
    return_true "cmake_file_exist $TEST_DIR/proj2"
    rm $TEST_DIR/proj2/CMakeLists.txt
    return_false "cmake_file_exist $TEST_DIR/proj2"
}

test_is_path() {
    return_true "is_path $TEST_DIR/proj2/src"
    return_false "is_path bashlibs-colors"
}

test_is_valid_project_path() {
    return_true "is_valid_project_path $TEST_DIR/proj2"
    return_true "is_valid_project_path $TEST_DIR/proj2/"

    rm $TEST_DIR/proj2/CMakeLists.txt
    return_false "is_valid_project_path $TEST_DIR/proj2"

    return_false "is_valid_project_path $TEST_DIR/proj2/src/"
    return_false "is_valid_project_path bashlibs-colors"
}

# load shunit2
source /usr/share/shunit2/shunit2
