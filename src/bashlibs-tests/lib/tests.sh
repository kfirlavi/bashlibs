include checks.sh
include directories.sh

should_run_tests() {
    false
}

pre_run_tests() {
    vdebug "pre_run_tests is not defined. If you define it, it will run before running all test files"
}

post_run_tests() {
    vdebug "post_run_tests is not defined. If you define it, it will run after running all test files"
}

pre_run_test() {
    local test_file=$1

    vdebug "running pre_run_test before running test $test_file"
    vdebug "pre_run_test is not defined. If you define it, it will run before each test file."
}

post_run_test() {
    local test_file=$1

    vdebug "running post_run_test after running test $test_file"
    vdebug "post_run_test is not defined. If you define it, it will run after each test file."
}

all_tests() {
    find \
        $(tests_dir) \
        -type f \
        -name 'test_*.sh'
}

verify_tests_dir_defined() {
    function_defined tests_dir \
        || eexit "tests_dir must be defined. It should return directory where tests reside"

    function_returns_empty_string tests_dir \
        && eexit "tests_dir should return directory where tests reside"
    
    dir_exist $(tests_dir) \
        || eexit "$(tests_dir) dir does not exits"

    function_returns_empty_string all_tests \
        && eexit "$(tests_dir) does not contain any test files test_*.sh"
}

run_tests_if_needed() {
    local i

    should_run_tests \
        || return

    verify_tests_dir_defined

    pre_run_tests

    for i in $(all_tests)
    do
        pre_run_test $i
        bash $i
        post_run_test $i
    done

    post_run_tests
}

run_tests_if_needed_and_exit() {
    run_tests_if_needed

    should_run_tests \
        && exit
}

stubs_dir() {
    echo $(tests_dir)/files
}
