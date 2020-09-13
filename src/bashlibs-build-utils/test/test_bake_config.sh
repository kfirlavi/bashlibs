#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_config.sh
include directories.sh

oneTimeSetUp() {
    TEST_DIR=$(create_progname_tmp_dir)

    mkdir -p $TEST_DIR/{proj1,proj2,common/{proj3,proj4}}
    touch $TEST_DIR/proj1/.bakerc
    touch $TEST_DIR/proj2/.bakerc
    touch $TEST_DIR/common/proj3/.bakerc
    mkdir $TEST_DIR/proj2/src

    echo "TOP_RC=1" > $TEST_DIR/.bakerc
}

oneTimeTearDown() {
    safe_delete_directory_from_tmp \
        $TEST_DIR
}

test_config_file_name() {
    returns ".bakerc" "config_file_name"
}

test_config_file_exist() {
    return_true "config_file_exist $TEST_DIR"
    return_true "config_file_exist $TEST_DIR/proj2"
    return_true "config_file_exist $TEST_DIR/common/proj3"
    return_false "config_file_exist $TEST_DIR/non_exist_path"
    return_false "config_file_exist $TEST_DIR/proj2/src"
}

test_load_config_file() {
    echo "MYTESTVAR=54" > $TEST_DIR/proj2/.bakerc

    var_is_not_defined MYTESTVAR

    load_config_file $TEST_DIR/proj2

    var_should_be_defined MYTESTVAR
    var_equal MYTESTVAR 54
}

test_set_top_level_path() {
    set_top_level_path
    returns_empty "top_level_path"

    set_top_level_path /tmp/aaa
    returns "/tmp/aaa" "top_level_path"
}

test_is_top_level_path() {
    return_true "is_top_level_path $TEST_DIR"
    return_false "is_top_level_path $TEST_DIR/proj2"
    return_false "is_top_level_path $TEST_DIR/common/proj3"
    return_false "is_top_level_path $TEST_DIR/non_exist_path"
    return_false "is_top_level_path $TEST_DIR/proj2/src"
}

test_sources_root_path() {
    echo "TOP_RC=1" > $TEST_DIR/.bakerc

    returns "$TEST_DIR" \
        "sources_root_path $TEST_DIR/proj1"

    returns "$TEST_DIR" \
        "sources_root_path $TEST_DIR/proj2"

    returns "$TEST_DIR" \
        "sources_root_path $TEST_DIR/common/proj3"

    returns "$TEST_DIR" \
        "sources_root_path $TEST_DIR/common/proj4"

    local SOURCES_TREE_PATH=$TEST_DIR
    returns $TEST_DIR "sources_root_path"

    SOURCES_TREE_PATH=$TEST_DIR/proj1
    returns $TEST_DIR "sources_root_path"

    SOURCES_TREE_PATH=$TEST_DIR/..
    returns_empty "sources_root_path"

    cd $TEST_DIR
    returns "$TEST_DIR" \
        "sources_root_path proj1"

    cd $TEST_DIR/common
    returns "$TEST_DIR" \
        "sources_root_path proj3"


    rm $TEST_DIR/.bakerc

    returns_empty \
        "sources_root_path $TEST_DIR/common/proj4"

    returns_empty \
        "sources_root_path $TEST_DIR/proj2"


    touch $TEST_DIR/.bakerc

    returns_empty \
        "sources_root_path $TEST_DIR/common/proj4"

    returns_empty \
        "sources_root_path $TEST_DIR/proj2"
}

test_path_is_in_source_tree() {
    echo "TOP_RC=1" > $TEST_DIR/.bakerc

    return_true "path_is_in_source_tree $TEST_DIR/proj1"
    return_true "path_is_in_source_tree $TEST_DIR/common/proj3"

    return_false "path_is_in_source_tree $TEST_DIR/.."

    return_false "path_is_in_source_tree $TEST_DIR/non_existing_path"

    cd $TEST_DIR
    return_true "path_is_in_source_tree proj1"

    cd $TEST_DIR/common
    return_true "path_is_in_source_tree proj3"


    rm $TEST_DIR/.bakerc

    return_false \
        "path_is_in_source_tree $TEST_DIR/common/proj4"

    return_false \
        "path_is_in_source_tree $TEST_DIR/proj2"


    touch $TEST_DIR/.bakerc

    return_false \
        "path_is_in_source_tree $TEST_DIR/common/proj4"

    return_false \
        "path_is_in_source_tree $TEST_DIR/proj2"
}

# load shunit2
source /usr/share/shunit2/shunit2
