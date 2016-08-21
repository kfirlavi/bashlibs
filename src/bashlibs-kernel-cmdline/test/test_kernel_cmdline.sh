#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include kernel_cmdline.sh

oneTimeSetUp() {
    CMDLINE_FILE=$(mktemp)

    echo "ip=1.2.3.4 var1=value1 var2=value2 hd=/dev/sda" > $CMDLINE_FILE
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

# load shunit2
source /usr/share/shunit2/shunit2