include verbose.sh

variable_is_in_template() {
    local template=$1
    local variable=$2

    grep -q "@$variable%" $template
}

exit_if_variable_is_not_in_template() {
    local template=$1
    local variable=$2

    variable_is_in_template $template $variable \
        || eexit "variable: '$variable' is not found in template: $template"
}

modify_template() {
    local template=$1; shift
    local variable=$1; shift
    local replace_str=$@

    exit_if_variable_is_not_in_template \
        $template \
        $variable

    vdebug "$FUNCNAME $template '$variable' -> '$replace_str'"

    sed \
        -e "s|@$variable%|$replace_str|g" \
        -i $template
}
