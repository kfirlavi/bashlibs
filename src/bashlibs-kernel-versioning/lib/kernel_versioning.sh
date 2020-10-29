include versions.sh

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
