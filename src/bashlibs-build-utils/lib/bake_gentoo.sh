make_conf() {
    echo /etc/portage/make.conf
}

emerge_quiet() {
    [[ -n $QUIET ]] \
        && echo '--quiet'
}

emerge_cmd() {
    echo emerge $(emerge_quiet) --oneshot --buildpkg=y
}

emerge_bin_pkg(){
    echo $(emerge_cmd) -GK
}

local_distfiles_directory() {
    create_dir_if_needed $(repositories_dir)/gentoo/distfiles
}

target_distdir() {
    run_remote grep DISTDIR $(make_conf) \
        | tail -1 \
        | cut -d '"' -f 2
}

target_pkgdir() {
    run_remote grep PKGDIR $(make_conf) \
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

copy_portage_tree_to_host() {
    local host=$1

    rsync -r --delete \
        $(portage_tree)/ \
        root@$host:$(gentoo_local_portage_path)
}

reponame() {
    cat $(portage_tree)/profiles/repo_name
}

change_portage_tree_name_on_host() {
    local host=$1
    local f=/tmp/repo_name

    echo Local $(reponame) > $f
    rsync -aq $f \
        root@$host:$(gentoo_local_portage_path)/profiles/
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

set_local_portage_tree_on_host() {
    local host=$1

    portage_overlay_line_already_defined \
        || run_on_host $host "echo '$(portage_overlay_line)' >> /etc/portage/make.conf"
}

modify_gentoo_configuration_files_requierd_by_package() {
    local host=$1; shift
    local packages=$@

    run_on_host $host CONFIG_PROTECT_MASK="/etc/portage" emerge --oneshot --autounmask-write $packages
}

print_host() {
    local host=$1

    echo -e "$(color red)$host$(no_color)"
}

print_packages_names() {
    local packages=$@
    local i
    
    for i in $packages
    do
        vinfo "Emerging package: $(color purple)$i$(no_color)"
    done
}

install_package_on_gentoo() {
    local host=$1; shift
    local packages=$@

    vinfo "building packages on $(print_host $host)"
    print_packages_names $packages
    modify_gentoo_configuration_files_requierd_by_package $host $packages
    run_on_host $host $(emerge_cmd) $packages
    copy_bin_pkg_from_server $host
    quick_install_on_other_gentoo_hosts $packages
}

copy_bin_pkg_from_server() {
    local host=$1

    rsync -aR \
        root@$host:$(target_pkgdir) \
        $(tmp_dir)
}

copy_bin_pkg_to_host() {
    local host=$1

    rsync -a \
        $(tmp_dir)/$(target_pkgdir) \
        root@$host:$(dirname $(target_pkgdir))
}

quick_install_on_other_gentoo_hosts() {
    local packages=$@
    local host

    for host in $HOSTS_TO_INSTALL_BIN_PACKAGES
    do
        vinfo "quick install on host $(print_host $host) the packages: $packages"
        copy_portage_tree_to_host $host
        change_portage_tree_name_on_host $host
        copy_bin_pkg_to_host $host
        set_local_portage_tree_on_host $host
        modify_gentoo_configuration_files_requierd_by_package $host $packages
        run_on_host $host $(emerge_bin_pkg) -q $packages
    done
}

create_tbz_package() {
    gen_changelog
    copy_sources_to_workdir
    tar_sources
    copy_tbz_package_to_server
    copy_portage_tree_to_host $(target_build_host)
    change_portage_tree_name_on_host $(target_build_host)
    exit_if_ebuild_dont_exist
    update_ebuild_manifest
    set_local_portage_tree_on_host $(target_build_host)
    copy_portage_tree_manifests_from_server
    safe_delete_directory_from_tmp $(tmp_dir)
}
