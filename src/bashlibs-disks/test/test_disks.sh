#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include disks.sh

image() {
    echo /tmp/file.img
}

oneTimeSetUp() {
    truncate -s 4G $(image)
    losetup -f $(image)
}

oneTimeTearDown() {
    losetup -D
    rm -f $(image)
}

loop_device() {
    losetup -l \
        | grep $(image) \
        | cut -d ' ' -f 1
}

loop_first_partition() {
    device_first_partition $(loop_device)
}

test_create_one_big_partition() {
    create_one_big_partition $(loop_device) > /dev/null 2>&1

    returns "$(loop_first_partition)       2048 8388607 8386560   4G 83 Linux" \
        "fdisk -l $(loop_device) | grep $(loop_first_partition)"
}

test_device_first_partition() {
    returns $(loop_device)p1 \
        "device_first_partition $(loop_device)"
}

test_create_ext4_filesystem() {
    return_true "create_ext4_filesystem $(loop_first_partition)"
    return_true "create_ext4_filesystem $(loop_first_partition)"

    return_true "create_ext4_filesystem $(loop_first_partition) -T small"
    returns "1048576" "inode_count $(loop_first_partition)"

    return_true "create_ext4_filesystem $(loop_first_partition) -T huge"
    returns "65536" "inode_count $(loop_first_partition)"
}

test_inode_count() {
    return_true "create_ext4_filesystem $(loop_first_partition)"

    returns "262144" "inode_count $(loop_first_partition)"
}

# load shunit2
source /usr/share/shunit2/shunit2
