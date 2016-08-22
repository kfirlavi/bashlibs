include colors.sh

export VERBOSE=0
export QUIET=
export VERBOSE_WITH_LOGGER=
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

name_to_level() {
    local level_name=$1

    case $level_name in 
        Error)   echo 0;;
        Info)    echo 1;;
        Warning) echo 2;;
        Debug)   echo 3;;
        *) eexit "no such verbose level '$level_name'";;
    esac
}

level_is_off() {
    local level_name=$1

    [[ -z $VERBOSE ]] \
        && return
    
    (( $VERBOSE < $(name_to_level $level_name) ))
}

vout() {
    local color=$1; shift
    local level=$1; shift
    local str=$@

    level_is_off $level \
        && return
    
    local color_str="$(color $color)$level: $(no_color)$str"
    local non_color_str="$level: $str"

    colors_are_on \
        && echo -e "$color_str" \
        || echo "$non_color_str"

    verbose_with_logger_enabled \
        && logger "$non_color_str"

    true
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

increase_verbose_level() {
    (( VERBOSE+=1 ))
}

decrease_verbose_level() {
    [[ $VERBOSE != 0 ]] \
        && (( VERBOSE-=1 ))
}

set_verbose_level_to_info() {
    VERBOSE=$VINFO
}

set_verbose_level_to_debug() {
    VERBOSE=$VDEBUG
}

enable_verbose_with_logger() {
    VERBOSE_WITH_LOGGER=1
}

verbose_with_logger_enabled() {
    [[ -n $VERBOSE_WITH_LOGGER ]]
}

no_verbose() {
    VERBOSE=0
}

set_quiet_mode() {
    no_verbose
    QUIET=1
}

is_quiet_mode_on() {
    [[ $QUIET == 1 ]]
}

turn_verbose_colors_on
