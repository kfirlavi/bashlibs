#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include templates.sh
include directories.sh

oneTimeSetUp() {
    create_workdir
}

oneTimeTearDown() {
    remove_workdir
}

templates_dir() {
    echo __BASHLIBS_PROJECT_TESTS_DIR__/files
}

simple_template() {
    echo $(workdir)/simple
}

setUp() {
    cp \
        $(templates_dir)/simple.template \
        $(simple_template)
}

test_variable_is_in_template() {
    local t=$(simple_template)
    local f=variable_is_in_template

    return_true  "$f $t id"
    return_false "$f $t ID"
    return_true  "$f $t NAME"
    return_false "$f $t name"
}

test_modify_template() {
    modify_template $(simple_template) id 100
    modify_template $(simple_template) NAME my_name

    return_true "grep -q ID=100 $(simple_template)"
    return_true "grep -q NAME=my_name $(simple_template)"
}

# load shunit2
source /usr/share/shunit2/shunit2
