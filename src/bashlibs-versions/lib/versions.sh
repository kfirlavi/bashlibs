version_regex() {
    echo '[[:digit:]]+.[[:digit:]]+.[[:digit:]]+'
}

replace_version() {
    local new_version=$1; shift
    local str=$@

    echo $str \
        | sed --regexp-extended "s/(.*)$(version_regex)(.*)/\1$new_version\2/"
}
