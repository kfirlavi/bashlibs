#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include bake_test.sh

test_package_is_bashlib() {
    return_true  "package_is_bashlib bashlibs-test"
    return_true  "package_is_bashlib bashlibs-test-bashlibs"
    return_true  "package_is_bashlib bashlibs-test-test"
    return_false "package_is_bashlib bash-test"
    return_false "package_is_bashlib bashbuild-test"
    return_false "package_is_bashlib bashlibs"
    return_false "package_is_bashlib test-test"
}

# load shunit2
source /usr/share/shunit2/shunit2
