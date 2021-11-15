#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include usage.sh

verbose_should_equal_to() {
    local value=$1

    value_should_be VERBOSE $value
}

test_current_verbose_level() {
    set_verbose_level_to_info
    returns 2 current_verbose_level

    set_verbose_level_to_debug
    returns 3 current_verbose_level
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

test_set_verbose_level_to_error() {
    local VERBOSE=4

    set_verbose_level_to_error
    verbose_should_equal_to 0
}

test_set_verbose_level_to_warning() {
    local VERBOSE=4

    set_verbose_level_to_warning
    verbose_should_equal_to 1
}

test_set_verbose_level_to_info() {
    local VERBOSE=4

    set_verbose_level_to_info
    verbose_should_equal_to 2
}

test_set_verbose_level_to_debug() {
    local VERBOSE=4

    set_verbose_level_to_debug
    verbose_should_equal_to 3
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

test_is_verbose_level_set_to_error() {
    set_verbose_level_to_info
    return_false is_verbose_level_set_to_error

    set_verbose_level_to_error
    return_true is_verbose_level_set_to_error
}

test_is_verbose_level_set_to_warning() {
    set_verbose_level_to_info
    return_false is_verbose_level_set_to_warning

    set_verbose_level_to_warning
    return_true is_verbose_level_set_to_warning
}

test_is_verbose_level_set_to_info() {
    set_verbose_level_to_debug
    return_false is_verbose_level_set_to_info

    set_verbose_level_to_info
    return_true is_verbose_level_set_to_info
}

test_is_verbose_level_set_to_debug() {
    set_verbose_level_to_info
    return_false is_verbose_level_set_to_debug

    set_verbose_level_to_debug
    return_true is_verbose_level_set_to_debug
}

test_is_verbose_level_is_error_or_above() {
    set_verbose_level_to_error
    return_true is_verbose_level_is_error_or_above

    set_verbose_level_to_warning
    return_true is_verbose_level_is_error_or_above

    set_verbose_level_to_info
    return_true is_verbose_level_is_error_or_above

    set_verbose_level_to_debug
    return_true is_verbose_level_is_error_or_above
}

test_is_verbose_level_is_warning_or_above() {
    set_verbose_level_to_error
    return_false is_verbose_level_is_warning_or_above

    set_verbose_level_to_warning
    return_true is_verbose_level_is_warning_or_above

    set_verbose_level_to_info
    return_true is_verbose_level_is_warning_or_above

    set_verbose_level_to_debug
    return_true is_verbose_level_is_warning_or_above
}

test_is_verbose_level_is_info_or_above() {
    set_verbose_level_to_error
    return_false is_verbose_level_is_info_or_above

    set_verbose_level_to_warning
    return_false is_verbose_level_is_info_or_above

    set_verbose_level_to_info
    return_true is_verbose_level_is_info_or_above

    set_verbose_level_to_debug
    return_true is_verbose_level_is_info_or_above
}

test_is_verbose_level_is_debug_or_above() {
    set_verbose_level_to_error
    return_false is_verbose_level_is_debug_or_above

    set_verbose_level_to_warning
    return_false is_verbose_level_is_debug_or_above

    set_verbose_level_to_info
    return_false is_verbose_level_is_debug_or_above

    set_verbose_level_to_debug
    return_true is_verbose_level_is_debug_or_above
}

# load shunit2
source /usr/share/shunit2/shunit2
