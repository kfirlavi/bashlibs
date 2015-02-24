include colors.sh
include code_clarity.sh

header() {
    local str=$@

    echo -en "$(color yellow)$str$(no_color)"
}

section_usage() {
	echo -en $(header Usage:)
}

section_options() {
	echo -en $(header Options:)
}

section_examples() {
	echo -en $(header Examples:)
}

indentation() {
    local num_of_spaces=${1:-4}

    printf "%${num_of_spaces}s"
}

set_column_indentation_gap() {
    _SINGELTON_GAP=$1
}

item_column_indentation_gap() {
    is_defined $_SINGELTON_GAP \
        && echo $_SINGELTON_GAP \
        || echo 22
}

item_gap() {
    local str=$@
    local str_length=${#str}
    local gap=$(($(item_column_indentation_gap) - str_length))

    (( 0 >= $gap )) \
        && echo 1 \
        || echo $gap
}

item() {
    local short_param=$1; shift
    local long_param=$1; shift
    local str=$@

    [[ $short_param == none ]] \
        && local param_str="   --$long_param" \
        || local param_str="-$short_param --$long_param"

    indentation
    echo -en "$(color cyan)$param_str$(no_color)"
    indentation $(item_gap $long_param)
    echo -en "$str"
}

example() {
    local str=$@

    indentation
    echo -en "$(color white)$str$(no_color)"
}

example_description() {
    local str=$@

    indentation
    echo -en "$str"
}

item_test() {
    item t test \
        "Run test suit to check vtestbed. Get a test file name or the 'all' to run all tests."
}

example_test() {
    local progname=$1
    
	cat <<- EOF
	$(example_description 'Run all unit tests')
	$(example $progname -t all)
	$(example $progname --test all)
	    
	$(example_description 'Run one unit test file (good for development stage):')
	$(example $progname --test test_vm_ip.sh)
	EOF
}

item_no_color() {
    item none no-color 'do not print colors'
}

item_help() {
    item h help 'Show this message'
}

item_verbose() {
    item v verbose 'Verbose. You can specify more then one -v to have more verbose'
}

item_debug() {
    item x debug 'Turn on bash -x flag'
}

items_test_help_verbose_debug() {
    local progname=$1
    
	cat <<- EOF
	$(item_test)
	$(item_help)
	$(item_no_color)
	$(item_verbose)
	$(item_debug)
	EOF
}

print_usage_and_exit_if_args_are_empty() {
    local args=$@

    [[ -z $args ]] \
        && usage \
        && exit
}
