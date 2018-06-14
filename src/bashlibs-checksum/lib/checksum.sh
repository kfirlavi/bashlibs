create_md5() {
    local filename=$1
    local name=$(basename $filename)
    local dir=$(dirname $filename)

    cd $dir
    md5sum $name > $name.md5
    cd - > /dev/null 2>&1
}
