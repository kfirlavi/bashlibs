create_new_bare_git() {
    local name=$1

    git init --bare $name
}

create_new_git() {
    local name=$1; shift
    local git_extra_options=$@

    git init $git_extra_options $name
    cd $name
    git commit --allow-empty -m "initial commit"
}

git_top_dir() {
    git rev-parse --show-toplevel
}

check_if_current_dir_is_in_git_tree() {
    git rev-parse --show-toplevel > /dev/null 2>&1
}

git_current_branch() {
    git symbolic-ref --short HEAD
}
 
git_create_new_branch() {
    local branch_name=$1

    git checkout -b $branch_name > /dev/null 2>&1
}

exit_if_not_in_git_tree() {
    check_if_current_dir_is_in_git_tree \
        || eexit "current dir $(pwd) is not in git repository"
}

git_status() {
    git status
}

git_is_up_to_date() {
    git_status \
        | grep -q '^Your branch is up.to.date with'
}

git_needs_push() {
    git_status \
        | grep -q '^Your branch is ahead of'
}

git_is_clean() {
    git_status \
        | grep -q '^nothing to commit, working .* clean'
}

git_config_email() {
    local email=$1

    git config user.email "$email"
}

git_config_username() {
    local name=$1

    git config user.name "$name"
}

git_config_push_new_behavior() {
    git config push.default simple
}
