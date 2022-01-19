#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include cmdline.sh

args() {
    echo '--before --test-one -n -p -- this is extra args --one --two-three -a -b -c'
}

test_args_without_extra_args() {
    returns '--before --test-one -n -p' \
        "args_without_extra_args"
}

test_extra_args() {
    returns 'this is extra args --one --two-three -a -b -c' \
        "extra_args"
}

# load shunit2
source /usr/share/shunit2/shunit2
