refresh_partition_table() {
    local hd_device=$1

    partx --update $hd_device
}

create_one_big_partition() {
    local hd_device=$1

    echo '2048,,' \
        | sfdisk -uS $hd_device --force

    refresh_partition_table $hd_device
}

create_ext4_filesystem() {
    local partition_device=$1

    mkfs.ext4 $partition_device
}
