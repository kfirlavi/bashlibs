include verbose.sh
include file_manipulations.sh

modfile() {
    echo /etc/initramfs-tools/modules
}

initramfs_register_module() {
    local module=$1

    egrep -q "^$module" $(modfile) \
        || add_line_to_file $(modfile) $module
}

initramfs_unregister_module() {
    local module=$1

    egrep -q "^$module" $(modfile) \
        && delete_line_from_file $(modfile) $module
}

update_initramfs() {
    local extra_commands=$@
    local all_kernel_versions='-k all'
    local update_an_existing_initramfs='-u'

	update-initramfs \
        $extra_commands \
        $all_kernel_versions \
        $update_an_existing_initramfs

}

kernel_versions() {
    ls -1 /lib/modules
}

initrd_for_kernel_version() {
    local kver=$1

    echo /boot/initrd.img-$kver
}

initrd_files() {
    local i

    for i in $(kernel_versions)
    do
        initrd_for_kernel_version $i
    done
}

list_initramfs_content() {
    local initrd=$1
    local tmpdir=$(mktemp -d)

    cd $tmpdir

    cp $initrd $tmpdir
    mv $(basename $initrd){,.gz}
    gzip -d $(basename $initrd).gz
    cpio -i < $(basename $initrd) > /dev/null 2>&1
    find

    [[ -d $tmpdir && $tmpdir =~ /tmp/tmp ]] \
        && rm -Rf $tmpdir

    cd -
}

is_initramfs_include_module() {
    local initrd=$1
    local module=$2

    list_initramfs_content $initrd \
        | grep -q $module
}

foreach_initramfs_check_module_included() {
    local module=$1
    local i

    for i in $(initrd_files)
    do
         is_initramfs_include_module $i "$module" \
		    ||  eexit "error adding $module to initrd $i"
    done
}

foreach_initramfs_check_module_not_included() {
    local module=$1
    local i

    for i in $(initrd_files)
    do
         is_initramfs_include_module $i "$module" \
		    &&  eexit "error removing $module from initrd $i"
    done
}

initramfs_add_moudle() {
    local module=$1

	vinfo "Adding $module to initrd"
    initramfs_register_module $module
    update_initramfs
    foreach_initramfs_check_module_included $module.ko
}

initramfs_remove_moudle() {
    local module=$1

	vinfo "Removing $module from initrd"
    initramfs_unregister_module $module
    update_initramfs
    foreach_initramfs_check_module_not_included $module.ko
}
