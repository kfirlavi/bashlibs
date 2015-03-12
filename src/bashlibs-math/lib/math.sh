#!/bin/bash

min() {
    local column=$1
    local datafile=$2

    awk "BEGIN {min=9999999999} {if (\$$column<min) min=\$$column} END {print min}" $datafile
}

max() {
    local column=$1
    local datafile=$2

    awk "BEGIN {max=0} {if (\$$column>max) max=\$$column} END {print max}" $datafile
}

average() {
    local column=$1
    local datafile=$2

    awk "{ total += \$$column} END { print total/NR }" $datafile
}
