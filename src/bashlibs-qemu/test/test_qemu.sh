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

cfile() {
    echo /tmp/test-compressed.qcow2
}

setUp() {
    create_qcow2_image $(qfile) 1G
    touch $(rfile)
}

tearDown() {
    rm -f $(cfile)
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

create_test_qcow2_with_filesystem() {
    nbd_connect $(qfile)

    create_one_big_partition $(nbd_first_device) > /dev/null 2>&1
    create_ext4_filesystem $(device_first_partition $(nbd_first_device)) > /dev/null 2>&1

    nbd_disconnect
}

tmp_mount_point() {
    echo /tmp/testdir
}

tmp_testfile() {
    echo $(tmp_mount_point)/testfile
}

verify_filesystem_is_read_write() {
    file_shouldnt_exist $(tmp_testfile)
    touch $(tmp_testfile) > /dev/null 2>&1
    file_should_exist $(tmp_testfile)
}

verify_filesystem_is_read_only() {
    file_shouldnt_exist $(tmp_testfile)
    touch $(tmp_testfile) > /dev/null 2>&1
    file_shouldnt_exist $(tmp_testfile)
}

verify_filesystem_created() {
    directory_should_exist \
        $(tmp_mount_point)/lost+found
}

verify_mount_point_was_released() {
    directory_shouldnt_exist \
        $(tmp_mount_point)/lost+found

    directory_should_be_empty \
        $(tmp_mount_point)
}

test_mount_qcow2_image() {
    create_test_qcow2_with_filesystem

    mount_qcow2_image $(qfile) 2 $(tmp_mount_point) > /dev/null 2>&1

    verify_filesystem_created
    verify_filesystem_is_read_write

    umount_qcow2_image $(tmp_mount_point)
    verify_mount_point_was_released

    safe_delete_directory_from_tmp $(tmp_mount_point)
}

test_mount_qcow2_image_readonly() {
    create_test_qcow2_with_filesystem

    mount_qcow2_image_readonly $(qfile) 2 $(tmp_mount_point) > /dev/null 2>&1

    verify_filesystem_created
    verify_filesystem_is_read_only

    umount_qcow2_image $(tmp_mount_point)
    verify_mount_point_was_released

    safe_delete_directory_from_tmp $(tmp_mount_point)
}

compressable_file() {
    echo $(tmp_mount_point)/compressable_file
}

generate_compressable_file() {
    seq 1 10000000 > $(compressable_file)
}

file_size() {
    local file=$1

    stat --printf="%s" $file
}

test_compress_qcow2_image() {
    create_test_qcow2_with_filesystem

    mount_qcow2_image $(qfile) 2 $(tmp_mount_point) > /dev/null 2>&1

    verify_filesystem_created
    verify_filesystem_is_read_write
    generate_compressable_file

    umount_qcow2_image $(tmp_mount_point)
    verify_mount_point_was_released

    safe_delete_directory_from_tmp $(tmp_mount_point)

    compress_qcow2_image \
        $(qfile) \
        $(cfile)

    return_true "(( $(file_size $(qfile)) > $(file_size $(cfile)) ))"
}

# load shunit2
source /usr/share/shunit2/shunit2
