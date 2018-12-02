include verbose.sh

user_home_dir() {
    cd ~
    pwd
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

    ssh-copy-id $user@$host
}

set_ssh_connection_with_keys() {
    local user=$1
    local host=$2

    create_ssh_key_if_not_exist

    is_ssh_connection_with_keys_working $user $host \
        || copy_ssh_keys $user $host
}

set_and_test_ssh_connection_with_keys() {
    local user=$1
    local host=$2

    vinfo "setting ssh passwordless connection to $user@$host"
    set_ssh_connection_with_keys $user $host

    set_ssh_connection_with_socket $user $host

    is_ssh_connection_with_keys_working $user $host \
        && vinfo "ssh passwordless connection works to $user@$host" \
        || eexit "ssh passwordless connection does not work to $user@$host. After setting keys. Please check!"
}

wait_for_ssh_connection() {
    local host=$1

    vinfo "waiting for ssh connection to host '$host'"

    while ! (nmap $host -PN -p ssh  | grep -q open )
    do
        is_verbose_level_set_to_info \
            && echo -n '.'

        sleep 1
    done

    echo
}

socket_name() {
    local user=$1
    local host=$2
    
    echo /tmp/$user@$host.sock
}

set_ssh_connection_with_socket() {
    local user=$1
    local host=$2

    ssh \
        -M \
        -o BatchMode=yes \
        -o ControlPersist=10m \
        -S $(socket_name $user $host) \
        "$user@$host" true
}

run_on_host() {
    local user=$1; shift
    local host=$1; shift
    local cmd=$@

    ssh \
        -S $(socket_name $user $host) \
        -o BatchMode=yes \
        "$user@$host" \
        -- \
        $cmd
}

rsync_params_to_use_ssh_socket() {
    local user=$1
    local host=$2

    echo "-e \"ssh -S $(socket_name $user $host)\""
}
