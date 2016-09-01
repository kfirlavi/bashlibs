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

test_create_one_big_partition() {
    create_one_big_partition $(loop_device) > /dev/null 2>&1

    returns "$(loop_device)p1       2048 8388607 8386560   4G 83 Linux" \
        "fdisk -l $(loop_device) | grep $(loop_device)p1"
}

# load shunit2
source /usr/share/shunit2/shunit2
