#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh
include checks.sh

oneTimeSetUp() {
    create_workdir
}

oneTimeTearDown() {
    remove_workdir
}

tearDown() {
    rm -f $(workdir)/*
}

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
    local f=$(workdir)/a

    return_false "file_exist $f"
    touch $f
    return_true "file_exist $f"
}

test_file_dont_exist() {
    local f=$(workdir)/a

    return_true "file_dont_exist $f"
    touch $f
    return_false "file_dont_exist $f"
}

test_file_is_empty() {
    local f=$(workdir)/a

    touch $f
    return_true "file_is_empty $f"
    echo "123" > $f
    return_false "file_is_empty $f"
}

test_file_is_empty() {
    local block_device=$(find /dev -type b | head -1)
    local char_device=$(find /dev -type c | head -1)

    return_true "file_is_block_device $block_device"
    return_false "file_is_block_device $char_device"
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

test_function_returns_empty_string() {
    f1() { echo -n; }
    f2() { echo; }
    f3() { echo abc; }

    return_true "function_returns_empty_string f1"
    return_true "function_returns_empty_string f2"
    return_false "function_returns_empty_string f3"
}

test_function_returns_non_empty_string() {
    f1() { echo -n; }
    f2() { echo; }
    f3() { echo abc; }

    return_false "function_returns_non_empty_string f1"
    return_false "function_returns_non_empty_string f2"
    return_true "function_returns_non_empty_string f3"
}

test_function_returns_true() {
    f1() { true; }
    f2() { false; }
    f3() { echo -n; }
    f4() { ls /none/existing/file; }

    return_true "function_returns_true f1"
    return_false "function_returns_true f2"
    return_true "function_returns_true f3"
    return_false "function_returns_true f4"
}

test_function_returns_false() {
    f1() { true; }
    f2() { false; }
    f3() { echo -n; }
    f4() { ls /none/existing/file; }

    return_false "function_returns_false f1"
    return_true "function_returns_false f2"
    return_false "function_returns_false f3"
    return_true "function_returns_false f4"
}

test_im_root() {
    whoami() { echo root;}
    return_true "im_root"

    whoami() { echo user;}
    return_false "im_root"
}

test_is_symbolic_link() {
    touch $(workdir)/a
    ln -sf $(workdir)/a $(workdir)/symlink
    return_true "is_symbolic_link $(workdir)/symlink"
    return_false "is_symbolic_link $(workdir)/a"
}

# load shunit2
source /usr/share/shunit2/shunit2
