include directories.sh
include os_detection.sh

check_chroot_dir_exists() {
    local chroot_dir=$1

    [[ -d $chroot_dir ]] \
        || eexit "chroot dir '$chroot_dir' does not exits!"
}

verify_chroot_dir() {
    local chroot_dir=$1

    dir_exist $chroot_dir \
        && [[ $chroot_dir != / ]]
}

allow_networking_from_chroot_for_ubuntu() {
    local chroot_dir=$1

    rsync -a \
        /run/resolvconf \
        $chroot_dir/run
}

allow_networking_from_chroot_for_gentoo() {
    local chroot_dir=$1

    rsync -a \
        /etc/resolv.conf \
        $chroot_dir/etc
}

is_mounted() {
    local mnt_point=$1

    mount \
        | grep -q $mnt_point
}

chroot_proc_mount_point() {
    local chroot_dir=$1

    create_dir_if_needed \
        $chroot_dir/proc
}

mount_proc_on_chroot() {
    local chroot_dir=$1
    local mount_point=$(chroot_proc_mount_point $chroot_dir)

    is_mounted $mount_point \
        || mount -t proc proc $mount_point
}

umount_proc_on_chroot() {
    local chroot_dir=$1

    umount $(chroot_proc_mount_point $chroot_dir)
}

chroot_sys_mount_point() {
    local chroot_dir=$1

    create_dir_if_needed \
        $chroot_dir/sys
}

mount_sys_on_chroot() {
    local chroot_dir=$1
    local mount_point=$(chroot_sys_mount_point $chroot_dir)

    is_mounted $mount_point \
        || mount -t sysfs none $mount_point
}

umount_sys_on_chroot() {
    local chroot_dir=$1

    umount $(chroot_sys_mount_point $chroot_dir)
}

chroot_dev_mount_point() {
    local chroot_dir=$1

    create_dir_if_needed \
        $chroot_dir/dev
}

mount_dev_on_chroot() {
    local chroot_dir=$1
    local mount_point=$(chroot_dev_mount_point $chroot_dir)

    is_mounted $mount_point \
        || mount -o bind /dev $mount_point
}

umount_dev_on_chroot() {
    local chroot_dir=$1

    umount $(chroot_dev_mount_point $chroot_dir)
}

chroot_var_run_mount_point() {
    local chroot_dir=$1

    create_dir_if_needed \
        $chroot_dir/var/run
}

mount_var_run_on_chroot() {
    local chroot_dir=$1
    local mount_point=$(chroot_var_run_mount_point $chroot_dir)

    is_mounted $mount_point \
        || mount -o bind /var/run $mount_point
}

umount_var_run_on_chroot() {
    local chroot_dir=$1

    umount $(chroot_var_run_mount_point $chroot_dir)
}

chroot_to() {
    local chroot_dir=$1; shift
    local chroot_params=$@

    check_chroot_dir_exists  $chroot_dir

    mount_proc_on_chroot     $chroot_dir
    mount_sys_on_chroot      $chroot_dir
    mount_dev_on_chroot      $chroot_dir
    mount_var_run_on_chroot  $chroot_dir

    allow_networking_from_chroot_for_$(distro_name)
    chroot $chroot_dir $chroot_params
    
    umount_var_run_on_chroot $chroot_dir
    umount_sys_on_chroot     $chroot_dir
    umount_proc_on_chroot    $chroot_dir
    umount_dev_on_chroot     $chroot_dir
}
