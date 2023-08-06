#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include qemu.sh
include disks.sh
include directories.sh

qfile() {
    echo $(workdir)/test.qcow2
}

qfile_bakup() {
    echo $(qfile).bak
}

rfile() {
    echo $(workdir)/test.raw
}

cfile() {
    echo $(workdir)/test-compressed.qcow2
}

oneTimeSetUp() {
    create_workdir
    create_test_qcow2_with_filesystem
    cp $(qfile) $(qfile_bakup)
}

oneTimeTearDown() {
    remove_workdir
    true
}

setUp() {
    touch $(rfile)
    cp $(qfile_bakup) $(qfile)
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
    create_qcow2_image $(qfile) 1G
    nbd_connect $(qfile)

    create_one_big_partition $(nbd_first_device) > /dev/null 2>&1
    create_ext4_filesystem $(device_first_partition $(nbd_first_device)) > /dev/null 2>&1

    nbd_disconnect
}

tmp_mount_point() {
    echo $(workdir)/testdir
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
    mount_qcow2_image $(qfile) 3 $(tmp_mount_point) > /dev/null 2>&1

    verify_filesystem_created
    verify_filesystem_is_read_write

    umount_qcow2_image $(tmp_mount_point)
    verify_mount_point_was_released

    safe_delete_directory_from_tmp $(tmp_mount_point)
}

test_mount_qcow2_image_readonly() {
    mount_qcow2_image_readonly $(qfile) 3 $(tmp_mount_point) > /dev/null 2>&1

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
    mount_qcow2_image $(qfile) 3 $(tmp_mount_point) > /dev/null 2>&1

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

test_create_qcow2_backing_file() {
    local new=$(workdir)/a/b/c/new.qcow2
    create_qcow2_backing_file $(qfile) $new

    return_true "verify_image_is_qcow2 $new"
    returns "../../../test.qcow2" "backing_file $new"
}

test_image_has_backing_file() {
    local new=$(workdir)/d/e/f/new.qcow2

    return_false "image_has_backing_file $(qfile)"
    return_false "image_has_backing_file $new"

    create_qcow2_backing_file $(qfile) $new

    return_false "image_has_backing_file $(qfile)"
    return_true "image_has_backing_file $new"
}

test_backing_file() {
    local new=$(workdir)/x/y/z/new.qcow2

    returns_empty "backing_file $(qfile)"
    returns_empty "backing_file $new"

    create_qcow2_backing_file $(qfile) $new

    returns_empty "backing_file $(qfile)"
    returns "../../../test.qcow2" "backing_file $new"
}

# load shunit2
source /usr/share/shunit2/shunit2
