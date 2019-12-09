#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_cmdline.sh

test_project_names_to_bake_commandline() {
    returns "-p proj1 " \
        "project_names_to_bake_commandline proj1"

    returns "-p proj1 -p proj2 " \
        "project_names_to_bake_commandline proj1 proj2"
}

# load shunit2
source /usr/share/shunit2/shunit2
