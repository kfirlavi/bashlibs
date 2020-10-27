#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include kernel_modules.sh

oneTimeSetUp() {
    lsmod() {
        cat __BASHLIBS_PROJECT_TESTS_DIR__/files/lsmod.txt
    }
}

test_kernel_module_loaded() {
    return_true "kernel_module_loaded nbd"
    return_true "kernel_module_loaded virtio_gpu"
    return_false "kernel_module_loaded non_module"
}

test_load_kernel_module() {
    modprobe() { echo $1; }
    returns_empty "load_kernel_module nbd"
    returns "new_module" "load_kernel_module new_module"
}

test_remove_kernel_module() {
    rmmod() { echo $1; }
    returns_empty "remove_kernel_module non_loaded_module"
    returns "nbd" "remove_kernel_module nbd"
}

# load shunit2
source /usr/share/shunit2/shunit2
