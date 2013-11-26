#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include file_manipulations.sh

oneTimeSetUp() {
    FILE=$(mktemp)
    
    echo "first line" > $FILE
    echo "second line" >> $FILE
    echo "path /a/b/c" >> $FILE
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

test_line_in_file() {
    return_true "line_in_file $FILE first line"
    return_true "line_in_file $FILE second line"
    return_true "line_in_file $FILE path /a/b/c"
    return_false "line_in_file $FILE /a/b/c"
    return_false "line_in_file $FILE path"
    return_false "line_in_file $FILE not in the file"
}

test_add_line_to_file_if_not_exist() {
    local line="not in the file"

    add_line_to_file_if_not_exist $FILE $line
    return_true "line_in_file $FILE $line"

    add_line_to_file_if_not_exist $FILE "first line"
    return_equals 1 "grep --count '^first line$' $FILE"
}

# load shunit2
source /usr/share/shunit2/shunit2
