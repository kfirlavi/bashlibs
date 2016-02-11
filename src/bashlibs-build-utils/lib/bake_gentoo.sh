emerge_quiet() {
    [[ -n $QUIET ]] \
        && echo '--quiet'
}

local_distfiles_directory() {
    create_dir_if_needed $(repositories_dir)/gentoo/distfiles
}

target_distdir() {
    run_remote grep DISTDIR /etc/portage/make.conf \
        | tail -1 \
        | cut -d '"' -f 2
}

create_target_distdir_if_needed() {
    run_remote mkdir -p $(target_distdir)
}

copy_tbz_package_to_server() {
    create_target_distdir_if_needed
    rsync \
        $(local_distfiles_directory)/$(tbz_filename) \
        root@$(target_build_host):$(target_distdir)/
}

copy_portage_tree_to_server() {
    rsync -r --delete \
        $(portage_tree)/ \
        root@$(target_build_host):$(gentoo_local_portage_path)
}

reponame() {
    cat $(portage_tree)/profiles/repo_name
}

change_portage_tree_name_on_the_server() {
    local f=/tmp/repo_name
    echo Local $(reponame) > $f
    rsync -aq $f \
        root@$(target_build_host):$(gentoo_local_portage_path)/profiles/
}

copy_portage_tree_manifests_from_server() {
    rsync -r \
        --include="*/" \
        --include=Manifest \
        --exclude="*" \
        root@$(target_build_host):$(gentoo_local_portage_path)/ \
        $(portage_tree)
}

find_ebuild_for_package() {
    find $(portage_tree) \
        -name "*$(cmake_project_name)-$(app_version)*"
}

package_category() {
    find_ebuild_for_package \
        | rev \
        | cut -d '/' -f 3 \
        | rev
}

package_name_with_version() {
    find_ebuild_for_package \
        | rev \
        | cut -d '/' -f 1 \
        | cut -d '.' -f 2- \
        | rev
}

package_full_name_with_version() {
    echo $(package_category)/$(package_name_with_version)
}

ebuild_exist() {
    [[ -n $(find_ebuild_for_package) ]]
}

exit_if_ebuild_dont_exist() {
    ebuild_exist \
        || eexit "ebuild for package $(cmake_project_name)-$(app_version) not found in portage tree $(portage_tree)"
}

ebuild_filename() {
    echo $(cmake_project_name)-$(app_version).ebuild
}

remote_ebuild_path() {
    run_remote "find $(gentoo_local_portage_path) -name '$(ebuild_filename)'"
}

remote_ebuild_category_path() {
    dirname $(remote_ebuild_path)
}

remote_delete_manifest_file() {
    run_remote "rm $(remote_ebuild_category_path)/Manifest"
}

update_ebuild_manifest() {
    remote_delete_manifest_file
    run_remote "ebuild $(remote_ebuild_path) manifest"
}

portage_overlay_line() {
    echo "PORTDIR_OVERLAY=\"\${PORTDIR_OVERLAY} $(gentoo_local_portage_path)\""
}

portage_overlay_line_already_defined() {
    run_remote cat /etc/portage/make.conf \
        | grep -q "$(portage_overlay_line)"
}

set_local_portage_tree_on_server() {
    portage_overlay_line_already_defined \
        || run_remote "echo '$(portage_overlay_line)' >> /etc/portage/make.conf"
}

modify_gentoo_configuration_files_requierd_by_package() {
    local packages=$@

    run_remote CONFIG_PROTECT_MASK="/etc/portage" emerge $(emerge_quiet) --autounmask-write --oneshot $packages
}

print_packages_names() {
    local packages=$@
    local i
    
    for i in $packages
    do
        vinfo "Emerging package: $(color red)$i$(no_color)"
    done
}

install_package_on_gentoo() {
    local packages=$@

    print_packages_names $packages
    modify_gentoo_configuration_files_requierd_by_package $packages
    run_remote emerge $(emerge_quiet) --update --oneshot --buildpkg $packages
}

create_tbz_package() {
    gen_changelog
    copy_sources_to_workdir
    tar_sources
    copy_tbz_package_to_server
    copy_portage_tree_to_server
    change_portage_tree_name_on_the_server
    exit_if_ebuild_dont_exist
    update_ebuild_manifest
    set_local_portage_tree_on_server
    copy_portage_tree_manifests_from_server
    safe_delete_directory_from_tmp $(tmp_dir)
}
