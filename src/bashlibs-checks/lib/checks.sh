function_defined() {
    local func_name=$1

    [[ $(type -t $func_name) == function ]]
}

function_not_defined() {
    local func_name=$1

    [[ $(type -t $func_name) != function ]]
}
