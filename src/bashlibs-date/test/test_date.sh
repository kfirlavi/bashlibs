#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include config.sh
include date.sh

date_string_for_testing() {
    echo "2022-02-03 15:30:48"
}

date() {
    local format=$@

    if [[ $format =~ -d ]]
    then
        local date_string=$(echo $format | cut -d '+' -f 1 | sed 's/-d//')
        local f=$(echo $format | cut -d '+' -f 2-)
        TZ="UTC" $(date_binary) -d "$date_string" +$f
    else
        TZ="UTC" $(date_binary) -d "$(date_string_for_testing)" $format
    fi
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

test_date_to_int() {
    returns "1643846400" "date_to_int 2022-02-03"
    returns "1643846400" "date_to_int 2022.02.03"
    returns "1643884980" "date_to_int 2022.02.03 10:43"
    returns "1643885035" "date_to_int 2022.02.03 10:43:55"
    returns "1643846400" "date_to_int 2022.02.03 00:00:00"
}

test_date_is_in_the_future() {
    date_string_for_testing() { echo "2022-02-03"; }

    return_true date_is_in_the_future 2023.01.02
    return_true date_is_in_the_future 2022.03.02
    return_true date_is_in_the_future 2022.02.04

    return_false date_is_in_the_future 2020.02.03
    return_false date_is_in_the_future 2020.02.04
    return_false date_is_in_the_future 2022.01.04
    return_false date_is_in_the_future 2022.02.02
}

test_date_is_in_the_past() {
    return_false date_is_in_the_past 2023.01.02
    return_false date_is_in_the_past 2022.03.02
    return_false date_is_in_the_past 2022.02.04
    return_false date_is_in_the_past 2022.02.03

    return_true date_is_in_the_past 2020.02.04
    return_true date_is_in_the_past 2022.01.04
    return_true date_is_in_the_past 2022.02.02
}

test_date_is_current() {
    return_true date_is_current 2022.02.03

    return_false date_is_current 2020.02.04
    return_false date_is_current 2022.01.04
    return_false date_is_current 2023.02.02
}

# load shunit2
source /usr/share/shunit2/shunit2
