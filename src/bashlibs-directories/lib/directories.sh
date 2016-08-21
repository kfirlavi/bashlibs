#!/bin/bash

dir_exist() {
    local dir=$1

    [[ -d $dir ]]
}

create_dir_if_needed() {
    local dir=$1

    [[ -d $dir ]] \
        || mkdir -p $dir

    readlink -m $dir
}

clean_path() {
    local path=$1

    echo $path \
        | sed 's|/\+|/|g' \
        | sed 's|/$||'
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

safe_delete_directory_from_tmp() {
    local dir=$1

    if directory_is_in_tmp $dir
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
