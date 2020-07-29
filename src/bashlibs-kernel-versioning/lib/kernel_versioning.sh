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

kernels_versions_in_boot() {
    local boot_dir=$1

    find $boot_dir \
        -type f \
        -exec file {} \; \
            | grep kernel \
            | cut -d ' ' -f 9 \
            | sort \
            | uniq \
            | cut -d '-' -f 1
}

oldest_kernel() {
    local boot_dir=$1

    oldest_version \
        $(kernels_versions_in_boot $boot_dir)
}

kernel_source_tree_version() {
    local kernel_source_tree=$1
    local m=$kernel_source_tree/Makefile

    local v=$(grep VERSION $m    | head -1 | cut -d ' ' -f 3)
    local p=$(grep PATCHLEVEL $m | head -1 | cut -d ' ' -f 3)
    local s=$(grep SUBLEVEL $m   | head -1 | cut -d ' ' -f 3)

    echo $v.$p.$s
}
