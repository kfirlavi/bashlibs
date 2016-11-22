load_config() {
    local conf_file=$1

    [[ -f $conf_file ]] \
        || eexit "$conf_file does not exist"

    source $conf_file
}
