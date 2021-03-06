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

loop_bios_boot_partition() {
    device_bios_boot_partition $(loop_device)
}

loop_first_partition() {
    device_first_partition $(loop_device)
}

test_create_one_big_partition() {
    create_one_big_partition $(loop_device) > /dev/null 2>&1

    returns "$(loop_bios_boot_partition)       2048   18431   16384   8M BIOS boot" \
        "fdisk -l $(loop_device) | grep $(loop_bios_boot_partition)"

    returns "$(loop_first_partition)       18432 8386559 8368128   4G Linux filesystem" \
        "fdisk -l $(loop_device) | grep $(loop_first_partition)"
}

test_device_bios_boot_partition() {
    returns $(loop_device)p1 \
        "device_bios_boot_partition $(loop_device)"
}

test_device_first_partition() {
    returns $(loop_device)p2 \
        "device_first_partition $(loop_device)"
}

test_create_ext4_filesystem() {
    return_true "create_ext4_filesystem $(loop_first_partition)"
    return_true "create_ext4_filesystem $(loop_first_partition)"

    return_true "create_ext4_filesystem $(loop_first_partition) -T small"
    returns "1046528" "inode_count $(loop_first_partition)"

    return_true "create_ext4_filesystem $(loop_first_partition) -T huge"
    returns "65536" "inode_count $(loop_first_partition)"
}

test_inode_count() {
    return_true "create_ext4_filesystem $(loop_first_partition)"

    returns "261632" "inode_count $(loop_first_partition)"
}

test_filesystem_uuid() {
    return_true "create_ext4_filesystem $(loop_first_partition)"

    returns 37 "filesystem_uuid $(loop_first_partition) | wc -m"
    returns 5 "filesystem_uuid $(loop_first_partition) | sed 's/-/ /g' | wc -w"
}

# load shunit2
source /usr/share/shunit2/shunit2
