package_is_bashlib() {
    local project_name=$1

    echo $project_name \
        | egrep -q '^bashlibs-'
}

package_test_files_gentoo() {
    run_remote \
        equery files $(cmake_project_name) \
           | grep test_
}

package_test_files_ubuntu() {
    run_remote \
        dpkg -L $(cmake_project_name) \
           | grep test_
}

package_test_files_debian() {
    package_test_files_ubuntu
}

package_test_files() {
    target_os_is_gentoo \
        && package_test_files_$(target_os)

    target_os_is_gentoo \
        && package_test_files_gentoo
}

package_has_test_files() {
    [[ -n $(package_test_files_$(target_os)) ]]
}

run_tests_of_package() {
    [[ -z $RUN_TESTS ]] \
        && return

    package_is_bashlib $(cmake_project_name) \
        || return

    package_has_test_files \
        || return

    local i

    for i in $(package_test_files_$(target_os))
    do
        run_remote \
            bashlibs -v --test $(basename $i)
    done
}
