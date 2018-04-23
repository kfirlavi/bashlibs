#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include user.sh

test_runnin_as_root() {
    current_user() { echo user1; }
    return_false "runnin_as_root"

    current_user() { echo root; }
    return_true "runnin_as_root"
}

# load shunit2
source /usr/share/shunit2/shunit2
