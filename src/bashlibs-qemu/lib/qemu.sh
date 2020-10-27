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

    create_dir_if_needed $mount_point
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

    ps fax \
        | grep "$ps_fax_process_identifier_str" \
        | grep -v grep \
        | grep -q "$ps_fax_process_identifier_str"
}

nbd_connected() {
    local image_file=$1

    process_is_running \
        "qemu-nbd --connect=$(nbd_first_device) $image_file"
}

mount_qcow2_image() {
    local image_file=$1
    local partition_number=$2
    local mount_point=$3
    local readonly_flag=$4

    create_mount_point $mount_point
    nbd_connect $image_file $readonly_flag
    mount $(nbd_first_device)p$partition_number $mount_point
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

umount_qcow2_image() {
    local mount_point=$1

    umount $mount_point
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

    create_dir_if_needed $target_dir > /dev/null 2>&1
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
    load_kernel_module intel_kvm
}
