#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include colors.sh

test_to_upper() {
    returns ALL_LOWER "to_upper all_lower"
    returns PARTIAL_UPPER "to_upper PARTIAL_upper"
    returns ALREADY_UPPER "to_upper ALREADY_UPPER"
}

test_spaces_to_underscors() {
    returns light_blue "spaces_to_underscors light blue"
    returns light_blue "spaces_to_underscors light      blue"
}

test_strip_colors() {

    returns "*12345*" \
        "strip_colors \"$(color blue)*$(color yellow)12345$(color green)*$(no_color)\""
}

#test_color() {
#    returns '\033[0;34m' "color blue"
#}

# load shunit2
source /usr/share/shunit2/shunit2
