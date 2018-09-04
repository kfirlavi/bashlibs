#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include git.sh
include directories.sh

git_for_testing() {
    echo /tmp/test.git
}

setUp() {
    create_new_git $(git_for_testing) > /dev/null 2>&1
}

tearDown() {
    cd /tmp
    safe_delete_directory_from_tmp $(git_for_testing)
}

test_create_new_git() {
    cd $(git_for_testing)
    return_true "check_if_current_dir_is_in_git_tree" 
}

test_git_top_dir() {
    cd $(git_for_testing)
    returns "$(git_for_testing)" "git_top_dir" 

    mkdir a
    cd a
    returns "$(git_for_testing)" "git_top_dir" 
}

test_check_if_current_dir_is_in_git_tree() {
    cd /tmp
    return_false "check_if_current_dir_is_in_git_tree"

    cd $(git_for_testing)
    return_true "check_if_current_dir_is_in_git_tree" 
}

# load shunit2
source /usr/share/shunit2/shunit2
