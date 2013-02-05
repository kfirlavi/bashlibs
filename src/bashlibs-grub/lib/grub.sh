grub_params_file() {
    echo /etc/default/grub
}

grub_cmdline_linux_default_add() {
    local cmdline=$1
    local var=GRUB_CMDLINE_LINUX_DEFAULT
    local line=$(grep $var $(grub_params_file))

    [[ $line =~ "$cmdline" ]] \
        && return

    sed -i \
        "s/\($var=\".*\)\"/\1 $cmdline\"/g" \
        $(grub_params_file)
}

grub_cmdline_linux_default_delete() {
    local cmdline=$1

    sed -i \
        "s/\(GRUB_CMDLINE_LINUX_DEFAULT.*\)$cmdline\(.*\)/\1\2/g; s/\s\+/ /g" \
        $(grub_params_file)
}

generate_grub_cfg() {
    grub-mkconfig > /boot/grub/grub.cfg
}

grub_clean_record_fail() {
    rm -f /boot/grub/grubenv
}
