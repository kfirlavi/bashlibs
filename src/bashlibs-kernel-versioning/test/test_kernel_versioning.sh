#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh
include config.sh
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
    var_to_function makefile $(mock_kernel_tree_dir)/Makefile
    kernel_source_top_makefile > $(makefile)
}

oneTimeSetUp() {
    create_mocked_kernel_tree
}

oneTimeTearDown() {
    safe_delete_directory_from_tmp $(mock_kernel_tree_dir)
}

test_kernel_makefile_variable_value() {
    returns 5  "kernel_makefile_variable_value VERSION $(makefile)"
    returns 4  "kernel_makefile_variable_value PATCHLEVEL $(makefile)"
    returns 10 "kernel_makefile_variable_value SUBLEVEL $(makefile)"
    returns '-gentoo' "kernel_makefile_variable_value EXTRAVERSION $(makefile)"
}

test_kernel_major_version() {
    returns 5 "kernel_major_version $(makefile)"
}

test_kernel_patchlevel_version() {
    returns 4 "kernel_patchlevel_version $(makefile)"
}

test_kernel_sublevel_version() {
    returns 10 "kernel_sublevel_version $(makefile)"
}

test_kernel_version_from_makefile() {
    returns 5.4.10 \
        "kernel_version_from_makefile $(makefile)"
}

test_kernel_source_tree_version() {
    returns 5.4.10 \
        "kernel_source_tree_version $(mock_kernel_tree_dir)"
}

# load shunit2
source /usr/share/shunit2/shunit2
