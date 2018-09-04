create_new_git() {
    local name=$1; shift
    local git_extra_options=$@

    git init $git_extra_options $name
}

git_top_dir() {
    git rev-parse --show-toplevel
}

check_if_current_dir_is_in_git_tree() {
    git rev-parse --show-toplevel > /dev/null 2>&1
}

exit_if_not_in_git_tree() {
    check_if_current_dir_is_in_git_tree \
        || eexit "current dir $(pwd) is not in git repository"
}
