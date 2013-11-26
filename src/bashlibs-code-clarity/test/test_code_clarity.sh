#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include code_clarity.sh

test_is_empty() {
	return_true "is_empty $none_variable"

    local var1
	return_true "is_empty $var1"

    local var2="str"
	return_false "is_empty $var2"

    local var2=""
	return_true "is_empty $var2"
}

test_is_not_empty() {
	return_false "is_not_empty $none_variable"

    local var1
	return_false "is_not_empty $var1"

    local var2="str"
	return_true "is_not_empty $var2"

    local var2=""
	return_false "is_not_empty $var2"
}

test_is_defined() {
	return_false "is_defined $none_variable"

    local var1
	return_false "is_defined $var1"

    local var2="str"
	return_true "is_defined $var2"

    local var2=""
	return_false "is_defined $var2"
}

test_is_not_defined() {
	return_true "is_not_defined $none_variable"

    local var1
	return_true "is_not_defined $var1"

    local var2="str"
	return_false "is_not_defined $var2"

    local var2=""
	return_true "is_not_defined $var2"
}

# load shunit2
source /usr/share/shunit2/shunit2
