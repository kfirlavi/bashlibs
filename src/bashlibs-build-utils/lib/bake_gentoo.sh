include bake_test.sh
include ssh.sh

emerge_quiet() {
    [[ -n $QUIET ]] \
        && echo '--quiet'
}

emerge_base_cmd() {
    echo emerge $(emerge_quiet) --autounmask-write --oneshot --color=y
}

emerge_build_package() {
    echo $(emerge_base_cmd) --buildpkg=y
}

emerge_install_binary_package(){
    echo $(emerge_base_cmd) --quiet --usepkg=y
}

add_portage_repository_to_package_name() {
    local pacakge_name=$1

    echo $pacakge_name::$(portage_tree_name_on_host)
}

package_names_with_portage_repository() {
    local packages=$@

    local i
    for i in $packages
    do
        add_portage_repository_to_package_name $i
    done
}

local_distfiles_directory() {
    create_dir_if_needed \
        $(repositories_dir)/gentoo/distfiles/$PORTAGE_TREE_NAME/distfiles
}

get_emerge_info() {
    local host=$1
    EMERGE_INFO=$(run_remote emerge --info)

    emerge_info() {
        echo $EMERGE_INFO
    }
}

emerge_variable() {
    local var_name=$1

    emerge_info \
        | grep -o "$var_name=.*" \
        | cut -d '"' -f 2
}

get_emerge_variables() {
    local host=$1

    get_emerge_info $host

    target_distdir() { emerge_variable DISTDIR; }
    vdebug "$(print_host $host) distfiles dir: $(target_distdir)"

    target_pkgdir()  { emerge_variable PKGDIR;  }
    vdebug "$(print_host $host) pkg dir: $(target_pkgdir)"
}

copy_tbz_package_to_host() {
    local host=$1

    rsync \
        --rsync-path="mkdir -p $(target_distdir) && rsync" \
        $(local_distfiles_directory)/$(tbz_filename) \
        root@$host:$(target_distdir)/
}

copy_portage_tree_to_host() {
    local host=$1

    rsync -r --delete \
        --rsync-path="mkdir -p $(gentoo_local_portage_path) && rsync" \
        $(portage_tree)/ \
        root@$host:$(gentoo_local_portage_path)
}

reponame() {
    cat $(portage_tree)/profiles/repo_name
}

portage_tree_name_on_host() {
    echo bake-local-$(reponame)
}

change_portage_tree_name_on_host() {
    local host=$1

    run_on_host root $host \
        "echo $(portage_tree_name_on_host) > $(gentoo_local_portage_path)/profiles/repo_name"
}

copy_portage_tree_manifests_from_host() {
    local host=$1

    rsync -r \
        --include="*/" \
        --include=Manifest \
        --exclude="*" \
        root@$host:$(gentoo_local_portage_path)/ \
        $(portage_tree)
}

find_ebuild_for_package() {
    local project_name=$1
    local version=$2
    local portage_tree=$3
    local current_path=$(pwd)

    find $portage_tree \
        -path "*/${project_name}-${version}.ebuild" \
        -exec realpath --relative-to $current_path {} \;
}

package_category() {
    find_ebuild_for_package \
        $(cmake_project_name) \
        $(app_version) \
        $(portage_tree) \
        | rev \
        | cut -d '/' -f 3 \
        | rev
}

package_name_with_version() {
    find_ebuild_for_package \
        $(cmake_project_name) \
        $(app_version) \
        $(portage_tree) \
        | rev \
        | cut -d '/' -f 1 \
        | cut -d '.' -f 2- \
        | rev
}

package_full_name_with_version() {
    echo $(package_category)/$(package_name_with_version)
}

ebuild_exist() {
    [[ -n $(find_ebuild_for_package $(cmake_project_name) $(app_version) $(portage_tree)) ]]
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
    local host=$1

    run_on_host root $host "rm $(remote_ebuild_category_path)/Manifest"
}

