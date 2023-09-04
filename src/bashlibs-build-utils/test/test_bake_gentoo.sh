#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_gentoo.sh
include string.sh

oneTimeSetUp() {
    reponame() { echo my_repo ; }
}

test_portage_tree_name_on_host() {
    returns "bake-local-my_repo" \
        "portage_tree_name_on_host dev-libs/abc"
}

test_add_portage_repository_to_package_name() {
    returns "dev-libs/abc::bake-local-my_repo" \
        "add_portage_repository_to_package_name dev-libs/abc"
}

test_package_names_with_portage_repository() {
    local packages="dev-libs/abc sys-apps/pack2"

    returns "dev-libs/abc::bake-local-my_repo sys-apps/pack2::bake-local-my_repo" \
        "package_names_with_portage_repository $packages | multiline_to_single_line"
}

test_find_ebuild_for_package() {
    local tmpdir=$(mktemp -d)
    local portage_tree=$tmpdir/portage

    mkdir -p $portage_tree/{sys-app,games,sys-fs}

    touch $portage_tree/sys-app/release-0.0.1.ebuild
    touch $portage_tree/games/my-release-0.0.1.ebuild
    touch $portage_tree/games/my-release-0.0.1.txt
    touch $portage_tree/sys-fs/newfs-0.2.3.ebuild

    cd $tmpdir
    returns "portage/sys-app/release-0.0.1.ebuild" \
        "find_ebuild_for_package release 0.0.1 $portage_tree"

    returns "portage/games/my-release-0.0.1.ebuild" \
        "find_ebuild_for_package my-release 0.0.1 $portage_tree"

    returns "portage/sys-fs/newfs-0.2.3.ebuild" \
        "find_ebuild_for_package newfs 0.2.3 $portage_tree"

    mkdir -p $tmpdir/relative
    cd $tmpdir/relative
    returns "../portage/sys-fs/newfs-0.2.3.ebuild" \
        "find_ebuild_for_package newfs 0.2.3 $portage_tree"
}

# load shunit2
source /usr/share/shunit2/shunit2
