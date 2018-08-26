#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_gentoo.sh

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
        "package_names_with_portage_repository $packages"
}

test_find_ebuild_for_package() {
    local tmpdir=$(mktemp -d)
    
    mkdir -p $tmpdir/sys-app
    mkdir -p $tmpdir/games

    portage_tree() { echo $tmpdir; }
    touch $tmpdir/sys-app/release-0.0.1.ebuild
    touch $tmpdir/games/my-release-0.0.1.ebuild
    touch $tmpdir/games/my-release-0.0.1.txt
    app_version() { echo 0.0.1; }

    cmake_project_name() { echo release; }
    returns "$tmpdir/sys-app/release-0.0.1.ebuild" \
        "find_ebuild_for_package"

    cmake_project_name() { echo my-release; }
    returns "$tmpdir/games/my-release-0.0.1.ebuild" \
        "find_ebuild_for_package"
}

# load shunit2
source /usr/share/shunit2/shunit2
