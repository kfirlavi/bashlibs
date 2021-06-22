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

test_date_year() {
    returns "$(date +%Y)" \
        "date_year"
}

test_date_month() {
    returns "$(date +%m)" \
        "date_month"
}

test_date_day() {
    returns "$(date +%d)" \
        "date_day"
}

# load shunit2
source /usr/share/shunit2/shunit2
