column() {
    local column=$1
    local input

    IFS=
    read -r input
    echo "$input" \
        | awk "{print \$$column}"
}

split_by() {
    local delimiter=$1
    local column=$2
    REPLY=$3

    [[ -z $REPLY ]] \
        && IFS= read -r

    echo "$REPLY" \
        | awk -F$delimiter "{print \$$column}"
}

csv_column() {
    local column=$1

    cat /dev/stdin \
        | cut -d ',' -f $column
}

colons_to_spaces() {
    cat /dev/stdin \
        | sed 's/:/ /g'
}

eol_to_spaces() {
    cat /dev/stdin \
        | tr '\n' ' ' \
        | delete_edge_spaces
}

delete_spaces() {
    cat /dev/stdin \
        | sed 's/ //g'
}

truncate_duplicate_spaces() {
    cat /dev/stdin \
        | sed 's/[ ][ ]*/ /g'
}

apostrophes_to_spaces() {
    cat /dev/stdin \
        | sed s/"'"/" "/g
}

commas_to_spaces() {
    cat /dev/stdin \
        | sed 's/,/ /g'
}

underscores_to_spaces() {
    cat /dev/stdin \
        | sed 's/_/ /g'
}

dash_to_spaces() {
    cat /dev/stdin \
        | sed 's/-/ /g'
}

dash_to_underscore() {
    cat /dev/stdin \
        | sed 's/-/_/g'
}

tabs_to_spaces() {
    cat /dev/stdin \
        | sed 's/[\t]/ /g'
}

delete_edge_spaces() {
    cat /dev/stdin \
        | sed 's/^[[:space:]][[:space:]]*//' \
        | sed 's/[[:space:]][[:space:]]*$//'
}

string_inside_quotes() {
    cat /dev/stdin \
        | sed 's/.*"\(.*\)".*/\1/'
}

str_to_camelcase() {
    cat /dev/stdin \
        | underscores_to_spaces \
        | dash_to_spaces \
        | sed -e 's/\b\(.\)/\u\1/g' \
        | delete_spaces
}

upcase_str() {
    cat /dev/stdin \
        | awk '{print toupper($0)}'
}

downcase_str() {
    cat /dev/stdin \
        | awk '{print tolower($0)}'
}

remove_bash_comments() {
    cat /dev/stdin \
        | sed -e 's/#.*$//'
}
