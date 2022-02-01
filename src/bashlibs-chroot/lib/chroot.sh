include directories.sh

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

allow_networking_from_chroot() {
    local chroot_dir=$1

    [[ -d /run/resolvconf ]] \
        && rsync -a \
            /run/resolvconf \
            $chroot_dir/run

    cp --dereference \
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
        && return

    mount --rbind /sys $mount_point
    mount --make-rslave $mount_point
}

umount_sys_on_chroot() {
    local chroot_dir=$1

    umount -R $(chroot_sys_mount_point $chroot_dir)
}

chroot_run_mount_point() {
    local chroot_dir=$1

    create_dir_if_needed \
        $chroot_dir/run
}

mount_run_on_chroot() {
    local chroot_dir=$1
    local mount_point=$(chroot_run_mount_point $chroot_dir)

    is_mounted $mount_point \
        && return

    mount --rbind /run $mount_point
    mount --make-rslave $mount_point
}

umount_run_on_chroot() {
    local chroot_dir=$1

    umount -R $(chroot_run_mount_point $chroot_dir)
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
        && return

    mount --rbind /dev $mount_point
    mount --make-rslave $mount_point
}

umount_dev_on_chroot() {
    local chroot_dir=$1

    umount -l $(chroot_dev_mount_point $chroot_dir){/shm,/pts,}
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
        && return

    mount --rbind /var/run $mount_point
    mount --make-rslave $mount_point
}

umount_var_run_on_chroot() {
    local chroot_dir=$1

    umount -R $(chroot_var_run_mount_point $chroot_dir)
}

chroot_prepare() {
    local chroot_dir=$1

    check_chroot_dir_exists  $chroot_dir

    mount_proc_on_chroot     $chroot_dir
    mount_sys_on_chroot      $chroot_dir
    mount_run_on_chroot      $chroot_dir
    mount_dev_on_chroot      $chroot_dir
    mount_var_run_on_chroot  $chroot_dir

    allow_networking_from_chroot $chroot_dir
}

chroot_finish() {
    local chroot_dir=$1

    umount_var_run_on_chroot $chroot_dir
    umount_sys_on_chroot     $chroot_dir
    umount_run_on_chroot     $chroot_dir
    umount_proc_on_chroot    $chroot_dir
    umount_dev_on_chroot     $chroot_dir
}

chroot_to() {
    local chroot_dir=$1; shift
    local chroot_params=$@

    chroot_prepare $chroot_dir
    chroot $chroot_dir $chroot_params
    chroot_finish $chroot_dir
}

execute_in_chroot() {
    local chroot_dir=$1; shift
    local chroot_command=$@

    chroot \
        $chroot_dir \
        $chroot_command
}
