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

kernel_makefile_variable_value() {
    local variable=$1
    local kernel_makefile=$2

    grep $variable $kernel_makefile \
        | head -1 \
        | cut -d ' ' -f 3
}

kernel_major_version() {
    local kernel_makefile=$1

    kernel_makefile_variable_value \
        VERSION \
        $kernel_makefile
}

kernel_patchlevel_version() {
    local kernel_makefile=$1

    kernel_makefile_variable_value \
        PATCHLEVEL \
        $kernel_makefile
}

kernel_sublevel_version() {
    local kernel_makefile=$1

    kernel_makefile_variable_value \
        SUBLEVEL \
        $kernel_makefile
}

kernel_version_from_makefile() {
    local kernel_makefile=$1

    echo -n $(kernel_major_version $kernel_makefile)
    echo -n '.'
    echo -n $(kernel_patchlevel_version $kernel_makefile)
    echo -n '.'
    echo    $(kernel_sublevel_version $kernel_makefile)
}

kernel_source_tree_version() {
    local kernel_source_tree=$1

    kernel_version_from_makefile \
        $kernel_source_tree/Makefile
}
