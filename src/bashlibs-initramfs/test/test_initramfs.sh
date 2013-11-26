#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include initramfs.sh

create_test_initramfs() {
    local tmpdir=$(mktemp -d)
    local initrd_file=$(mktemp /tmp/initrd.XXXXX)

    cd $tmpdir

    touch test_module.ko
    find | cpio -o > $initrd_file 2> /dev/null
    gzip $initrd_file
    mv $initrd_file{.gz,}

    [[ -d $tmpdir && $tmpdir =~ /tmp/tmp ]] \
        && rm -Rf $tmpdir

    echo $initrd_file

    cd - > /dev/null 2>&1
}

setUp() {
    FILE=$(mktemp)
    modfile() {
        echo $FILE
    }
}

tearDown() {
    [[ -f $FILE ]] \
        && rm -f $FILE
}


test_initramfs_register_module() {
    initramfs_register_module aufs

    it_should "include the module aufs" \
        "grep -q aufs $(modfile)"
}

test_initramfs_unregister_module() {
    initramfs_register_module aufs
    initramfs_unregister_module aufs

    it_shouldnt "include the module aufs" \
        "grep -q aufs $(modfile)"
}

test_is_initramfs_include_module() {
    local initrd=$(create_test_initramfs)

    return_true "is_initramfs_include_module $initrd test_module.ko"
    return_false "is_initramfs_include_module $initrd non_exist_module.ko"

    rm -f $initrd
}

# load shunit2
source /usr/share/shunit2/shunit2
