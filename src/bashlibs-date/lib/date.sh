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
