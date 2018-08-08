#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include config.sh

conf_file() {
    echo /tmp/conf_file.conf
}

delete_conf_file() {
    rm -f $(conf_file)
}

setUp() {
	VAR_IN_CONF_FILE=

	cat<<-EOF > $(conf_file)
	# just a comment
	VAR_IN_CONF_FILE=123
	MULTI_LINE_VAR="first line
	                second line
	                third line"

		  	 STRING_VAR="The variable value is 222" # and a comment

	   # another comment with COMMMENT_VAR=444
	EOF
}

tearDown() {
    delete_conf_file
}

test_config_exist() {
    return_true "config_exist $(conf_file)"
    delete_conf_file
    return_false "config_exist $(conf_file)"
}

test_all_variables_in_config() {
    returns "VAR_IN_CONF_FILE MULTI_LINE_VAR STRING_VAR" \
        "all_variables_in_config $(conf_file)"
}

test_config_value() {
    local VAR1="str1 645"
    returns "str1 645" "config_value VAR1"

    local VAR2="str1
                645"
    returns "str1 645" "config_value VAR1"
}

test_load_config() {
    var_is_not_defined    VAR_IN_CONF_FILE
    var_is_not_defined    MULTI_LINE_VAR
    var_is_not_defined    STRING_VAR

    load_config $(conf_file)

    var_should_be_defined MULTI_LINE_VAR
    var_should_be_defined VAR_IN_CONF_FILE
    var_should_be_defined STRING_VAR

    delete_conf_file
    return_false "load_config $(conf_file)"

}

test_load_config_if_exist() {
    var_is_not_defined    VAR_IN_CONF_FILE
    load_config $(conf_file)
    var_should_be_defined VAR_IN_CONF_FILE

    delete_conf_file
    return_false "load_config_if_exist $(conf_file)"

}

test_var_to_true_function() {
    function_not_defined func_return_true
    var_to_true_function func_return_true
    function_should_be_defined func_return_true
    return_true func_return_true
}

test_var_to_false_function() {
    function_not_defined func_return_false
    var_to_false_function func_return_false
    function_should_be_defined func_return_false
    return_false func_return_false
}

test_var_to_function() {
    function_not_defined return_one
    function_not_defined return_string
    
    var_to_function return_one 1
    var_to_function return_string "just a sting 1234"

    function_should_be_defined return_one
    function_should_be_defined return_string
    returns 1 return_one
    returns "just a sting 1234" return_string
}

test_config_variables_as_functions() {
    function_not_defined var_in_conf_file
    function_not_defined string_var
    function_not_defined comment_var
    load_config $(conf_file)
    function_should_be_defined var_in_conf_file
    function_should_be_defined string_var
    function_not_defined comment_var
    returns 123 "var_in_conf_file"
    returns "The variable value is 222" "string_var"
}

test_verify_config_varialbes_defined() {
    load_config $(conf_file)
    eexit() { echo Error: $@; false; }

    returns "Error: VAR_NOT_DEFINED should be defined in $(conf_file)" \
        "verify_config_varialbes_defined $(conf_file) VAR_NOT_DEFINED"    

    return_false "verify_config_varialbes_defined $(conf_file) VAR_NOT_DEFINED"

    return_true "verify_config_varialbes_defined $(conf_file) VAR_IN_CONF_FILE STRING_VAR MULTI_LINE_VAR"
}

# load shunit2
source /usr/share/shunit2/shunit2
