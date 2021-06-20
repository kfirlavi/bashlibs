include file_manipulations.sh

hosts_file() {
    echo /etc/hosts
}

delete_hosts_entries_by_ip() {
    local ip=$1

    [[ -z $ip ]] \
        && return

    delete_line_from_file \
        $(hosts_file) \
        $ip
}

delete_hosts_entries_by_names() {
    local names=$@
    local i

    for i in $names
    do
        delete_line_from_file_using_pattern \
            $(hosts_file) \
            $i
    done
}

add_hosts_entry() {
    local ip=$1; shift
    local names=$@

    add_line_to_file_if_not_exist \
        $(hosts_file) \
        "$ip $names"
}