update_ebuild_manifest() {
    local host=$1

    remote_delete_manifest_file $host
    run_on_host root $host "ebuild $(remote_ebuild_path) manifest"
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
        || run_on_host root $host "echo '$(portage_overlay_line)' >> /etc/portage/make.conf"
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

portage_configurations_have_changed() {
    local host=$1

    run_on_host $host \
        find /etc/portage/ -name '._cfg*' \
        | grep -q _cfg
}

update_portage_configurations() {
    local host=$1

    run_on_host root $host \
        etc-update --automode -5 /etc/portage
}

install_package_on_gentoo() {
    local host=$1; shift
    local packages=$(package_names_with_portage_repository $@)

    vinfo "building packages on $(print_host $host)"
    print_packages_names $packages
    run_on_host_with_tty root $host $(emerge_build_package) $packages
    run_tests_of_package
    portage_configurations_have_changed $host \
        && update_portage_configurations $host \
        && run_on_host_with_tty root $host $(emerge_build_package) $packages
    copy_bin_pkg_from_server $host
    quick_install_on_other_gentoo_hosts $packages
    safe_delete_directory_from_tmp $(tmp_dir)
}

copy_bin_pkg_from_server() {
    local host=$1

    rsync -aR \
        root@$host:$(dirname $(target_pkgdir)) \
        $(tmp_dir)
}

copy_bin_pkg_to_host() {
    local host=$1

    rsync -a \
        $(tmp_dir)/$(dirname $(target_pkgdir))/ \
        root@$host:$(dirname $(target_pkgdir))
}

quick_install_on_other_gentoo_hosts() {
    local packages=$(package_names_with_portage_repository $@)
    local host

    for host in $HOSTS_TO_INSTALL_BIN_PACKAGES
    do
        vinfo "quick install on host $(print_host $host) the packages: $packages"
        copy_portage_tree_to_host $host
        change_portage_tree_name_on_host $host
        copy_bin_pkg_to_host $host
        set_local_portage_tree_on_host $host
        run_on_host root $host $(emerge_install_binary_package) $packages
        portage_configurations_have_changed $host \
            && update_portage_configurations $host \
            && run_on_host root $host $(emerge_install_binary_package) $packages
    done
}

create_tbz_package() {
    local host=$1

    exit_if_ebuild_dont_exist
    gen_changelog
    copy_sources_to_workdir
    tar_sources
    get_emerge_variables $host
    copy_tbz_package_to_host $host
    copy_portage_tree_to_host $host
    change_portage_tree_name_on_host $host
    update_ebuild_manifest $host
    set_local_portage_tree_on_host $host
    copy_portage_tree_manifests_from_host $host
    safe_delete_directory_from_tmp $(tmp_dir)
}

gentoo_ebuilds() {
    find $(portage_tree) \
        -name '*.ebuild'
}

gentoo_ebuilds_project_names() {
    local i

    for i in $(gentoo_ebuilds)
    do
        basename $(dirname $i)
    done
}

gentoo_projects() {
    comm -12 \
        <(gentoo_ebuilds_project_names | sort | uniq) \
        <(all_cmake_project_names $(top_level_path) | sort | uniq)
}

eapi_exist() {
    local ebuild=$1

    grep -q '^EAPI=' $ebuild
}

show_warning_if_no_eapi_defined() {
    local ebuild=$1

    eapi_exist $ebuild \
        || vwarning "eapi is not defined in ebuild: $ebuild"
}

current_eapi() {
    local ebuild=$1

    eval $(grep '^EAPI=' $ebuild)

    echo $EAPI
}

set_eapi() {
    local ebuild=$1
    local eapi=$2

    sed -i \
        "s/^EAPI=.*/EAPI=$eapi/" \
        $ebuild
}

set_gentoo_ebuild_eapi_if_needed() {
    ebuild_exist \
        || return

    eapi_up || eapi_down \
        || return

    local ebuild=$(find_ebuild_for_package $(cmake_project_name) $(app_version) $(portage_tree))

    show_warning_if_no_eapi_defined $ebuild
    local eapi=$(current_eapi $ebuild)

    eapi_up \
        && (( eapi++ ))

    eapi_down \
        && (( eapi-- ))

    vinfo "set ebuild $ebuild to $(color white)EAPI=$eapi$(no_color)"
    set_eapi $ebuild $eapi
}
