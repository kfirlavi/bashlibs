include verbose.sh
include colors.sh
include checks.sh

it_should() {
    assertTrue "It should $1" "$2"
}

it_shouldnt() {
    assertFalse "It shouldnt $1" "$2"
}

it_can() {
    assertTrue "It can $1" "$2"
}

it_cannt() {
    assertFalse "It cannt $1" "$2"
}

value_should_be() {
    local variable_name=$1
    local should_be=$2

    local value=$(eval echo $(echo \$$variable_name))

    assertTrue \
        "$variable_name should equal $should_be, but it is $variable_name=$value" \
        "[[ $value == $should_be ]]"
}

return_should() {
    assertTrue "It should $1" "$2"
}

return_shouldnt() {
    assertFalse "It shouldnt $1" "$2"
}

it_should_return() {
    assertTrue "It should return $1" "$2"
}

it_shouldnt_return() {
    assertFalse "It shouldnt return $1" "$2"
}

it_should_exit_with_error() {
    local cmd="$@"

    ($cmd) > /dev/null 2>&1
    local ret=$?
    it_should "exit with error $1 but got '($cmd)' return value=$ret" \
        "[[ $ret > 0 ]]"
}

return_true() {
    local cmd="$@"

    assertTrue "should return true. Command='$cmd'" "$cmd"
}

return_false() {
    local cmd="$@"

    assertFalse "should return false. Command='$cmd'" "$cmd"
}

returns() {
    return_equals "$1" "$2"
}

return_equals() {
    local expected=$1
    local cmd=$2
    local ret=$(eval "$cmd")

    assertTrue "return value should equal to expected. cmd='$cmd', got='$ret', expected='$expected'. Escaped strings: got: '$(printf \"%q\" \"$expected\")' expected: '$(printf \"%q\" \"$expected\")'
" \
        "[[ '$expected' == '$ret' ]]"
}

return_value_shouldnt_equal() {
    local expected=$1
    local cmd=$2
    local ret=$(eval $cmd)

    assertTrue "return value should not equal to expected. cmd='$cmd', got='$ret', expected='$expected'" \
        "[[ '$expected' != '$ret' ]]"
}

return_value_should_include() {
    local expected=$1
    local cmd=$2
    local ret=$(eval $cmd)

    assertTrue "return value should include expected. cmd='$cmd', got='$ret', expected='$expected'" \
        "echo '$ret' | grep -q '$expected'"
}

returns_empty() {
    local cmd=$1
    local ret=$(eval $cmd)

    assertTrue "return value should be empty. cmd='$cmd', got='$ret'" \
        "[[ '$ret' == '' ]]"
}

return_value_shouldnt_include() {
    local expected=$1
    local cmd=$2
    local ret=$(eval $cmd)

    assertFalse "return value should not include expected. cmd='$cmd', got='$ret', expected='$expected'" \
        "echo '$ret' | grep -q '$expected'"
}

files_should_equal() {
    local file_a=$1 ;shift
    local file_b=$1 ;shift
    local extra_diff_parameters=$@

    diff \
        $extra_diff_parameters \
        $file_a \
        $file_b

	assertTrue "Files do not match! $file_a $file_b" $?
}

file_should_exist() {
    local f=$1

    assertTrue \
        "file should exist $f" \
        "[[ -f $f ]]"
}

file_shouldnt_exist() {
    local f=$1

    assertFalse \
        "file shouldn't exist $f" \
        "[[ -f $f ]]"
}

file_should_be_empty() {
    local f=$1

    assertFalse \
        "file should be empty $f" \
        "[[ -s $f ]]"
}

file_shouldnt_be_empty() {
    local f=$1

    assertTrue \
        "file should not be empty $f" \
        "[[ -s $f ]]"
}

file_access_rights_should_be() {
    local access_rights_in_octal=$1
    local f=$2
    local file_access_rights=$(stat --format '%a' $f)

    assertTrue \
        "file $f access rights are $file_access_rights, and they should be $access_rights_in_octal" \
        "[[ $access_rights_in_octal == $file_access_rights ]]"
}

directory_should_exist() {
    local d=$1

    assertTrue \
        "directory should exist $d" \
        "[[ -d $d ]]"
}

directory_shouldnt_exist() {
    local d=$1

    assertFalse \
        "directory should exist $d" \
        "[[ -d $d ]]"
}

directory_should_be_empty() {
    local d=$1

    assertFalse \
        "directory is not empty $d" \
        "[[ -z $(ls --almost-all $d) ]]"
}

var_should_be_defined() {
    local variable_name=$1
    local value=$(eval echo $(echo \$$variable_name))

    assertTrue \
        "variable '$variable_name' should be defined" \
        "[[ -n '$value' ]]"
}

var_is_not_defined() {
    local variable_name=$1
    local value=$(eval echo $(echo \$$variable_name))

    assertFalse \
        "variable '$variable_name' should not be defined" \
        "[[ -n '$value' ]]"
}

var_equal() {
    local variable_name=$1
    local should_be_value=$2
    local value=$(eval echo $(echo \$$variable_name))

    assertTrue \
        "variable '$variable_name' value should be '$should_be_value' but is '$value'" \
        "[[ '$value' == '$should_be_value' ]]"
}

function_should_be_defined() {
    local func_name=$1

    assertTrue \
        "function '$func_name' should be defined" \
        "function_defined $func_name"
}

create_temp_file() {
    local func_name=$1
    local tmpf=$(mktemp)

    eval "$func_name() { echo $tmpf; }"
}

delete_temp_file() {
    local func_name=$1
    local tmpf=$(eval $func_name)

    [[ -f $tmpf ]] \
        && rm -f $tmpf
}

find_shunit2() {
    local i=

    for i in /usr/share/shunit2 /usr/bin test .
    do
        local lib=$i/shunit2
        [[ -f $lib ]] \
            && export readonly SHUNIT2=$lib
    done
}

test_files() {
    local tests_dir=$1
    local pattern=${2:-'test_*'}

    find $tests_dir \
        -type f \
        -name "*$pattern*"
}

test_debugging() {
    echo -n
}

set_test_debugging() {
    local debug=$1

    [[ -z $debug ]] \
        && return

    test_debugging() { echo -x; }
}

test_name() {
    local test_file=$1

    basename $test_file \
        | sed 's/test_//' \
        | sed 's/.sh$//'
}

run_test() {
    local test_file=$1

    vinfo "Running tests for: $(color purple)$(test_name $test_file)$(no_color)"

    clean_library_included
    bash $(test_debugging) $test_file
}

run_tests_by_pattern() {
    local tests_dir=$1
    local pattern=$2
    local i

    [[ -d $tests_dir/$pattern ]] \
        && tests_dir=$tests_dir/$pattern \
        && pattern=

    for i in $(test_files $tests_dir $pattern)
    do
        run_test $i $debug
    done
}

run_tests() {
    local tests_dir=$1
    local debug=$2 # gets -x for debugging

    set_test_debugging $debug

    export RUN_TESTS
    find_shunit2

    set_verbose_level_to_info

    [[ $RUN_TESTS == all ]] \
        && run_tests_by_pattern $tests_dir \
        || run_tests_by_pattern $tests_dir $RUN_TESTS
}
