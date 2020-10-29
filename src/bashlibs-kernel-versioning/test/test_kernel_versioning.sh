#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh
include kernel_versioning.sh

mock_kernel_tree_dir() {
    echo /tmp/mock_kernel_tree
}

kernel_source_top_makefile() {
	cat<<-EOF
	# SPDX-License-Identifier: GPL-2.0
	VERSION = 5
	PATCHLEVEL = 4
	SUBLEVEL = 10
	EXTRAVERSION = -gentoo
	NAME = Kleptomaniac Octopus
	EOF
}

create_mocked_kernel_tree() {
    mkdir -p $(mock_kernel_tree_dir)
    kernel_source_top_makefile > $(mock_kernel_tree_dir)/Makefile
}

oneTimeSetUp() {
    create_mocked_kernel_tree
}

oneTimeTearDown() {
    safe_delete_directory_from_tmp $(mock_kernel_tree_dir)
}

test_kernel_source_tree_version() {
    returns 5.4.10 \
        "kernel_source_tree_version $(mock_kernel_tree_dir)"
}

# load shunit2
source /usr/share/shunit2/shunit2
