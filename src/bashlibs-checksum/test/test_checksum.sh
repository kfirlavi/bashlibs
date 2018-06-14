#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include checksum.sh

tempfile() {
    echo /tmp/bashlibs_checksum_test_tmpfile
}

setUp() {
    echo -n > $(tempfile)
}

tearDown() {
    rm -f $(tempfile)
}

test_create_md5() {
    echo "just a string" > $(tempfile)
    create_md5 $(tempfile)
    file_should_exist $(tempfile).md5

    returns \
        "700ee18e43340071b8576a69e3ada352  $(basename $(tempfile))" \
        "cat $(tempfile).md5"

    rm -f $(tempfile).md5
}

# load shunit2
source /usr/share/shunit2/shunit2
