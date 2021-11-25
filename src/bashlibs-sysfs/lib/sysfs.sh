include checks.sh

sysfs_root_path() {
    local prefix=$1

    echo $prefix/proc/sys
}

sysfs_set_value() {
    local sysfs_path=$1; shift
    local value=$@

    file_exist $sysfs_path \
        && echo $value > $sysfs_path
}

sysfs_option_on() {
    local sysfs_path=$1

    sysfs_set_value $sysfs_path 1
}

sysfs_option_off() {
    local sysfs_path=$1

    sysfs_set_value $sysfs_path 0
}
