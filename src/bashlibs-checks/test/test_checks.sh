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

# load shunit2
source /usr/share/shunit2/shunit2
