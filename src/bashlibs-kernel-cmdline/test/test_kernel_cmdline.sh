#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include kernel_cmdline.sh

oneTimeSetUp() {
    kernel_cmdline() {
        echo "flag1 ip=1.2.3.4 var1=value1 flag_2 var2=value2 hd=/dev/sda flag3"
    }
}

test_kernel_cmdline_value() {
    returns "1.2.3.4" \
        "kernel_cmdline_value ip"

    returns "value1" \
        "kernel_cmdline_value var1"

    returns "value2" \
        "kernel_cmdline_value var2"

    returns "/dev/sda" \
        "kernel_cmdline_value hd"
}

test_kernel_cmdline_var_provided() {
    return_true \
        "kernel_cmdline_var_provided ip"

    return_true \
        "kernel_cmdline_var_provided var1"

    return_true \
        "kernel_cmdline_var_provided var2"

    return_true \
        "kernel_cmdline_var_provided hd"

    return_false \
        "kernel_cmdline_var_provided var3"

    return_false \
        "kernel_cmdline_var_provided my_ip"
}

test_kernel_cmdline_flag_provided() {
    return_true \
        "kernel_cmdline_flag_provided flag1"

    return_true \
        "kernel_cmdline_flag_provided flag_2"

    return_true \
        "kernel_cmdline_flag_provided flag3"

    return_false \
        "kernel_cmdline_flag_provided flag4"

    return_false \
        "kernel_cmdline_flag_provided var1"

    return_false \
        "kernel_cmdline_flag_provided value1"
}

test_kernel_cmdline_missing_params() {
    returns_empty \
        "kernel_cmdline_missing_params ip var1 var2 hd"

    returns "var4 aaa var3" \
        "kernel_cmdline_missing_params var4 ip var1 var2 aaa hd var3"
}

# load shunit2
source /usr/share/shunit2/shunit2
