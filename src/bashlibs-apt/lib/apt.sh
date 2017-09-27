apt_get_quiet_flags() {
    echo "--quiet=2"
}

apt_get_force() {
    echo "apt-get -y --force-yes $(apt_get_quiet_flags)"
}

apt_fix_install() {
    $(apt_get_force) install
}

apt_install_package() {
    local package=$1

    vinfo "installing pacakge: $(color white)$package$(no_color)"
    $(apt_get_force) install $package
    apt_fix_install
}

apt_update() {
    vinfo "updating apt database"
    $(apt_get_force) update
}

apt_upgrade() {
    vinfo "upgrading packages"
    $(apt_get_force) upgrade
}

apt_dist_upgrade() {
    vinfo "dist-upgrade packages"
    $(apt_get_force) dist-upgrade
}

apt_autoremove() {
    vinfo "autoremove unneeded packages"
    $(apt_get_force) autoremove
}

apt_clean() {
    apt-get clean
}
