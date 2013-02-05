#!/bin/bash
$(bashlibs --include include.sh)
include shunit2_enhancements.sh
include file_manipulations.sh

oneTimeSetUp() {
    FILE=$(mktemp)
    
    echo "first line" > $FILE
    echo "second line" >> $FILE
    echo "final line" >> $FILE
}

oneTimeTearDown() {
    [[ -f $FILE ]] \
        && rm -f $FILE
}

test_add_line_to_file() {
    local line="last line in file"

    add_line_to_file $FILE $line

    it_should "include the line '$line'" \
        "grep -q '$line' $FILE"
}

test_delete_line_from_file() {
    local line="last line in file"

    delete_line_from_file $FILE $line

    it_shouldnt "include the line '$line'" \
        "grep -q '$line' $FILE"
}

# load shunit2
source /usr/share/shunit2/shunit2
