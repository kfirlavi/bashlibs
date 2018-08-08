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

test_file_exist() {
    local f=/tmp/a

    return_false "file_exist $f"
    touch $f
    return_true "file_exist $f"

    rm -f $f
}

test_file_dont_exist() {
    local f=/tmp/a

    return_true "file_dont_exist $f"
    touch $f
    return_false "file_dont_exist $f"

    rm -f $f
}

test_variable_defined() {
    return_false "variable_defined non_defined"
    
    local just_local
    return_false "variable_defined just_local"

    local empty_string=""
    return_true "variable_defined empty_string"

    local non_empty=1
    return_true "variable_defined non_empty"
}

test_variable_not_defined() {
    return_true "variable_not_defined non_defined"
    
    local just_local
    return_true "variable_not_defined just_local"

    local empty_string=""
    return_false "variable_not_defined empty_string"

    local non_empty=1
    return_false "variable_not_defined non_empty"
}

# load shunit2
source /usr/share/shunit2/shunit2
