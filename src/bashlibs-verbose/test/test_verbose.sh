#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include usage.sh

verbose_should_equal_to() {
    local value=$1

    value_should_be VERBOSE $value
}

test_increase_verbose_level() {
    local VERBOSE=0

    increase_verbose_level
    verbose_should_equal_to 1

    increase_verbose_level
    verbose_should_equal_to 2
}

test_decrease_verbose_level() {
    local VERBOSE=3

    decrease_verbose_level
    verbose_should_equal_to 2

    decrease_verbose_level
    verbose_should_equal_to 1

    decrease_verbose_level
    verbose_should_equal_to 0

    decrease_verbose_level
    verbose_should_equal_to 0
}

test_set_verbose_level_to_info() {
    local VERBOSE=4

    set_verbose_level_to_info
    verbose_should_equal_to 1
}

test_set_verbose_level_to_debug() {
    local VERBOSE=4

    set_verbose_level_to_debug
    verbose_should_equal_to 2
}

test_no_verbose() {
    local VERBOSE=3

    no_verbose
    verbose_should_equal_to 0

    no_verbose
    verbose_should_equal_to 0
}

test_set_quiet_mode() {
    local VERBOSE=3

    set_quiet_mode
    verbose_should_equal_to 0
    value_should_be QUIET 1
}

test_is_quiet_mode_on() {
    local QUIET=0

    return_false "is_quiet_mode_on"
    set_quiet_mode
    return_true "is_quiet_mode_on"
}

# load shunit2
source /usr/share/shunit2/shunit2
