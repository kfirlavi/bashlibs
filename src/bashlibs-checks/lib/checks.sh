function_defined() {
    local func_name=$1

    [[ $(type -t $func_name) == function ]]
}

function_not_defined() {
    local func_name=$1

    [[ $(type -t $func_name) != function ]]
}

file_exist() {
    local file=$1

    [[ -f $file ]]
}

file_dont_exist() {
    local file=$1

    [[ ! -f $file ]]
}
