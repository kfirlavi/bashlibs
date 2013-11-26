#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include date.sh

test_date_str() {
    returns "$(date +%Y.%m.%d)" \
        "date_str"
}

test_time_str() {
    returns "$(date +%H.%M)" \
        "time_str"
}

test_time_with_seconds_str() {
    returns "$(date +%H.%M.%S)" \
        "time_with_seconds_str"
}

test_date_time_str() {
    returns "$(date +%Y.%m.%d-%H.%M)" \
        "date_time_str"
}

test_date_time_with_seconds_str() {
    returns "$(date +%Y.%m.%d-%H.%M.%S)" \
        "date_time_with_seconds_str"

    returns "$(date +%Y_%m_%d-%H_%M_%S)" \
        "date_time_with_seconds_str '_'"

    returns "$(date +%Y_%m_%d_%H_%M_%S)" \
        "date_time_with_seconds_str '_' '_'"
}

# load shunit2
source /usr/share/shunit2/shunit2
