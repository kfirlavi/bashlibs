include verbose.sh
include directories.sh
include disks.sh
include kernel_modules.sh

nbd_device() {
    echo /dev/nbd
}

nbd_first_device() {
    echo $(nbd_device)0
}

create_qcow2_image() {
    local image_file=$1
    local size=$2

    qemu-img create \
        -q \
        -f qcow2 \
        $image_file \
        $size

    sync_wait $image_file
}

image_file_format() {
    local image_file=$1

    qemu-img info $image_file \
        | grep 'file format' \
        | awk '{print $3}'
}

verify_image_is_qcow2() {
    local image_file=$1

    qemu-img info $image_file \
        | grep -q 'file format: qcow2'
}

enable_nbd() {
    load_kernel_module nbd max_part=8
}

create_mount_point() {
    local mount_point=$1

    create_dir_if_needed $mount_point quiet
}

nbd_connect() {
    local image_file=$1
    local readonly_flag=$2
    local extra_params=

    enable_nbd

    [[ -n $readonly_flag ]] \
        && extra_params="--read-only"

    qemu-nbd $extra_params \
        --connect=$(nbd_first_device) \
        $image_file

    refresh_partition_table \
        $(nbd_first_device)
}

nbd_disconnect() {
    qemu-nbd \
        --disconnect $(nbd_first_device) \
        > /dev/null
}

process_is_running() {
    local ps_fax_process_identifier_str=$@

    ps faxww \
        | grep "$ps_fax_process_identifier_str" \
        | grep -v grep \
        | grep -q "$ps_fax_process_identifier_str"
}

nbd_connected() {
    local image_file=$1

    process_is_running \
        "qemu-nbd --connect=$(nbd_first_device) $image_file"
}

mount_wait() {
    local hd_device=$1
    local mount_point=$2
    local count=30

    mount $nbd_device $mount_point > /dev/null 2>&1

    while true
    do
        dir_is_empty $mount_point \
            || return

        (( count-- == 0 )) \
            && eexit "mount $nbd_device $mount_point don't work"

        sleep 1
    done
}

mount_qcow2_image() {
    local image_file=$1
    local partition_number=$2
    local mount_point=$3
    local readonly_flag=$4
    local nbd_device=$(nbd_first_device)p$partition_number

    create_mount_point $mount_point
    nbd_connect $image_file $readonly_flag

    while [[ -z $(mount | grep "$nbd_device") ]]
    do
        [[ -b $nbd_device ]] \
            && mount_wait \
                $nbd_device \
                $mount_point

        sleep 1
    done
}

mount_qcow2_image_readonly() {
    local image_file=$1
    local partition_number=$2
    local mount_point=$3

    mount_qcow2_image \
        $image_file \
        $partition_number \
        $mount_point \
        readonly
}

is_mounted() {
    local mount_point=$1
 
    mount \
        | grep -q $mount_point
}

umount_wait() {
    local mount_point=$1
    local count=30
 
    while true
    do
        umount $mount_point > /dev/null 2>&1

        is_mounted $mount_point \
            || return

        sleep 1

        (( count-- == 0 )) \
            && eexit "can not unmount $mount_point"
    done
}

umount_qcow2_image() {
    local mount_point=$1
    local count=60

    sync_wait $mount_point
    umount_wait $mount_point
    nbd_disconnect
}

compress_qcow2_image() {
    local input_qcow2=$1
    local output_qcow2=$2

    verify_image_is_qcow2 $input_qcow2 \
        || eexit "$input_qcow2 is not qcow2"

    qemu-img convert -c -f qcow2 -O qcow2 \
        $input_qcow2 \
        $output_qcow2.compressed

    mv $output_qcow2{.compressed,}
}

create_qcow2_backing_file() {
    local master_image=$(realpath $1)
    local target_image=$(realpath -m $2)
    local target_dir=$(dirname $target_image)

    create_dir_if_needed $target_dir quiet
    cd $target_dir

    qemu-img create \
        -b $(realpath -m --relative-to=. $master_image) \
        -F qcow2 \
        -f qcow2 $target_image \
         > /dev/null 2>&1

    cd - > /dev/null 2>&1
}

image_has_backing_file() {
    local image=$1

    file $image \
        | grep -q 'has backing file '
}

backing_file() {
    local image=$1

    image_has_backing_file $image \
        || return

    file $image \
        | sed 's/.*(path //' \
        | sed 's/).*//'
}

enable_kvm() {
    load_kernel_module kvm_intel
}
