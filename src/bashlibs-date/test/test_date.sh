#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include config.sh
include date.sh

date() {
    local format=$@

    $(date_binary) -d "2022-02-03 15:30:48" $format
}

oneTimeSetUp() {
    var_to_function date_binary $(which date)
}

test_date_str() {
    returns "2022.02.03" \
        "date_str"
}

test_time_str() {
    returns "15.30" \
        "time_str"
}

test_time_with_seconds_str() {
    returns "15.30.48" \
        "time_with_seconds_str"
}

test_date_time_str() {
    returns "2022.02.03-15.30" \
        "date_time_str"
}

test_date_time_with_seconds_str() {
    returns "2022.02.03-15.30.48" \
        "date_time_with_seconds_str"

    returns "2022_02_03-15_30_48" \
        "date_time_with_seconds_str '_'"

    returns "2022_02_03_15_30_48" \
        "date_time_with_seconds_str '_' '_'"
}

test_date_year() {
    returns "2022" \
        "date_year"
}

test_date_month() {
    returns "02" \
        "date_month"
}

test_date_day() {
    returns "03" \
        "date_day"
}

# load shunit2
source /usr/share/shunit2/shunit2
