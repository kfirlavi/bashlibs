include verbose.sh
include colors.sh

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

    assertTrue "return value should equal to expected. cmd='$cmd', got='$ret', expected='$expected'" \
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

find_shunit2() {
    local i=

    for i in /usr/share/shunit2 /usr/bin test .
    do
        local lib=$i/shunit2
        [[ -f $lib ]] \
            && export readonly SHUNIT2=$lib
    done
}

run_test() {
        local test_file=$1
        vinfo "Running tests for: $(color purple)$(basename $test_file)$(no_color)"
        clean_library_included
        bash $debug $test_file
}

run_all_tests() {
    local tests_dir=$1
    local test_file

    for test_file in $tests_dir/test_*
    do
        run_test $test_file
    done
}

run_tests() {
    local tests_dir=$1
    local debug=$2 # gets -x for debugging
    local test_file

    export RUN_TESTS
    find_shunit2

    [[ $RUN_TESTS == all ]] \
        && run_all_tests $tests_dir \
        || run_test $tests_dir/$RUN_TESTS
}
