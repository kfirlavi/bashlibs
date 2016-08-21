#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include kernel_cmdline.sh

oneTimeSetUp() {
    CMDLINE_FILE=$(mktemp)

    echo "flag1 ip=1.2.3.4 var1=value1 flag_2 var2=value2 hd=/dev/sda flag3" > $CMDLINE_FILE
}

oneTimeTearDown() {
    rm -f $CMDLINE_FILE
}

test_kernel_cmdline_value() {
    returns "1.2.3.4" \
        "kernel_cmdline_value ip $CMDLINE_FILE"

    returns "value1" \
        "kernel_cmdline_value var1 $CMDLINE_FILE"

    returns "value2" \
        "kernel_cmdline_value var2 $CMDLINE_FILE"

    returns "/dev/sda" \
        "kernel_cmdline_value hd $CMDLINE_FILE"
}

test_kernel_cmdline_var_provided() {
    return_true \
        "kernel_cmdline_var_provided ip $CMDLINE_FILE"

    return_true \
        "kernel_cmdline_var_provided var1 $CMDLINE_FILE"

    return_true \
        "kernel_cmdline_var_provided var2 $CMDLINE_FILE"

    return_true \
        "kernel_cmdline_var_provided hd $CMDLINE_FILE"

    return_false \
        "kernel_cmdline_var_provided var3 $CMDLINE_FILE"

    return_false \
        "kernel_cmdline_var_provided my_ip $CMDLINE_FILE"
}

test_kernel_cmdline_flag_provided() {
    return_true \
        "kernel_cmdline_flag_provided flag1 $CMDLINE_FILE"

    return_true \
        "kernel_cmdline_flag_provided flag_2 $CMDLINE_FILE"

    return_true \
        "kernel_cmdline_flag_provided flag3 $CMDLINE_FILE"

    return_false \
        "kernel_cmdline_flag_provided flag4 $CMDLINE_FILE"

    return_false \
        "kernel_cmdline_flag_provided var1 $CMDLINE_FILE"

    return_false \
        "kernel_cmdline_flag_provided value1 $CMDLINE_FILE"
}

# load shunit2
source /usr/share/shunit2/shunit2
