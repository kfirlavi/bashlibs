include string.sh

config_exist() {
    local conf_file=$1

    [[ -f $conf_file ]]
}

all_variables_in_config() {
    local conf_file=$1

    cat $conf_file \
        | remove_bash_comments \
        | delete_edge_spaces \
        | cut -d '=' -f 1 \
        | eol_to_spaces
}

config_value() {
    local conf_file=$1
    local var=$2


    cat $conf_file \
        | remove_bash_comments \
        | delete_edge_spaces \
        | grep "^${var}=" \
        | tail -1 \
        | cut -d '=' -f 2
}

var_to_function() {
    local func_name=$1; shift
    local return_value=$@

    eval "$func_name() { echo \"$return_value\"; }"
}

var_to_true_function() {
    local func_name=$1

    eval "$func_name() { true; }"
}

var_to_false_function() {
    local func_name=$1

    eval "$func_name() { false; }"
}

config_variables_as_functions() {
    local conf_file=$1
    local i

    for i in $(all_variables_in_config $conf_file)
    do
        var_to_function \
            $(echo $i | downcase_str) \
            $(config_value $conf_file $i)
    done
}

load_config_if_exist() {
    local conf_file=$1

    config_exist $conf_file \
        && source $conf_file \
        && config_variables_as_functions $conf_file
}

load_config() {
    local conf_file=$1

    load_config_if_exist $conf_file \
        || eexit "$conf_file does not exist"
}
