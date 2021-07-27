#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include checksum.sh
include directories.sh

tempfile() {
    echo $(workdir)/bashlibs_checksum_test_tmpfile
}

setUp() {
    create_workdir
    echo -n > $(tempfile)
    echo 1 > $(workdir)/a
    echo 2 > $(workdir)/b
}

tearDown() {
    remove_workdir
}

test_create_md5() {
    echo "just a string" > $(tempfile)
    create_md5 $(tempfile)
    file_should_exist $(tempfile).md5

    returns \
        "700ee18e43340071b8576a69e3ada352  $(basename $(tempfile))" \
        "cat $(tempfile).md5"
}

test_create_md5_for_all_files_in_directory() {
    create_md5_for_all_files_in_directory $(workdir)
    file_should_exist $(workdir)/a.md5
    file_should_exist $(workdir)/b.md5
    
    returns \
        "b026324c6904b2a9cb4b88d6d61c81d1  a" \
        "cat $(workdir)/a.md5"

    returns \
        "26ab0db90d72e28ad0ba1e22ee510510  b" \
        "cat $(workdir)/b.md5"
}

# load shunit2
source /usr/share/shunit2/shunit2
