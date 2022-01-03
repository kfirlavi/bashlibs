#!/bin/bash

default_delimiter() {
    echo '.'
}

date_str() {
    local delimiter=${1:-$(default_delimiter)}

    date +%Y${delimiter}%m${delimiter}%d
}

time_str() {
    local delimiter=${1:-$(default_delimiter)}

    date +%H${delimiter}%M
}

time_with_seconds_str() {
    local delimiter=${1:-$(default_delimiter)}

    date +%H${delimiter}%M${delimiter}%S
}

date_time_str() {
    local delimiter=${1:-$(default_delimiter)}
    local hour_delimiter=${2:-'-'}

    echo $(date_str $delimiter)${hour_delimiter}$(time_str $delimiter)
}

date_time_with_seconds_str() {
    local delimiter=${1:-$(default_delimiter)}
    local hour_delimiter=${2:-'-'}

    echo $(date_str $delimiter)${hour_delimiter}$(time_with_seconds_str $delimiter)
}

date_year() {
    date +%Y
}

date_month() {
    date +%m
}

date_day() {
    date +%d
}

date_to_int() {
    local date_str=$@
    local str=$(echo $date_str | sed 's/\./-/g')

    date -d "$str" +%s
}

date_is_in_the_future() {
    local date_str=$1

    (( $(date_to_int $date_str) > $(date_to_int $(date_str)) ))
}

date_is_in_the_past() {
    local date_str=$1

    (( $(date_to_int $date_str) < $(date_to_int $(date_str)) ))
}

date_is_current() {
    local date_str=$1
    local current_date=$(date_to_int "$(date_str) 00:00:00")

    (( $(date_to_int $date_str) == $current_date ))
}
