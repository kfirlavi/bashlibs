include verbose.sh
include string.sh
include checks.sh

config_exist() {
    local conf_file=$1

    [[ -f $conf_file ]]
}

all_variables_in_config() {
    local conf_file=$1

    cat $conf_file \
        | remove_bash_comments \
        | delete_edge_spaces \
        | grep '=' \
        | cut -d '=' -f 1 \
        | eol_to_spaces
}

config_value() {
    local var=$1

    eval echo \$$var
}

var_to_function() {
    local func_name=$1; shift
    local return_value=$@

    case $return_value in
        true) var_to_true_function $func_name ;;
       false) var_to_false_function $func_name ;;
           *) eval "$func_name() { echo \"$return_value\"; }" ;;
    esac
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
    local function_name_prefix=$2
    local i

    for i in $(all_variables_in_config $conf_file)
    do
        var_to_function \
            $(echo $function_name_prefix$i | downcase_str) \
            $(config_value $i)
    done
}

load_config_if_exist() {
    local conf_file=$1
    local function_name_prefix=$2

    config_exist $conf_file \
        && source $conf_file \
        && config_variables_as_functions $conf_file $function_name_prefix \
        && vdebug "configuration file loaded: $conf_file"
}

load_config() {
    local conf_file=$1
    local function_name_prefix=$2

    load_config_if_exist $conf_file $function_name_prefix \
        || eexit "$conf_file does not exist"
}

verify_config_varialbes_defined() {
    local conf_file=$1; shift
    local var_names=$@

    local i
    for i in $var_names
    do
        variable_defined $i \
            || eexit "$i should be defined in $conf_file"
    done
}

load_config_variable() {
    local var_name=$1; shift
    local value=$@

    eval "$var_name=\"$value\""

    var_to_function \
            $(echo $var_name | downcase_str) \
            $value
}

unload_config_variable() {
    local var_name=$1

    unset $var_name

    unset -f $(echo $var_name | downcase_str)
}
