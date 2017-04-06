config_exist() {
    local conf_file=$1

    [[ -f $conf_file ]]
}

load_config_if_exist() {
    local conf_file=$1

    config_exist $conf_file \
        && source $conf_file
}

load_config() {
    local conf_file=$1

    load_config_if_exist $conf_file \
        || eexit "$conf_file does not exist"
}
