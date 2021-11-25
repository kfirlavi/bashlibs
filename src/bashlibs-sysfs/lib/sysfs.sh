include checks.sh
include verbose.sh

sysfs_root_path() {
    local prefix=$1

    echo $prefix/proc/sys
}

sysfs_set_value() {
    local sysfs_path=$1; shift
    local value=$@

    vdebug "setting $(color white)$sysfs_path$(no_color) to value $(color green)$value$(no_color)"

    file_exist $sysfs_path \
        && echo $value > $sysfs_path \
        || verror "$sysfs_path does not exist"
}

sysfs_option_on() {
    local sysfs_path=$1

    sysfs_set_value $sysfs_path 1
}

sysfs_option_off() {
    local sysfs_path=$1

    sysfs_set_value $sysfs_path 0
}
