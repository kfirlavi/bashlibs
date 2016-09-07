include bake_test.sh

deb_archive_dir_intree() {
    local repo_name=$1

    create_dir_if_needed \
        $(repositories_dir)/$repo_name/$(repository_architecture)/binary
}

deb_archive_dir_real_system() {
    local repo_name=$1

    create_dir_if_needed \
        $(repositories_dir)/$repo_name/$(repository_architecture)/binary
}

deb_repo_dir() {
    local repo_name=$1

    running_in_src_tree \
        && deb_archive_dir_intree $repo_name \
        || deb_archive_dir_real_system $repo_name
}

save_deb_to_each_repository() {
    local repo_name
    local tmpfile=/tmp/$(cmake_deb_filename)

    archive_deb \
        /var/cache/apt/archives/$(cmake_deb_filename) \
        /tmp

    for repo_name in $(repositories_names)
    do
        cp $tmpfile $(deb_repo_dir $repo_name)
    done

    rm -f $tmpfile
}

generate_repository_index_for_each_repository() {
    local repo_name

    for repo_name in $(repositories_names)
    do
        generate_repository_index \
            binary \
            $(repository_architecture) \
            $(deb_repo_dir $repo_name)/../..
    done
}

apt_get_params() {
    echo --assume-yes \
        --force-yes \
        --allow-unauthenticated \
        -f
}

apt_get_cmd() {
    echo \
        DEBIAN_FRONTEND=noninteractive \
        apt-get $(apt_get_params)
}

should_install_pre_compiled_depend() {
    [[ -n $PRE_COMPILE_DEPEND ]]
}

install_pre_compile_dependencies() {
    should_install_pre_compiled_depend \
        || return

    vinfo "Installing $(color yellow)$PRE_COMPILE_DEPEND$(no_color)"

    run_remote \
        $(apt_get_cmd) \
            install $PRE_COMPILE_DEPEND
}

update_apt() {
    [[ -z $UPDATE_APT ]] \
        && return
        
    run_remote $(apt_get_cmd) update
}

create_deb_package() {
    remote_dist_upgrade
    install_pre_compile_dependencies
    clean_remote_dirs
    gen_changelog
    copy_sources_to_target
    run_cmake \
        || eexit "Compilation error"
    update_apt
    copy_deb_to_apt_archives
    install_deb
    save_deb_to_each_repository
    generate_repository_index_for_each_repository
    clean_remote_dirs
    run_tests_of_package
}
