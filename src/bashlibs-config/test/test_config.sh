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
	VAR_IN_CONF_FILE=123
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

# load shunit2
source /usr/share/shunit2/shunit2
