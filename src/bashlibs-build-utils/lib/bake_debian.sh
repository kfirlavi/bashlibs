deb_archive_dir_intree() {
    local rep_name=$1

    create_dir_if_needed \
        $(repositories_dir)/$rep_name/$(repository_architecture)/binary
}

deb_archive_dir_real_system() {
    local rep_name=$1

    create_dir_if_needed \
        $(repositories_dir)/$rep_name/$(repository_architecture)/binary
}

deb_archive_dir() {
    local rep_name=$1

    running_in_src_tree \
        && deb_archive_dir_intree $rep_name \
        || deb_archive_dir_real_system $rep_name
}

save_deb_to_each_repository() {
    local rep_name
    local tmpfile=/tmp/$(cmake_deb_filename)

    archive_deb \
        /var/cache/apt/archives/$(cmake_deb_filename) \
        /tmp

    for rep_name in $(repositories_names)
    do
        cp $tmpfile $(deb_archive_dir $rep_name)
    done

    rm -f $tmpfile
}

generate_repository_index_for_each_repository() {
    local rep_name

    for rep_name in $(repositories_names)
    do
        generate_index \
            binary \
            Packages \
            $(deb_archive_dir $rep_name)/..
    done
}

install_all_apt_required_software() {
    run_remote DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes -f install
}

should_install_pre_compiled_depend() {
    [[ -n $PRE_COMPILE_DEPEND ]]
}

install_pre_compile_dependencies() {
    vinfo "Installing $PRE_COMPILE_DEPEND"
    run_remote DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install $PRE_COMPILE_DEPEND
}

update_apt() {
    [[ -n $UPDATE_APT ]] \
        && run_remote DEBIAN_FRONTEND=noninteractive apt-get update
}

create_deb_package() {
    should_install_pre_compiled_depend \
        && install_pre_compile_dependencies

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
#    run_remote dpkg -L $(cmake_project_name)
#    run_remote aptitude install $(cmake_project_name)
#    run_remote $PROGNAME --test
}
