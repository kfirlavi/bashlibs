kernel_cmdline_value() {
    local var=$1
    local proc_cmdline_file=${2:-/proc/cmdline}

    cat $proc_cmdline_file \
        | sed 's/ /\n/g' \
        | grep "${var}=" \
        | cut -d '=' -f 2
}

kernel_cmdline_var_provided() {
    local var=$1
    local proc_cmdline_file=${2:-/proc/cmdline}

    cat $proc_cmdline_file \
        | sed 's/ /\n/g' \
        | grep -q "${var}="
}

kernel_cmdline_flag_provided() {
    local flag=$1
    local proc_cmdline_file=${2:-/proc/cmdline}

    cat $proc_cmdline_file \
        | sed 's/ /\n/g' \
        | grep -q "^$flag$"
}
