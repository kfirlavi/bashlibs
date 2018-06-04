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

test_load_config() {
    var_is_not_defined    VAR_IN_CONF_FILE
    load_config $(conf_file)
    var_should_be_defined VAR_IN_CONF_FILE

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

test_all_variables_in_config() {
    returns "VAR_IN_CONF_FILE STRING_VAR" \
        "all_variables_in_config $(conf_file)"
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

# load shunit2
source /usr/share/shunit2/shunit2
