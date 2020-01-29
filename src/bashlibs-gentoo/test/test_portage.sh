#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include portage.sh

emerge_info() {
    cat $(libraries_tests_dir)/files/emerge_info.txt
}

test_emerge_info_vars() {
    return_value_should_include "MAKEOPTS=" \
        "emerge_info_vars"

    return_value_should_include "PORTAGE_BINHOST=" \
        "emerge_info_vars"

    return_value_shouldnt_include '^dev-lang/perl' \
        "emerge_info_vars"

    return_value_shouldnt_include '^Repositories' \
        "emerge_info_vars"
}

test_emerge_info_var_line() {
    returns 'PORTAGE_BINHOST="http://testhost/gentoo/packages"' \
        "emerge_info_var_line PORTAGE_BINHOST"
}

test_emerge_info_var_value() {
    returns 'http://testhost/gentoo/packages' \
        "emerge_info_var_value PORTAGE_BINHOST"
}

test_emerge_info_vars_to_functions() {
    emerge_info_vars_to_functions

    function_should_be_defined emerge_env_portage_binhost
    function_should_be_defined emerge_env_accept_keywords
    function_should_be_defined emerge_env_features

    returns 'http://testhost/gentoo/packages' \
        "emerge_env_portage_binhost"

    returns 'amd64' \
        "emerge_env_accept_keywords"

    return_value_should_include "assume-digests" \
        "emerge_env_features"

    return_value_should_include "pid-sandbox preserve-libs" \
        "emerge_env_features"
}

# load shunit2
source /usr/share/shunit2/shunit2
