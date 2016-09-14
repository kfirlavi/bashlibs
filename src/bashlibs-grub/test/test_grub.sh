#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include grub.sh

setUp() {
    FILE=$(mktemp)

	cat<<-EOF > $FILE
	#GRUB_CMDLINE_LINUX_DEFAULT=""
	#GRUB_TERMINAL=console
	EOF

    grub_params_file() {
        echo $FILE
    }
}

tearDown() {
    [[ -f $FILE ]] \
        && rm -f $FILE
}

test_grub_cmdline_linux_default_add() {
    local before='#GRUB_CMDLINE_LINUX_DEFAULT="text"'
    local expected='GRUB_CMDLINE_LINUX_DEFAULT="text myvar=aaa"'

    echo $before > $FILE
    grub_cmdline_linux_default_add 'myvar=aaa'

    it_should "add the string to grub param" \
        "grep -q '$expected' $FILE"

    grub_cmdline_linux_default_add 'myvar=aaa'
    grub_cmdline_linux_default_add 'myvar=aaa'

    it_should "add the string to grub param just once" \
        "grep -q '$expected' $FILE"

    it_should "remove the # in the start of the line" \
        "grep -q '^GRUB_CMDLINE_LINUX_DEFAULT' $FILE"
}

test_grub_cmdline_linux_default_delete() {
    local before='GRUB_CMDLINE_LINUX_DEFAULT="text myvar=aaa myvar=bbb var1"'
    local expected='GRUB_CMDLINE_LINUX_DEFAULT="text myvar=bbb var1"'

    echo $before > $FILE
    grub_cmdline_linux_default_delete 'myvar=aaa'

    it_should "delete the string from grub param" \
        "grep -q '$expected' $FILE"
}

test_enable_grub_serial_console() {
    enable_grub_serial_console 115200 tty0 ttyS0

    it_should "set console device kernel variable console=tty0" \
        "grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*console=tty0.*' $FILE"

    it_should "set serial console kernel variable console=ttyS0,115200" \
        "grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*console=ttyS0,115200.*' $FILE"

    it_should "set the variable GRUB_TERMINAL" \
        "grep -q 'GRUB_TERMINAL=\"console serial\"' $FILE"

    it_should "set the variable GRUB_SERIAL_COMMAND" \
        "grep -q 'GRUB_SERIAL_COMMAND=\"serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1\"' $FILE"
}

test_disable_grub_serial_console() {
    enable_grub_serial_console  115200 tty0 ttyS0
    disable_grub_serial_console 115200 tty0 ttyS0

    return_false "grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*console=tty0.*' $FILE"
    return_false "grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*console=ttyS0,115200.*' $FILE"
    return_false "grep -q 'GRUB_TERMINAL=\"console serial\"' $FILE"
    return_false "grep -q 'GRUB_SERIAL_COMMAND=\"serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1\"' $FILE"
}

# load shunit2
source /usr/share/shunit2/shunit2
