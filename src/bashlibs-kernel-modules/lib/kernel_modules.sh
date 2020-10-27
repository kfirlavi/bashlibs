kernel_module_loaded() {
    local module=$1

    lsmod \
        | grep -q ^$module
}

load_kernel_module() {
    local module=$1; shift
    local params=$@

    kernel_module_loaded $module \
        && return

    modprobe $module $params
}

remove_kernel_module() {
    local module=$1

    kernel_module_loaded $module \
        || return

    rmmod $module
}
