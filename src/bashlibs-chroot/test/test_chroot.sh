#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh
include chroot.sh

chroot_dir() {
    create_dir_if_needed /tmp/test_chroot
}

oneTimeTearDown() {
    local no_delete=

    for i in proc sys dev
    do
        is_mounted $(chroot_${i}_mount_point $(chroot_dir)) \
            && no_delete=1
    done

    [[ -z $no_delete ]] \
        && safe_delete_directory_from_tmp $(chroot_dir)
}

test_verify_chroot_dir() {
    local empty_chroot_dir_variable=
    local root_filesystem=/
    local non_exist_dir=/tmp/non_exist_dir

    return_false "verify_chroot_dir $empty_chroot_dir_variable"
    return_false "verify_chroot_dir $root_filesystem"
    return_false "verify_chroot_dir $non_exist_dir"

    return_true  "verify_chroot_dir $(chroot_dir)"
}

test_chroot_proc_mount_point() {
    returns /tmp/test_chroot/proc \
        "chroot_proc_mount_point $(chroot_dir)"
}

mount_test_on_chroot() {
    local name=$1
    local mount_point=$(chroot_${name}_mount_point $(chroot_dir))

    return_false "is_mounted $mount_point"
    mount_${name}_on_chroot $(chroot_dir)
    return_true  "is_mounted $mount_point"
    mount_${name}_on_chroot $(chroot_dir)
    return_true  "is_mounted $mount_point"
    umount_${name}_on_chroot $(chroot_dir)
    return_false "is_mounted $mount_point"
}

test_mount_proc_on_chroot() {
    mount_test_on_chroot proc
}

test_chroot_sys_mount_point() {
    returns /tmp/test_chroot/sys \
        "chroot_sys_mount_point $(chroot_dir)"
}

test_mount_sys_on_chroot() {
    mount_test_on_chroot sys
}

test_chroot_dev_mount_point() {
    returns /tmp/test_chroot/dev \
        "chroot_dev_mount_point $(chroot_dir)"
}

test_mount_dev_on_chroot() {
    mount_test_on_chroot dev
}

test_chroot_var_run_mount_point() {
    returns /tmp/test_chroot/var/run \
        "chroot_var_run_mount_point $(chroot_dir)"
}

test_mount_var_run_on_chroot() {
    mount_test_on_chroot var_run
}

test_chroot_to() {
    touch $(chroot_dir)/test_file
    rsync -a /bin $(chroot_dir)/
    returns "/test_file" \
        "chroot_to $(chroot_dir) /bin/busybox ls /test_file"

    local i
    for i in proc dev var_run sys
    do
        return_false "is_mounted $(chroot_${i}_mount_point $(chroot_dir))"
    done
}

# load shunit2
source /usr/share/shunit2/shunit2
