#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include string.sh

test_column() {
    return_equals "one"   "echo one two three | column 1"
    return_equals "two"   "echo one two three | column 2"
    return_equals "three" "echo one  two    three | column 3"

    return_equals "one"   "echo '  one two three   ' | column 1"
    return_equals "three"   "echo '  one two three   ' | column 3"

    returns_empty "echo | column 3"
}

test_split_by() {
    return_equals "a"   "echo 'a-b' | split_by '-' 1"
    return_equals "a"   "split_by '-' 1 'a-b'"
    return_equals "b"   "echo 'a-b' | split_by '-' 2"
    return_equals "b"   "split_by '-' 2 'a-b'"
    returns_empty "echo 'a-' | split_by '-' 2"
}

test_csv_column() {
    return_equals "one"     "echo 'one,two,three' | csv_column 1"
    return_equals " one"     "echo ' one,two,three' | csv_column 1"
    return_equals "  two  " "echo 'one,  two  ,  three , ' | csv_column 2"
    return_equals " three"  "echo ' ,   two   , three' | csv_column 3"
    return_equals " three    "  "echo ',two, three    ' | csv_column 3"
    returns_empty "echo | csv_column 3"
}

test_colons_to_spaces() {
    return_equals "one two three" "echo 'one:two:three' | colons_to_spaces"
    return_equals " one   two     three  " "echo ' one  :two :   three  ' | colons_to_spaces"
}

test_eol_to_spaces() {
    return_equals "line1 line2" "echo -e 'line1\nline2' | eol_to_spaces"
}

test_delete_spaces() {
    returns_empty "echo '  ' | delete_spaces"
    return_equals "abcd" "echo '  a  b c d   ' | delete_spaces"
}

test_truncate_duplicate_spaces() {
    return_equals " " "echo '  ' | truncate_duplicate_spaces"
    return_equals " one two " "echo '  one    two   ' | truncate_duplicate_spaces"
}

test_apostrophes_to_spaces() {
    return_equals "   " "echo \"'''\" | apostrophes_to_spaces"
    return_equals " " "echo \"'\" | apostrophes_to_spaces"
    return_equals "one " "echo \"one'\" | apostrophes_to_spaces"
    return_equals "a b c" "echo \"a'b'c\" | apostrophes_to_spaces"
}

test_commas_to_spaces() {
    return_equals "   " "echo ',,,' | commas_to_spaces"
    return_equals "a b     " "echo 'a,b   , ' | commas_to_spaces"
    return_equals " a    b    " "echo ' a   ,b   ,' | commas_to_spaces"
}

test_underscores_to_spaces() {
    return_equals "my test string" "echo 'my_test_string' | underscores_to_spaces"
    return_equals "   " "echo '___' | underscores_to_spaces"
    return_equals "a b     " "echo 'a_b   _ ' | underscores_to_spaces"
    return_equals " a    b    " "echo ' a   _b   _' | underscores_to_spaces"
}

test_dash_to_spaces() {
    return_equals "my test string" "echo 'my-test-string' | dash_to_spaces"
    return_equals "   " "echo '---' | dash_to_spaces"
    return_equals "a b     " "echo 'a-b   - ' | dash_to_spaces"
    return_equals " a    b    " "echo ' a   -b   -' | dash_to_spaces"
}

test_dash_to_underscore() {
    return_equals "my_test_string" "echo 'my-test-string' | dash_to_underscore"
    return_equals "___" "echo '---' | dash_to_underscore"
    return_equals "a_b   _ " "echo 'a-b   - ' | dash_to_underscore"
    return_equals " a   _b   _" "echo ' a   -b   -' | dash_to_underscore"
}

test_dot_to_spaces() {
    return_equals "my test string" "echo 'my.test.string' | dot_to_spaces"
    return_equals "   " "echo '...' | dot_to_spaces"
    return_equals "a b     " "echo 'a.b   . ' | dot_to_spaces"
    return_equals " a    b    " "echo ' a   .b   .' | dot_to_spaces"
}

