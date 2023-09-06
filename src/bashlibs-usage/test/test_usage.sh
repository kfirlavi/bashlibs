#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include usage.sh

test_indentation() {
    returns 's e' "echo 's$(indentation 1)e'"
    returns 's  e' "echo 's$(indentation 2)e'"
    returns 's    e' "echo 's$(indentation 4)e'"
    returns 's          e' "echo 's$(indentation 10)e'"
    returns 's          e' "echo 's$(indentation -10)e'"
}

test_item_gap() {
    returns 16 "item_gap '--help'"
    returns 10 "item_gap '--print-data'"
}

test_item_column_indentation_gap() {
    returns 22 "item_column_indentation_gap"

    set_column_indentation_gap 50
    returns 50 "item_column_indentation_gap"

    set_column_indentation_gap 26
}

# load shunit2
source /usr/share/shunit2/shunit2
