#!/bin/bash
export readonly PROGNAME=$(basename $0)
export readonly PROGDIR=$(readlink -m $(dirname $0))
export readonly SKELATON_DIR=$PROGDIR/../skelaton
export readonly BASH_LIBS_DIR=$PROGDIR/../..
export readonly ARGS="$@"

project_name() {
    local name=$1

    echo $name \
        | sed 's/_/-/g'
}

lib_file_name() {
    local name=$1

    echo $name \
        | sed 's/-/_/g'
}

project_dir() {
    echo $BASH_LIBS_DIR/$(project_name $library_name)
}

cp_skelaton() {
    local library_name=$1

    rsync -av \
        $SKELATON_DIR/ \
        $(project_dir)
}

create_libfile() {
    local library_name=$1
    local lib_dir=$(project_dir)/lib

    mv \
        $lib_dir/project_name.sh \
        $lib_dir/$(lib_file_name $library_name).sh
}

create_testfile() {
    local library_name=$1
    local test_dir=$(project_dir)/test
    local src=$test_dir/test_project_name.sh
    local dst=$test_dir/test_$(lib_file_name $library_name).sh

    mv $src $dst

    sed -i \
        "s/project_name/$(lib_file_name $library_name)/g" \
        $dst
}

modify_cmake() {
    local library_name=$1

    sed -i \
        "s/project-name/$(project_name $library_name)/g" \
        $(project_dir)/CMakeLists.txt
}

create_new_bash_library_project() {
    local library_name=$1

    cp_skelaton $library_name
    create_libfile $library_name
    create_testfile $library_name
    modify_cmake $library_name
}

main() {
    local new_bash_libs=$ARGS
    local i

    for i in $new_bash_libs
    do
        create_new_bash_library_project $i
    done
}
main
