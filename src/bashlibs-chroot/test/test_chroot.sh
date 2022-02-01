#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include directories.sh
include chroot.sh

chroot_dir() {
    create_dir_if_needed /tmp/test_chroot
}

libraries() {
    local command=$1
    ldd $command \
        | grep '/' \
        | cut -d '/' -f 2- \
        | cut -d ' ' -f 1
}

copy_exe_and_libraries() {
    local command=$1
    local i

    rsync -aRL $command $(chroot_dir)

    for i in $(libraries $command)
    do
        rsync -aRL /$i $(chroot_dir)
    done

    chmod +x $(chroot_dir)/bin/*
}

oneTimeSetUp() {
    touch $(chroot_dir)/test_file
    copy_exe_and_libraries /bin/ls
}

oneTimeTearDown() {
    local no_delete=

    for i in proc sys run dev
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

test_chroot_run_mount_point() {
    returns /tmp/test_chroot/run \
        "chroot_run_mount_point $(chroot_dir)"
}

test_mount_run_on_chroot() {
    mount_test_on_chroot run
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
    returns "/test_file" \
        "chroot_to $(chroot_dir) /bin/ls /test_file"

    local i
    for i in proc dev var_run sys run
    do
        return_false "is_mounted $(chroot_${i}_mount_point $(chroot_dir))"
    done
}

test_execute_in_chroot() {
    chroot_prepare $(chroot_dir)

    returns "/test_file" \
        "execute_in_chroot $(chroot_dir) /bin/ls /test_file"

    chroot_finish $(chroot_dir)
}

# load shunit2
source /usr/share/shunit2/shunit2
