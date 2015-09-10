config_file_name() {
    echo .bakerc
}

config_file_exist() {
    local path=$1
    local conf_file=$path/$(config_file_name)

    [[ -f $conf_file ]]
}

load_config_file() {
    local path=$1
    local conf_file=$path/$(config_file_name)

    config_file_exist $path \
        || vinfo "Config file '$conf_file' not found"

    config_file_exist $path \
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
    local path=$1

    while [[ -z $TOP_RC && $path != '/' ]] 
    do
        load_config_file $path
        path=$(realpath $path/..)
    done
}

is_top_level_path() {
    local path=$1
    local rc=$path/$(config_file_name)

    [[ -f $rc ]] \
        || return

    grep -q 'TOP_RC=1' \
        $rc
}

find_root_sources_path() {
    local path=$(realpath $1)

    [[ $path == '/' ]] \
        && return

    if is_top_level_path $path
    then
        echo $path
    else
        find_root_sources_path $path/..
    fi
}
