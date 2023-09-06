include string.sh

version_regex() {
    echo '[[:digit:]]+.[[:digit:]]+.[[:digit:]]+'
}

replace_version() {
    local new_version=$1; shift
    local str=$@

    echo $str \
        | sed --regexp-extended "s/(.*)$(version_regex)(.*)/\1$new_version\2/"
}

versions_sorted() {
    local versions=$@

    printf '%s\n' $versions \
        | sort -V
}

newest_version() {
    local versions=$@

    versions_sorted $versions \
        | tail -1
}

oldest_version() {
    local versions=$@

    versions_sorted $versions \
        | head -1
}

previous_version() {
    local reference_version=$1
    local versions=$@

    versions_sorted $versions \
        | uniq \
        | sed "/^$reference_version$/Q" \
        | tail -1
}

previous_version_avaliable() {
    local reference_version=$1
    local versions=$@

    [[ -n $(previous_version $reference_version $versions) ]]
}

versions_are_equal() {
    local version=$1
    local reference=$2

    [[ $version == $reference ]]
}

version_less_then() {
    local version=$1
    local reference=$2

    versions_are_equal $version $reference \
        && return false

    [[ $(oldest_version $version $reference) == $version ]]
}

version_greater_then() {
    local version=$1
    local reference=$2

    versions_are_equal $version $reference \
        && return false

    [[ $(oldest_version $version $reference) == $reference ]]
}
