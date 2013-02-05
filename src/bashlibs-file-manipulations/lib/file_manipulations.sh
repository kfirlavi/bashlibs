add_line_to_file() {
    local file=$1; shift
    local line=$@

    echo $line >> $file
}

delete_line_from_file() {
    local file=$1; shift
    local line=$@

    sed -i "/^$line/d" $file
}
