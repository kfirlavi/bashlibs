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

file_is_empty() {
    local file=$1

    [[ -z $(cat $file) ]]
}

variable_defined() {
    local var_name=$1

    [[ -v $var_name ]]
}

variable_not_defined() {
    local var_name=$1

    [[ ! -v $var_name ]]
}

functions_not_defined() {
    local function_names=$@
    local f
    local i
    
    for i in $function_names
    do
        function_not_defined $i \
            && f+="$i "
    done

    echo $f
}

eexit_if_functions_not_defined() {
    local function_names=$@
    local non_defined=$(functions_not_defined $function_names)
    
    [[ -z $non_defined ]] \
        || eexit "This functions must be defined: $(color red)${non_defined}$(no_color)"
}

function_returns_empty_string() {
    local func_name=$1

    [[ -z $($func_name) ]]
}

function_returns_non_empty_string() {
    local func_name=$1

    [[ -n $($func_name) ]]
}

function_returns_true() {
    local func_name=$1

    $func_name > /dev/null 2>&1
}

function_returns_false() {
    local func_name=$1

    ! function_returns_true $func_name
}
