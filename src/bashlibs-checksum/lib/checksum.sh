create_md5() {
    local filename=$1
    local name=$(basename $filename)
    local dir=$(dirname $filename)

    cd $dir
    md5sum $name > $name.md5
    cd - > /dev/null 2>&1
}

create_md5_for_all_files_in_directory() {
    local dir=$1

    local i
    for i in $(find $dir -maxdepth 1 -type f)
    do
        create_md5 $i
    done
}
