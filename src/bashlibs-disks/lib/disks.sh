create_one_big_partition() {
    local hd_device=$1

    echo '2048,,' \
        | sfdisk -uS $hd_device --force
}
