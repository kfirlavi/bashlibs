#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include file_manipulations.sh

oneTimeSetUp() {
    FILE=$(mktemp)
}

oneTimetearDown() {
    [[ -f $FILE ]] \
        && rm -f $FILE
}

setUp() {
	cat<<-EOF > $FILE
	first line
	second line
	path /a/b/c
	abc [xyz=yyy] one two three
	final line
	EOF
}

test_add_line_to_file() {
    local line="last line in file"

    add_line_to_file $FILE $line
    return_true "line_in_file $FILE $line"
}

test_delete_existing_line_from_file() {
    local line="final line"

    delete_line_from_file $FILE $line
    return_false "line_in_file $FILE $line"
}

test_delete_non_existing_line_from_file() {
    local line="this line does not exist"

    delete_line_from_file $FILE $line
    return_false "line_in_file $FILE $line"
}

test_delete_line_from_file_using_pattern() {
    delete_line_from_file_using_pattern \
        $FILE \
        line

    return_false "line_in_file $FILE first line"
    return_false "line_in_file $FILE second line"
    return_true  "line_in_file $FILE path /a/b/c"
    return_true  "line_in_file $FILE abc [xyz=yyy] one two three"
    return_false "line_in_file $FILE final line"
}

test_delete_line_from_file_unix_path_handling() {
    local line="path /a/b/c"

    delete_line_from_file $FILE $line
    return_false "line_in_file $FILE $line"
}

test_line_in_file() {
    return_true "line_in_file $FILE first line"
    return_true "line_in_file $FILE second line"
    return_true "line_in_file $FILE path /a/b/c"
    return_true "line_in_file $FILE abc [xyz=yyy] one two three"
    return_true "line_in_file $FILE final line"
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
