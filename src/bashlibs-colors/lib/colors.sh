_color_major_minor_black()        { echo '0;30' ;}
_color_major_minor_blue()         { echo '0;34' ;}
_color_major_minor_green()        { echo '0;32' ;}
_color_major_minor_cyan()         { echo '0;36' ;}
_color_major_minor_red()          { echo '0;31' ;}
_color_major_minor_purple()       { echo '0;35' ;}
_color_major_minor_brown()        { echo '0;33' ;}
_color_major_minor_light_gray()   { echo '0;37' ;}
_color_major_minor_dark_gray()    { echo '1;30' ;}
_color_major_minor_light_blue()   { echo '1;34' ;}
_color_major_minor_light_green()  { echo '1;32' ;}
_color_major_minor_light_cyan()   { echo '1;36' ;}
_color_major_minor_light_red()    { echo '1;31' ;}
_color_major_minor_light_purple() { echo '1;35' ;}
_color_major_minor_yellow()       { echo '1;33' ;}
_color_major_minor_white()        { echo '1;37' ;}

to_upper() {
    local str=$@

    echo $str \
        | tr '[:lower:]' '[:upper:]'
}

spaces_to_underscors() {
    local str=$@

    echo $str \
        | tr ' ' '_'
}

color() {
    local color_name=$(spaces_to_underscors $@)

    echo -en "\033[$(_color_major_minor_$color_name)m"
}

no_color()
{
	echo -en "\033[0m"
}
