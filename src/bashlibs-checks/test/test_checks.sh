#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include checks.sh

test_function_defined() {
    function_not_defined my_func

    my_func() { echo; }
    my_func2() { echo; }

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

test_file_is_empty() {
    local f=/tmp/a

    touch $f
    return_true "file_is_empty $f"
    echo "123" > $f
    return_false "file_is_empty $f"

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

test_functions_not_defined() {
    returns_empty "functions_not_defined"
    returns_empty "functions_not_defined my_func my_func2"

    returns "func_not_defined" \
        "functions_not_defined my_func my_func2 func_not_defined"

    returns "func_not_defined" \
        "functions_not_defined my_func func_not_defined my_func2"
}

test_eexit_if_functions_not_defined() {
    eexit() { echo $@; }
    return_true "eexit_if_functions_not_defined my_func my_func2"

    returns "This functions must be defined: $(color red)func_not_defined$(no_color)" \
         "eexit_if_functions_not_defined my_func func_not_defined my_func2"
}

# load shunit2
source /usr/share/shunit2/shunit2
