terminal_size() {
    tput cols
}

print_ruler() {
    local sign=${1:-'*'}
    local length=${2:-$(terminal_size)}

    printf "${sign}%.0s" $(eval echo {1..$length})
    echo
}

print_box_sides() {
    local sign=${1:-'*'}
    local length=${2:-$(terminal_size)}

    echo -n "$sign"
    print_gap $(( length - 2 ))
    echo "$sign"
}

print_gap() {
    local length=$1

    printf " %.0s" $(eval echo {1..$length})
}

print_header_midline() {
    local package_name=$1
    local name_color=$2
    local sign=$3
    local box_color=$4
    local line_length=${5:-$(terminal_size)}
    local package_name_length=${#package_name}
    local side=$(((line_length - package_name_length)/2 - 1))

    color $box_color
    echo -n "$sign"
    print_gap $side

    color $name_color
    echo -n $package_name

    color $box_color
    print_gap $((side + (line_length - package_name_length)%2))
    echo -n "$sign"

    no_color
}

print_header() {
    local package_name=$1
    local name_color=$2
    local sign=$3
    local box_color=$4

    echo
    color $box_color
    print_ruler "$sign"
    print_box_sides "$sign"

    print_header_midline \
        $package_name \
        $name_color \
        "$sign" \
        $box_color

    echo
    color $box_color
    print_box_sides "$sign"
    print_ruler "$sign"

    echo
    no_color
}

