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

test_versions_sorted() {
    returns "1.6 1.9 2.3 4.5 7.3 8.9" \
        "versions_sorted 1.9 2.3 4.5 7.3 1.6 8.9"
    returns "3.4.14 3.18.5" \
        "versions_sorted 3.4.14 3.18.5"
    returns "4.4.25 4.4.38 5.18.5" \
        "versions_sorted 4.4.25 5.18.5 4.4.38"
}

test_oldest_version() {
    returns 1.6 "oldest_version 1.9 2.3 4.5 7.3 1.6 8.9"
    returns 3.4.14 "oldest_version 3.4.14 3.18.5"
    returns 4.4.25 "oldest_version 4.4.25 5.18.5 4.4.38"
}

test_newest_version() {
    returns 8.9 "newest_version 1.9 2.3 4.5 7.3 1.6 8.9"
    returns 3.18.5 "newest_version 3.4.14 3.18.5"
    returns 5.18.5 "newest_version 4.4.25 5.18.5 4.4.38"
}

test_versions_are_equal() {
    return_true "versions_are_equal 4.3.7 4.3.7"
    return_false "versions_are_equal 4.3.4 4.3.7"
}

test_version_less_then() {
    return_true "version_less_then 3.4.55 4.3.7"
    return_true "version_less_then 3.4 4.3"
    return_false "version_less_then 4.4 4.3"
    return_false "version_less_then 4.3.7 3.4.55"
    return_false "version_less_then 4.3.7 4.3.7"
}

test_version_greater_then() {
    return_true "version_greater_then 4.3.7 3.4.55"
    return_true "version_greater_then 4.3 3.4"
    return_false "version_greater_then 4.3 4.4"
    return_false "version_greater_then 3.4.55 4.3.7"
    return_false "version_greater_then 4.3.7 4.3.7"
}

test_kernel_source_tree_version() {
    returns 5.4.10 \
        "kernel_source_tree_version $(mock_kernel_tree_dir)"
}

# load shunit2
source /usr/share/shunit2/shunit2
