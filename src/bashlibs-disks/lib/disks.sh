device_first_partition() {
    local hd_device=$1

    echo -n $(dirname $hd_device)/

    lsblk --list $hd_device \
        | cut -d ' ' -f 1 \
        | grep 1
}

refresh_partition_table() {
    local hd_device=$1

    partx --update $hd_device \
        > /dev/null 2>&1
}

create_one_big_partition() {
    local hd_device=$1

    echo '2048,,' \
        | sfdisk -uS $hd_device --force

    refresh_partition_table $hd_device
}

create_ext4_filesystem() {
    local partition_device=$1; shift
    local extra_args=$@

    mkfs.ext4 $extra_args -F $partition_device
}

inode_count() {
    local partition_device=$1

    dumpe2fs $partition_device 2> /dev/null \
        | grep 'Inode count:' \
        | awk '{print $3}'
}

filesystem_uuid() {
    local partition_device=$1

    dumpe2fs $partition_device 2> /dev/null \
        | grep 'Filesystem UUID:' \
        | awk '{print $3}'
}
