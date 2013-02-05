#!/bin/bash
$(bashlibs --include include.sh)
include shunit2_enhancements.sh
include grub.sh

setUp() {
    FILE=$(mktemp)
    grub_params_file() {
        echo $FILE
    }
}

tearDown() {
    [[ -f $FILE ]] \
        && rm -f $FILE
}

test_grub_cmdline_linux_default_add() {
    local before='GRUB_CMDLINE_LINUX_DEFAULT="text"'
    local expected='GRUB_CMDLINE_LINUX_DEFAULT="text myvar=aaa"'

    echo $before > $FILE
    grub_cmdline_linux_default_add 'myvar=aaa'

    it_should "add the string to grub param" \
        "grep -q '$expected' $FILE"

    grub_cmdline_linux_default_add 'myvar=aaa'
    grub_cmdline_linux_default_add 'myvar=aaa'

    it_should "add the string to grub param just once" \
        "grep -q '$expected' $FILE"
}

test_grub_cmdline_linux_default_delete() {
    local before='GRUB_CMDLINE_LINUX_DEFAULT="text myvar=aaa var1"'
    local expected='GRUB_CMDLINE_LINUX_DEFAULT="text var1"'

    echo $before > $FILE
    grub_cmdline_linux_default_delete 'myvar=aaa'

    it_should "delete the string from grub param" \
        "grep -q '$expected' $FILE"
}

# load shunit2
source /usr/share/shunit2/shunit2
