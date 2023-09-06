#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include string.sh
include versions.sh

test_replace_version() {
    returns "my-package-0.0.2.tar.gz" \
        "replace_version 0.0.2 my-package-0.0.1.tar.gz"

    returns "my-package.0.0.2.tar.gz" \
        "replace_version 0.0.2 my-package.0.0.1.tar.gz"
}

test_versions_sorted() {
    returns "1.6 1.9 2.3 4.5 7.3 8.9" \
        "versions_sorted 1.9 2.3 4.5 7.3 1.6 8.9 | multiline_to_single_line"
    returns "3.4.14 3.18.5" \
        "versions_sorted 3.4.14 3.18.5 | multiline_to_single_line"
    returns "4.4.25 4.4.38 5.18.5" \
        "versions_sorted 4.4.25 5.18.5 4.4.38 | multiline_to_single_line"
}

test_oldest_version() {
    returns 1.6 "oldest_version 1.9 2.3 4.5 7.3 1.6 8.9"
    returns 3.4.14 "oldest_version 3.4.14 3.18.5"
    returns 4.4.25 "oldest_version 4.4.25 5.18.5 4.4.38"
}

test_newest_version() {
    returns 8.9 "newest_version 1.9 2.3 4.5 7.3 1.6 8.9"
    returns 3.18.5 "newest_version 3.4.14 3.18.5"
    returns 5.18.5 "newest_version 4.4.25 5.18.5 4.4.38"
}

test_previous_version() {
    returns 7.3 "previous_version 8.9 1.9 2.3 4.5 7.3 1.6 8.9"
    returns 4.5 "previous_version 7.3 1.9 2.3 4.5 7.3 1.6 8.9"
    returns 3.4.14 "previous_version 3.18.5 3.4.14 3.4.12 3.3.12 2.4.5 3.18.5"
    returns 3.4.12 "previous_version 3.4.14 3.4.14 3.4.12 3.3.12 2.4.5 3.18.5"
    returns 3.3.12 "previous_version 3.4.12 3.4.14 3.4.12 3.3.12 2.4.5 3.18.5"
    returns 2.4.5 "previous_version 3.3.12 3.4.14 3.4.12 3.3.12 2.4.5 3.18.5"
    returns 2.4.5 "previous_version 3.3.11 3.4.14 3.4.12 3.3.12 2.4.5 3.18.5"
    returns 3.3.12 "previous_version 3.4.11 3.4.14 3.4.12 3.3.12 2.4.5 3.18.5"
    returns_empty "previous_version 2.4.5 3.4.14 3.4.12 3.3.12 2.4.5 3.18.5"
}

test_previous_version_avaliable() {
    return_true "previous_version_avaliable 8.9 1.9 2.3 4.5 7.3 1.6 8.9"
    return_false "previous_version_avaliable 2.4.5 3.4.14 3.4.12 3.3.12 2.4.5 3.18.5"
}

test_versions_are_equal() {
    return_true "versions_are_equal 4.3.7 4.3.7"
    return_false "versions_are_equal 4.3.4 4.3.7"
}

test_version_less_then() {
    return_true "version_less_then 3.4.55 4.3.7"
    return_true "version_less_then 3.4 4.3"
    return_false "version_less_then 4.4 4.3"
    return_false "version_less_then 4.3.7 3.4.55"
    return_false "version_less_then 4.3.7 4.3.7"
}

test_version_greater_then() {
    return_true "version_greater_then 4.3.7 3.4.55"
    return_true "version_greater_then 4.3 3.4"
    return_false "version_greater_then 4.3 4.4"
    return_false "version_greater_then 3.4.55 4.3.7"
    return_false "version_greater_then 4.3.7 4.3.7"
}

# load shunit2
source /usr/share/shunit2/shunit2