test_dot_to_underscore() {
    return_equals "my_test_string" "echo 'my.test.string' | dot_to_underscore"
    return_equals "___" "echo '...' | dot_to_underscore"
    return_equals "a_b   _ " "echo 'a.b   . ' | dot_to_underscore"
    return_equals " a   _b   _" "echo ' a   .b   .' | dot_to_underscore"
}

test_spaces_to_underscore() {
    return_equals "abc_efg" "echo 'abc efg' | spaces_to_underscore"
    return_equals "_abc_efg_" "echo ' abc efg ' | spaces_to_underscore"
    return_equals "__" "echo '  ' | spaces_to_underscore"
}

test_spaces_to_newlines() {
    return_equals "abc" "echo 'abc efg' | spaces_to_newlines | head -1"
    return_equals "efg" "echo 'abc efg' | spaces_to_newlines | tail -1"
}

test_tabs_to_spaces() {
    return_equals " " "echo -e '\t' | tabs_to_spaces"
    return_equals "    " "echo -e ' \t\t ' | tabs_to_spaces"
    return_equals " " "echo -e ' ' | tabs_to_spaces"
    return_equals "  local" "echo -e '\t\tlocal' | tabs_to_spaces"
}

test_delete_edge_spaces() {
    return_equals "a" "echo ' a ' | delete_edge_spaces"
    return_equals "a b" "echo '   a b  ' | delete_edge_spaces"
    return_equals "string with	 tabs" "echo '		   string with	 tabs  			  ' | delete_edge_spaces"
    returns_empty "echo '   ' | delete_edge_spaces"
    returns_empty "echo '  ' | delete_edge_spaces"
    returns_empty "echo ' ' | delete_edge_spaces"
    returns_empty "echo '' | delete_edge_spaces"
}

test_string_inside_quotes() {
    return_equals "abc" "echo '\"abc\"' | string_inside_quotes"
    return_equals " abc " "echo '\" abc \"' | string_inside_quotes"
    return_equals "a" "echo 'b \"a\" c' | string_inside_quotes"
    return_equals "a line of" "echo 'this is \"a line of\" example' | string_inside_quotes"
}

test_string_inside_tags() {
    return_equals "abc" "echo 'abc' | string_inside_tags"
    return_equals " abc " "echo ' abc ' | string_inside_tags"
    return_equals 'this is "a line of" example' "echo 'this is \"a line of\" example' | string_inside_tags"
}

test_str_to_camelcase() {
    return_equals "Abc"    "echo 'abc'            | str_to_camelcase"
    return_equals "Abc"    "echo 'Abc'            | str_to_camelcase"
    return_equals "AbcDef" "echo 'abc def'        | str_to_camelcase"
    return_equals "AbcDef" "echo 'abc_def'        | str_to_camelcase"
    return_equals "AbcDef" "echo 'abc-_-def--___' | str_to_camelcase"
}

test_every_word_to_camelcase() {
    return_equals "Abc"         "echo 'abc'         | every_word_to_camelcase"
    return_equals "Abc"         "echo 'Abc'         | every_word_to_camelcase"
    return_equals "Abc Def"     "echo 'abc def'     | every_word_to_camelcase"
    return_equals "Abc_def Abc" "echo 'abc_def abc' | every_word_to_camelcase"
    return_equals "Abc-Def"     "echo 'abc-def'     | every_word_to_camelcase"
}

test_upcase_str() {
    return_equals "ABC"     "echo 'abc'     | upcase_str"
    return_equals "ABC"     "echo 'Abc'     | upcase_str"
    return_equals "ABC DEF" "echo 'abc def' | upcase_str"
}

test_downcase_str() {
    return_equals "abc"     "echo 'ABC'     | downcase_str"
    return_equals "abc"     "echo 'Abc'     | downcase_str"
    return_equals "abc def" "echo 'AbC DEF' | downcase_str"
}

