#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include qemu.sh
include disks.sh
include directories.sh

qfile() {
    echo /tmp/test.qcow2
}

rfile() {
    echo /tmp/test.raw
}

setUp() {
    create_qcow2_image $(qfile) 1G
    touch $(rfile)
}

tearDown() {
    rm -f $(qfile)
    rm -f $(rfile)
}

test_create_qcow2_image() {
    create_qcow2_image $(qfile) 1G
    file_should_exist $(qfile)
    returns "qcow2" "image_file_format $(qfile)"
}

test_image_file_format() {
    returns "raw"   "image_file_format $(rfile)"
    returns "qcow2" "image_file_format $(qfile)"
}

test_verify_image_is_qcow2() {
    return_false "verify_image_is_qcow2 $(rfile)"
    return_true  "verify_image_is_qcow2 $(qfile)"
}

test_nbd_connected() {
    rmmod nbd

    nbd_connect $(qfile)
    return_true "nbd_connected $(qfile)"

    nbd_disconnect
    return_false "nbd_connected $(qfile)"
}

test_mount_qemu_image() {
    local mount_point=/tmp/testdir

    nbd_connect $(qfile)

    create_one_big_partition $(nbd_first_device) > /dev/null 2>&1
    create_ext4_filesystem $(device_first_partition $(nbd_first_device)) > /dev/null 2>&1

    mount_qcow2_image $(qfile) 1 $mount_point > /dev/null 2>&1
    directory_should_exist $mount_point/lost+found

    umount_qcow2_image $mount_point
    directory_shouldnt_exist $mount_point/lost+found
    directory_should_be_empty $mount_point

    safe_delete_directory_from_tmp $mount_point
}

# load shunit2
source /usr/share/shunit2/shunit2
