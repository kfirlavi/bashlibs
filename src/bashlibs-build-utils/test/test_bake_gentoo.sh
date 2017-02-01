#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_gentoo.sh

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
