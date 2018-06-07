#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include checks.sh

test_function_defined() {
    function_not_defined my_func

    my_func() { echo; }

    function_should_be_defined my_func
}

test_function_not_defined() {
    local variable

    return_true "function_not_defined variable"
    return_true "function_not_defined non_exist_name"

    my_func() { echo; }

    return_false "function_not_defined my_func"
}

# load shunit2
source /usr/share/shunit2/shunit2
