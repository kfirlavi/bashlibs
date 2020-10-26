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

loop_efi_partition() {
    device_efi_partition $(loop_device)
}

loop_first_partition() {
    device_first_partition $(loop_device)
}

test_create_one_big_partition() {
    create_one_big_partition $(loop_device) > /dev/null 2>&1

    returns "$(loop_bios_boot_partition)   2048    6143    4096    2M BIOS boot" \
        "fdisk -l $(loop_device) | grep $(loop_bios_boot_partition)"

    returns "$(loop_efi_partition)   6144  268287  262144  128M EFI System" \
        "fdisk -l $(loop_device) | grep $(loop_efi_partition)"

    returns "$(loop_first_partition) 268288 8386559 8118272  3.9G Linux filesystem" \
        "fdisk -l $(loop_device) | grep $(loop_first_partition)"
}

test_device_bios_boot_partition() {
    returns $(loop_device)p1 \
        "device_bios_boot_partition $(loop_device)"
}

test_device_efi_partition() {
    returns $(loop_device)p2 \
        "device_efi_partition $(loop_device)"
}

test_device_first_partition() {
    returns $(loop_device)p3 \
        "device_first_partition $(loop_device)"
}

test_create_efi_filesystem() {
    return_true "create_efi_filesystem $(loop_device)"
    return_true "minfo -i $(loop_efi_partition) | grep 'disk type' | grep -q FAT32"
}

test_create_ext4_filesystem() {
    return_true "create_ext4_filesystem $(loop_first_partition)"
    return_true "create_ext4_filesystem $(loop_first_partition)"

    return_true "create_ext4_filesystem $(loop_first_partition) -T small"
    local i=$(inode_count $(loop_first_partition))
    return_true "(( $i < 10210000 || $i > 10200000 ))"

    return_true "create_ext4_filesystem $(loop_first_partition) -T huge"
    returns "63488" "inode_count $(loop_first_partition)"
}

test_inode_count() {
    return_true "create_ext4_filesystem $(loop_first_partition)"

    returns "253952" "inode_count $(loop_first_partition)"
}

test_filesystem_uuid() {
    return_true "create_ext4_filesystem $(loop_first_partition)"

    returns 37 "filesystem_uuid $(loop_first_partition) | wc -m"
    returns 5 "filesystem_uuid $(loop_first_partition) | sed 's/-/ /g' | wc -w"
}

df() {
    echo "/dev/root             51475068 31694492  17142752  65% /"
}

test_avaliable_space() {
    returns 17142752 "avaliable_space /mypath"
}

test_is_space_sufficient() {
    return_true  "is_space_sufficient 17142752 /mypath"
    return_false "is_space_sufficient 17142753 /mypath"
    return_false "is_space_sufficient 20000000 /mypath"
    return_true  "is_space_sufficient 17142751 /mypath"
    return_true  "is_space_sufficient 0 /mypath"
    return_true  "is_space_sufficient 1233123 /mypath"
}

# load shunit2
source /usr/share/shunit2/shunit2
