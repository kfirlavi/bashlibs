config_file_name() {
    echo .bakerc
}

config_file_exist() {
    local conf_file=$1

    [[ -f $conf_file ]]
}

load_config_file() {
    local conf_file=$1

    config_file_exist $conf_file \
        || vinfo "Config file '$conf_file' not found"

    config_file_exist $conf_file \
        && vinfo "Loading configuration file: '$conf_file'" \
        && eval $(cat $conf_file)
}

set_top_level_path() {
    local path=$1

    _TOP_LEVEL_PATH=$path
}

top_level_path() {
    echo $_TOP_LEVEL_PATH
}

load_configuration_files() {
    local path=$(realpath $(project_path))

    while [[ -z $TOP_RC && $path != '/' ]] 
    do
        load_config_file $path/$(config_file_name)
        set_top_level_path $path
        path=$(realpath $path/..)
    done
}
