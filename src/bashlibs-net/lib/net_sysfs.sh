include sysfs.sh

sysfs_net_root_path() {
    local prefix=$1

    echo $(sysfs_root_path $prefix)/net
}

sysfs_set_net() {
    local subcategory=$1; shift
    local param=$1; shift
    local value=$@

    sysfs_set_value \
        $(sysfs_net_root_path)/$subcategory/$param \
        $value
}

sysfs_set_net_core() {
    local param=$1; shift
    local value=$@

    sysfs_set_net core $param $value
}

sysfs_set_net_ipv4() {
    local param=$1; shift
    local value=$@

    sysfs_set_net ipv4 $param $value
}
