include colors.sh

VINFO=1
VDEBUG=2

verbose() {
	local strength=$1; shift
    local str=$@

    [[ $strength == $VINFO ]] \
        && vinfo $str

    [[ $strength == $VDEBUG ]] \
        && vdebug $str
}

eexit() {
	verror "$@"
	exit 1
}

eerror() { 
    verror $@
}

einfo() { 
    vinfo $@
}

turn_verbose_colors_off() {
    VERBOSE_IN_COLORS=
}

turn_verbose_colors_on() {
    VERBOSE_IN_COLORS=1
}

colors_are_on() {
    [[ -n $VERBOSE_IN_COLORS ]]
}

vout() {
    local color=$1; shift
    local level=$1; shift
    local str=$@

    colors_are_on \
        && echo -e "$(color $color)$level: $(no_color)$str" \
        || echo "$level: $str"
}

vinfo() {
    vout cyan Info $@
}

vdebug() {
    vout blue Debug $@
}

vwarning() {
    vout yellow Warning $@
}

verror() {
    vout red Error $@
}

vcritical() {
    vout purple Critical $@
}

turn_verbose_colors_on
