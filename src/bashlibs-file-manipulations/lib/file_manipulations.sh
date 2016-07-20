add_line_to_file() {
    local file=$1; shift
    local line=$@

    echo $line >> $file
}

delete_line_from_file() {
    local file=$1; shift
    local line=$@

    sed -i "\|^$line|d" $file
}

line_in_file() {
    local f=$1; shift
    local line=$@

    grep -q "^$line$" $f
}

add_line_to_file_if_not_exist() {
    local f=$1; shift
    local line=$@

    line_in_file $f $line \
        || add_line_to_file $f $line
}
