is_empty() {
    local var=$1

    [[ -z $var ]]
}

is_not_empty() {
    local var=$1

    [[ -n $var ]]
}

is_defined() {
    local var=$1

    is_not_empty $var
}

is_not_defined() {
    local var=$1

    is_empty $var
}
