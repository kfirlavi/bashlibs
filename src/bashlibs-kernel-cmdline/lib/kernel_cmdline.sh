kernel_cmdline() {
    cat /proc/cmdline
}

kernel_cmdline_value() {
    local var=$1

    kernel_cmdline \
        | sed 's/ /\n/g' \
        | grep "${var}=" \
        | cut -d '=' -f 2
}

kernel_cmdline_var_provided() {
    local var=$1

    kernel_cmdline \
        | sed 's/ /\n/g' \
        | grep -q "${var}="
}

kernel_cmdline_flag_provided() {
    local flag=$1

    kernel_cmdline \
        | sed 's/ /\n/g' \
        | grep -q "^$flag$"
}

kernel_cmdline_missing_params() {
    local params=$@
    local i

    for i in $params
    do
        kernel_cmdline_var_provided $i \
            || echo $i
    done
}

kernel_cmdline_exit_if_param_is_missing() {
    local param=$1
    local missing_param=$(kernel_cmdline_missing_params $param)

    [[ -n $missing_param ]] \
        && eexit "param $(color white)$param$(no_color) must be provided as a kernel command line arguments"
}

kernel_cmdline_exit_if_params_are_missing() {
    local params=$@
    local missing_params=$(kernel_cmdline_missing_params $params)

    [[ -n $missing_params ]] \
        && eexit "params $(color white)$params$(no_color) must be provided as a kernel command line arguments"
}
