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

none_git_directory() {
    echo /tmp/none_git.git
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
    mkdir -p $(none_git_directory)
}

tearDown() {
    cd /tmp
    safe_delete_directory_from_tmp $(git_for_testing)
    safe_delete_directory_from_tmp $(remote_git_for_testing)
    safe_delete_directory_from_tmp $(none_git_directory)
    true
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

test_current_branch_is_master() {
    return_true "current_branch_is_master"

    git_create_new_branch new_branch
    return_false "current_branch_is_master"
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

test_git_is_clean_with_untracked_files() {
    return_false "git_is_clean_with_untracked_files"
    touch b
    return_true "git_is_clean_with_untracked_files"
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

test_git_bare_config_file() {
    returns "$(remote_git_for_testing)/config" \
        "git_bare_config_file $(remote_git_for_testing)"
}

test_git_config_file() {
    returns "$(git_for_testing)/.git/config" \
        "git_config_file $(git_for_testing)"
}

test_is_bare_git() {
    return_true "is_bare_git $(remote_git_for_testing)"
    return_false "is_bare_git $(git_for_testing)"
    return_false "is_bare_git $(none_git_directory)"
}

test_is_regular_git() {
    return_false "is_regular_git $(remote_git_for_testing)"
    return_true "is_regular_git $(git_for_testing)"
    return_false "is_regular_git $(none_git_directory)"
}

test_is_git() {
    return_true "is_git $(remote_git_for_testing)"
    return_true "is_git $(git_for_testing)"
    return_false "is_git $(none_git_directory)"
}

test_git_clean_untracked() {
    local f=untracked_file

    touch $f
    return_true "file_exist $f"
    git_clean_untracked $(git_for_testing) > /dev/null 2>&1
    return_false "file_exist $f"
}

test_git_delete_uncommited_work() {
    local f=uncommited_file

    touch $f
    git add $f
    return_true "file_exist $f"
    git_delete_uncommited_work $(git_for_testing) > /dev/null 2>&1
    return_false "file_exist $f"
}

test_git_reset_to_origin() {
    local f=uncommited_file

    touch $f
    git add $f
    git commit -av -m "added $f" > /dev/null 2>&1
    return_true "file_exist $f"
    git_reset_to_origin $(git_for_testing) > /dev/null 2>&1
    return_false "file_exist $f"
}


# load shunit2
source /usr/share/shunit2/shunit2
