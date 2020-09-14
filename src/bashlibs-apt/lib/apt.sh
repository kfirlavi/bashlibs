include verbose.sh
include config.sh
include apt_cmd.sh

setup_apt() {
    [[ -n $(which apt) ]] \
        && var_to_function apt_bin apt \
        && return

    [[ -n $(which apt-get) ]] \
        && var_to_function apt_bin apt-get \
        && return

    eexit "Can not find apt or apt-get support in the system"
}

apt_bin() {
    echo you need to run setup_apt, before using any of the apt functions
}

vinfo_apt() {
    local str=$@

    vinfo "$(apt_bin): $str"
}

apt_fix_install() {
    vinfo_apt "fixing installation"
    eval $(apt_cmd_fix_install)
}

apt_install_package() {
    local package=$1

    vinfo_apt "installing $(color white)$package$(no_color)"
    eval $(apt_cmd_install_package $package)
    apt_fix_install
}

apt_update() {
    vinfo_apt "updating"
    eval $(apt_cmd_update)
}

apt_upgrade() {
    vinfo_apt "upgrading packages"
    eval $(apt_cmd_upgrade)
}

apt_dist_upgrade() {
    vinfo_apt "dist-upgrade packages"
    eval $(apt_cmd_dist_upgrade)
}

apt_autoremove() {
    vinfo_apt "autoremove unneeded packages"
    eval $(apt_cmd_autoremove)
}

apt_clean() {
    vinfo_apt "cleaning"
    eval $(apt_cmd_clean)
}
