partitiion_name() {
    local hd_device=$1
    local partition_number=$2
    local name=$(basename $hd_device)
    local dir=$(dirname $hd_device)

    echo -n $dir/

    lsblk --list $hd_device \
        | awk '{print $1}' \
        | grep $name \
        | egrep "$name.*$partition_number"
}

device_bios_boot_partition() {
    local hd_device=$1

    partitiion_name $hd_device 1
}

device_efi_partition() {
    local hd_device=$1

    partitiion_name $hd_device 2
}

device_first_partition() {
    local hd_device=$1

    partitiion_name $hd_device 3
}

last_partition() {
    local hd_device=$1

    fdisk -l \
        | grep $(basename $hd_device) \
        | tail -1 \
        | cut -d ' ' -f 1
}

last_partition_uuid() {
    local hd_device=$1

    ls -l /dev/disk/by-partuuid/ \
        | grep  $(basename $(last_partition $hd_device)) \
        | awk '{print $9}'
}

sync_wait() {
    local path=$1
    local count=30
    
    while true
    do
        sync $path > /dev/null 2>&1 \
            && return

        (( count-- == 0 )) \
            && eexit "sync $path exit with errors"

        sleep 1
    done
}

partprobe_wait() {
    local hd_device=$1
    local count=30
    
    while true
    do
        partprobe $hd_device > /dev/null 2>&1
        
        (( $(fdisk -l $hd_device 2> /dev/null | wc -l) > 0 )) \
            && return

        (( count-- == 0 )) \
            && eexit "partprobe $hd_device exit with errors"

        sleep 1
    done
}

refresh_partition_table() {
    local hd_device=$1

    sync_wait $hd_device
    partprobe_wait $hd_device
}

wait_for_kernel_to_load_partition() {
    local hd_device=$1
    local i=0
    local timeout=1
    local exit_after=60

    refresh_partition_table $hd_device

    until [[ -b /dev/disk/by-partuuid/$(last_partition_uuid $hd_device) ]]
    do
        sleep $timeout

        (( ++i > exit_after/timeout )) \
            && eexit "partition table of $hd_device is not updating/refreshing correctly"
    done
}

create_one_big_partition() {
    local hd_device=$1

    parted --align optimal --script $hd_device \
        mklabel gpt \
        unit mib \
        mkpart primary 1 3 \
        name 1 grub \
        set 1 bios_grub on \
        mkpart primary 3 131 \
        name 2 efi \
        set 2 boot on \
        mkpart primary 131 100% \
        name 3 rootfs

    sync_wait $hd_device
    wait_for_kernel_to_load_partition $hd_device
}

create_efi_filesystem() {
    local hd_device=$1

    mkfs.fat -F 32 $(device_efi_partition $hd_device)
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

avaliable_space() {
    local path=$1

    df $path \
        | awk '{print $4}' \
        | tail -1
}

is_space_sufficient() {
    local needed_space=$1
    local path=$2

    (( $(avaliable_space $path) >= $needed_space ))
}
