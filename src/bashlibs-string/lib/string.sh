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

    IFS= read -r
    echo "$REPLY" \
        | cut -d ',' -f $column
}

colons_to_spaces() {
    IFS= read -r
    echo "$REPLY" \
        | sed 's/:/ /g'
}

eol_to_spaces() {
    IFS= 
    while read -r
    do
        echo "$REPLY" \
            | tr '\n' ' '
    done \
        | delete_edge_spaces
}

delete_spaces() {
    IFS= read -r
    echo "$REPLY" \
        | sed 's/ //g'
}

truncate_duplicate_spaces() {
    IFS= read -r
    echo "$REPLY" \
        | sed 's/[ ][ ]*/ /g'
}

apostrophes_to_spaces() {
    IFS= read -r
    echo "$REPLY" \
        | sed s/"'"/" "/g
}

commas_to_spaces() {
    IFS= read -r
    echo "$REPLY" \
        | sed 's/,/ /g'
}

underscores_to_spaces() {
    IFS= read -r
    echo "$REPLY" \
        | sed 's/_/ /g'
}

tabs_to_spaces() {
    IFS= read -r
    echo "$REPLY" \
        | sed 's/[\t]/ /g'
}

delete_edge_spaces() {
    IFS= read -r
    echo "$REPLY" \
        | sed 's/^[ ][ ]*//' \
        | sed 's/[ ][ ]*$//'
}

string_inside_quotes() {
    IFS= read -r
    echo "$REPLY" \
        | sed 's/.*"\(.*\)".*/\1/'
}
