#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include nice_header.sh

test_print_ruler() {
    returns "****" \
        "print_ruler '*' 4"

    returns "++++++" \
        "print_ruler '+' 6"
}

test_print_gap() {
    returns "start_gap stop_gap" \
        "echo start_gap$(print_gap 1)stop_gap"

    returns "start_gap          stop_gap" \
        "echo start_gap$(print_gap 10)stop_gap"
}

test_print_header_midline() {
    returns "*    123456789     *" \
        "strip_colors \"$(print_header_midline 123456789 yellow '*' blue 20)\""
    returns "*     1234567890    *" \
        "strip_colors \"$(print_header_midline 1234567890 yellow '*' blue 20)\""
}

# load shunit2
source /usr/share/shunit2/shunit2
