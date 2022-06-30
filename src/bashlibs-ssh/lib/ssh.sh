include verbose.sh
include directories.sh

ssh_cmd() {
    echo ssh
}

rsa_ssh_key() {
    echo "$(user_home_dir)/.ssh/id_rsa"
}

rsa_ssh_public_key() {
    echo $(rsa_ssh_key).pub
}

rsa_ssh_public_key_exist() {
    [[ -f $(rsa_ssh_public_key) ]]
}

create_rsa_ssh_key() {
    ssh-keygen -f $(rsa_ssh_key) -t rsa -N '' > /dev/null 2>&1
}

create_ssh_key_if_not_exist() {
    rsa_ssh_public_key_exist \
        || create_rsa_ssh_key
}

is_ssh_connection_with_keys_working() {
    local user=$1
    local host=$2

    run_on_host $user $host true
}

copy_ssh_keys() {
    local user=$1
    local host=$2
    local password=$3

    [[ -n $password ]] \
        && sshpass -p $password ssh-copy-id $user@$host \
        || ssh-copy-id $user@$host
}

set_ssh_connection_with_keys() {
    local user=$1
    local host=$2
    local password=$3

    create_ssh_key_if_not_exist

    is_ssh_connection_with_keys_working $user $host \
        || copy_ssh_keys $user $host $password
}

set_and_test_ssh_connection_with_keys() {
    local user=$1
    local host=$2
    local password=$3

    vinfo "setting ssh passwordless connection to $user@$host"
    set_ssh_connection_with_keys $user $host $password

    set_ssh_connection_with_socket $user $host

    is_ssh_connection_with_keys_working $user $host \
        && vinfo "ssh passwordless connection works to $user@$host" \
        || eexit "ssh passwordless connection does not work to $user@$host. After setting keys. Please check!"
}

ssh_port_is_open() {
    local host=$1

    nmap $host -PN -p ssh \
        | grep ssh \
        | grep -q open
}

ssh_port_is_closed() {
    local host=$1

    ! ssh_port_is_open $host
}

wait_for_ssh_connection() {
    local host=$1; shift
    local total_seconds_to_wait=${1:-180}
    local interval=1
    local seconds_elapsed=0

    vinfo "waiting for ssh connection to host '$host'"

    while ssh_port_is_closed $host
    do
        is_verbose_level_is_info_or_above \
            && echo -n '.'

        sleep $interval
        (( seconds_elapsed+=interval ))

        if (( $total_seconds_to_wait == $seconds_elapsed ))
        then
            verror "cannot establish ssh connection to host '$host'"
            return
        fi
    done

    echo
}

socket_name() {
    local user=$1
    local host=$2

    echo /tmp/$user@$host.sock
}

ssh_socket_exist() {
    local user=$1
    local host=$2

    [[ -S $(socket_name $user $host) ]]
}

set_ssh_connection_with_socket() {
    local user=$1
    local host=$2

    ssh_socket_exist $user $host \
        && return

    $(ssh_cmd) \
        -M \
        -o ControlPersist=10m \
        -S $(socket_name $user $host) \
        "$user@$host" true
}

run_on_host() {
    local user=$1; shift
    local host=$1; shift
    local cmd=$@

    $(ssh_cmd) \
        -S $(socket_name $user $host) \
        -o BatchMode=yes \
        "$user@$host" \
        -- \
        $cmd
}

set_rsync_ssh_connection_with_socket() {
    local user=$1
    local host=$2

    export RSYNC_RSH="ssh -S $(socket_name $user $host)"
}
