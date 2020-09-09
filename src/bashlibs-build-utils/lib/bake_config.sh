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
        || vdebug "Config file '$conf_file' not found"

    config_file_exist $path \
        && vdebug "Loading configuration file: '$conf_file'" \
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
    local path=${1:-$(pwd)}
    TOP_RC=

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

sources_root_path() {
    local path=${1:-$SOURCES_TREE_PATH}
    path=$(realpath $path)

    [[ $path == '/' ]] \
        && return

    if is_top_level_path $path
    then
        echo $path
    else
        sources_root_path $path/..
    fi
}

path_is_in_source_tree() {
    local path=$1

    [[ -n $(sources_root_path $path) ]]
}

exit_if_path_is_not_in_source_tree() {
    local path=$1

    path_is_in_source_tree $path \
        || eexit "$(color white)$(realpath $path)$(no_color) is not in a source tree! Use option --root or run $(progname) from sources tree."
}
