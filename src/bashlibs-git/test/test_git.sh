#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include git.sh
include directories.sh

git_for_testing() {
    echo /tmp/test.git
}

remote_git_for_testing() {
    echo /tmp/test_remote.git
}

config_git_for_testing() {
    git_config_username myuser
    git_config_email myuser@gmail.com
    git_config_push_new_behavior
}

add_first_commit() {
    touch a
    git add a
    git commit -av -m 'added a' > /dev/null 2>&1
}

setUp() {
    create_new_bare_git $(remote_git_for_testing) > /dev/null 2>&1
    git clone $(remote_git_for_testing) $(git_for_testing) > /dev/null 2>&1
    cd $(git_for_testing)
    config_git_for_testing
    add_first_commit > /dev/null 2>&1
    git push > /dev/null 2>&1
}

tearDown() {
    cd /tmp
    safe_delete_directory_from_tmp $(git_for_testing)
    safe_delete_directory_from_tmp $(remote_git_for_testing)
}

test_create_new_git() {
    return_true "check_if_current_dir_is_in_git_tree" 
}

test_git_top_dir() {
    returns "$(git_for_testing)" "git_top_dir" 

    mkdir tmp_dir
    cd tmp_dir
    returns "$(git_for_testing)" "git_top_dir" 
}

test_check_if_current_dir_is_in_git_tree() {
    cd /tmp
    return_false "check_if_current_dir_is_in_git_tree"

    cd $(git_for_testing)
    return_true "check_if_current_dir_is_in_git_tree" 
}

test_git_current_branch() {
    returns "master" "git_current_branch"

    git checkout -b new_branch > /dev/null 2>&1
    returns "new_branch" "git_current_branch"
}

test_git_create_new_branch() {
    git_create_new_branch new_branch
    returns "new_branch" "git_current_branch"
}

test_git_is_clean() {
    touch b
    git add b
    return_false "git_is_clean"
    git commit -av -m 'added b' > /dev/null 2>&1
    return_true "git_is_clean"
}

test_git_needs_push() {
    return_false "git_needs_push"
    touch b
    git add b
    git commit -av -m 'added b' > /dev/null 2>&1
    return_true "git_needs_push"
    git push > /dev/null 2>&1
    return_false "git_needs_push"
}

test_git_is_up_to_date() {
    return_true "git_is_up_to_date"
    touch b
    git add b
    git commit -av -m 'added b' > /dev/null 2>&1
    return_false "git_is_up_to_date"
    git push > /dev/null 2>&1
    return_true "git_is_up_to_date"
}

# load shunit2
source /usr/share/shunit2/shunit2
