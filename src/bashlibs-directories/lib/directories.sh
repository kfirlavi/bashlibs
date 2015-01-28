#!/bin/bash

create_dir_if_needed() {
    local dir=$1

    [[ -d $dir ]] \
        || mkdir -p $dir

    readlink -m $dir
}
