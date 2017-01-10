is_kernel_module_loaded() {
    local module=$1

    lsmod \
        | grep -q $module
}

load_kernel_module() {
    local module=$1

    is_kernel_module_loaded $module \
        || modprobe $module

    is_kernel_module_loaded $module \
        || eexit "Can't load kernel module: $module"
}
