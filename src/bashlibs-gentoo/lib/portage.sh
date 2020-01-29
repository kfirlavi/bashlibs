include config.sh

emerge_info() {
    emerge --info 2>&1
}

emerge_info_vars() {
    emerge_info \
        | grep '="'
}

emerge_info_var_line() {
    local var_name=$1

    emerge_info_vars \
        | grep "^$var_name="
}

emerge_info_var_value() {
    local var_name=$1

    emerge_info_var_line $var_name \
        | cut -d '"' -f 2    
}

emerge_info_vars_to_functions() {
    local tmp_file=$(mktemp)

    emerge_info_vars > $tmp_file
    load_config $tmp_file emerge_env_
    
    rm -f $tmp_file
}
