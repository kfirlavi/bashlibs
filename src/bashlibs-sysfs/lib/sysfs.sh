include checks.sh

sysfs_option_on() {
    local sysfs_path=$1

    file_exist $sysfs_path \
        && echo 1 > $sysfs_path
}

sysfs_option_off() {
    local sysfs_path=$1

    file_exist $sysfs_path \
        && echo 0 > $sysfs_path
}
