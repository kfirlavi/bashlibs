include file_manipulations.sh

grub_params_file() {
    echo /etc/default/grub
}

grub_cfg() {
    echo /boot/grub/grub.cfg
}

grub_exe() {
    which grub2-mkconfig > /dev/null 2>&1 \
        && echo grub2 \
        || echo grub
}

enable_marked_out_variable() {
    local var_name=$1
    local file=$2

    sed -i "s/#$var_name/$var_name/" $file
}

grub_cmdline_linux_default_add() {
    local cmdline=$1
    local var=GRUB_CMDLINE_LINUX_DEFAULT
    local line=$(grep $var $(grub_params_file))

    enable_marked_out_variable \
        $var \
        $(grub_params_file)

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
    $(grub_exe)-mkconfig -o $(grub_cfg)
}

grub_clean_record_fail() {
    rm -f /boot/grub/grubenv
}

enable_grub_serial_console() {
    local baud=$1
    local console_device=$2
    local serial_device=$3

    grub_cmdline_linux_default_add \
        "console=$console_device"

    grub_cmdline_linux_default_add \
        "console=$serial_device,$baud"

    sed -i 's/.*GRUB_TERMINAL=.*/GRUB_TERMINAL="console serial"/' \
        $(grub_params_file)

    add_line_to_file_if_not_exist \
        $(grub_params_file) \
        "GRUB_SERIAL_COMMAND=\"serial --speed=$baud --unit=0 --word=8 --parity=no --stop=1\""
}

disable_grub_serial_console() {
    local baud=$1
    local console_device=$2
    local serial_device=$3

    delete_line_from_file \
        $(grub_params_file) \
        "GRUB_SERIAL_COMMAND="

    grub_cmdline_linux_default_delete \
        "console=$console_device"

    sed -i 's/.*GRUB_TERMINAL=.*/GRUB_TERMINAL="console"/' \
        $(grub_params_file)


    grub_cmdline_linux_default_delete \
        "console=$serial_device,$baud"
}
