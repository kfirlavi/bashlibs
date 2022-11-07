apt_quiet_flags() {
    echo "--quiet=2"
}

apt_noninteractive_flag() {
    echo DEBIAN_FRONTEND=noninteractive
}

apt_force() {
    echo "$(apt_noninteractive_flag) $(apt_bin) -y --force-yes $(apt_quiet_flags)"
}

apt_cmd_fix_install() {
    echo $(apt_force) install
}

apt_cmd_install_package() {
    local package=$1

    echo $(apt_force) install $package
}

apt_cmd_update() {
    echo $(apt_force) update
}

apt_cmd_upgrade() {
    echo $(apt_force) upgrade
}

apt_cmd_dist_upgrade() {
    echo $(apt_force) dist-upgrade
}

apt_cmd_force_dist_upgrade() {
    echo $(apt_force) dist-upgrade --fix-missing
}

apt_cmd_autoremove() {
    echo $(apt_force) autoremove
}

apt_cmd_clean() {
    echo $(apt_force) clean
}

apt_cmd_locked() {
    echo 'dpkg -i /dev/zero > /dev/null 2>&1'
}

apt_cmd_package_installed() {
    local package=$1

    echo "dpkg -l | cut -d ' ' -f 3 | egrep '^$package$'"
}
