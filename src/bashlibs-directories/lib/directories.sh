include config.sh

dir_exist() {
    local dir=$1

    [[ -d $dir ]]
}

dir_is_empty() {
    local dir=$1

    [[ -z $(ls --almost-all $dir) ]]
}

create_dir_if_needed() {
    local dir=$1

    [[ -d $dir ]] \
        || mkdir -p $dir

    readlink -m $dir
}

clean_path() {
    local path=$1

    realpath --canonicalize-missing $path
}

top_dir() {
    local dir=$1
    local current_dir=$(clean_path $dir)

    while [[ $current_dir != '/' ]]
    do
        last_dir=$current_dir
        current_dir=$(dirname $current_dir)
    done

    echo $last_dir
}

directory_is_in_tmp() {
    local dir=$(clean_path $1)

    [[ $(top_dir $dir) == '/tmp' ]] \
        && [[ $dir != '/tmp' ]] \
        && [[ $dir != '/tmp/' ]]
}

is_dir_under_base_dir() {
    local dir=$(clean_path $1)
    local base_dir=$(clean_path $2)
    local path_reminder=$(clean_path $dir | sed "s|^$(clean_path $base_dir)||")

    [[ $dir != $base_dir ]] \
        || return

    [[ $path_reminder != '/' ]] \
        || return

    echo $dir \
        | grep -q "^$base_dir"
}

directory_can_be_deleted() {
    local dir=$1

    is_dir_subpath_of_allowd_directories $dir
}

safe_delete_directory_from_tmp() {
    local dir=$1

    if is_dir_under_base_dir $dir /tmp
    then
        if dir_exist $dir
        then
            rm -Rf $dir
            true
        else
            vdebug "$FUNCNAME: dir '$dir' does not exist. No need to delete it." 
            false
        fi
    else
        verror "$FUNCNAME: can't delete '$dir', because it is not in /tmp" 
        false
    fi
}

create_progname_tmp_dir() {
    mktemp -d /tmp/$(progname).XXXXX
}

create_workdir() {
    local d=$(create_progname_tmp_dir)
    
    var_to_function workdir $d
}

remove_workdir() {
    safe_delete_directory_from_tmp $(workdir)
}