test_remove_bash_comments() {
	cat<<-EOF > /tmp/before
	# just a comment
	VAR_IN_CONF_FILE=123

	    STRING_VAR="The variable value is 222" # and a comment
		   STRING_VAR="The variable value is 333" 	   # and a comment
	    STRING_VAR="The variable value is 555"# and a comment
	    STRING_VAR="The variable value is 666"#and a comment

	   # another comment with COMMMENT_VAR=444
	EOF

	cat<<-EOF > /tmp/correct
	VAR_IN_CONF_FILE=123

	    STRING_VAR="The variable value is 222"
		   STRING_VAR="The variable value is 333"
	    STRING_VAR="The variable value is 555"
	    STRING_VAR="The variable value is 666"

	EOF

    cat /tmp/before | remove_bash_comments > /tmp/after

    files_should_equal /tmp/correct /tmp/after

#    rm -f /tmp/{before,correct,after}
}

test_str_len() {
    returns 0 "str_len"
    returns 1 "str_len a"
    returns 8 "str_len run wild"
    returns 9 "str_len run wild\n"
    returns 10 "str_len 'run wild\n'"
    returns 2 "str_len '\n'"
    returns 1 "str_len \n"
    returns 4 "str_len '$(no_color)'"
    returns 7 "str_len '$(color red)'"
    returns 9 "str_len '$(color red)\n'"
    returns 16 "str_len '$(color red)\n$(color blue)'"
    returns 22 "str_len '$(color red)\n$(color blue)\n$(no_color)'"
    returns 49 "str_len '$(color red)with actual\n$(color blue)\nwords and spaces$(no_color)'"
}

test_str_without_escape_chars() {
    returns "abc" "str_without_escape_chars abc"
    returns "abc" "str_without_escape_chars 'abc\n'"
    returns "abc" "str_without_escape_chars '$(color red)abc'"
}

test_text_width() {
    returns 0 "text_width"
    returns 0 "text_width '\n'"
    returns 0 "text_width '$(color red)'"
    returns 0 "text_width '$(color red)\n'"
    returns 0 "text_width '$(color red)\n$(color blue)'"
    returns 0 "text_width '$(color red)\n$(color blue)\n$(no_color)'"

    returns 3 "text_width run"
    returns 8 "text_width run fast"
    returns 24 "text_width run fast\nthen run again\n"
    returns 8 "text_width '$(color white)run fast$(no_color)'"
    returns 8 "text_width '$(color white)run fast$(no_color)\n'"
    returns 8 "text_width '$(color white)run fast$(no_color)\nrun'"
    returns 14 "text_width '$(color white)run fast$(no_color)\nthen $(color red)run$(no_color) again\n'"
    returns 9 "text_width '1234 6789 \n123\n 3 4 5\n   444  \n'"
}

test_text_hight() {
    returns 0 "text_hight"
    returns 2 "text_hight '\n'"
    returns 2 "text_hight '$(color red)\n'"
    returns 3 "text_hight '$(color red)\n$(color blue)\n$(no_color)'"

    returns 1 "text_hight run"
    returns 1 "text_hight run fast"
    returns 3 "text_hight run 'fast\nthen run again\n'"
    returns 1 "text_hight '$(color white)run fast$(no_color)'"
    returns 2 "text_hight '$(color white)run fast$(no_color)\n'"
    returns 2 "text_hight '$(color white)run fast$(no_color)\nrun'"
    returns 3 "text_hight '$(color white)run fast$(no_color)\nthen $(color red)run$(no_color) again\n'"
    returns 5 "text_hight '1234 6789 \n123\n 3 4 5\n   444  \n'"
}

test_multiline_to_single_line() {
    returns "single line" "echo 'single line' | multiline_to_single_line"
    returns "line1  line2 line 3" "echo -e ' line1\n line2\nline 3\n' | multiline_to_single_line"
}


# load shunit2
source /usr/share/shunit2/shunit2
