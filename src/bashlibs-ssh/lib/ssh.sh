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

verify_ssh_connection_with_keys() {
    local user=$1
    local host=$2

    ssh -o BatchMode=yes "$user@$host" true
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

    verify_ssh_connection_with_keys $user $host \
        || copy_ssh_keys $user $host
}

set_and_test_ssh_connection_with_keys() {
    local user=$1
    local host=$2

    vinfo "setting ssh passwordless connection to $user@$host"
    set_ssh_connection_with_keys $user $host

    verify_ssh_connection_with_keys $user $host \
        && vinfo "ssh passwordless connection works to $user@$host" \
        || eexit "ssh passwordless connection does not work to $user@$host. After setting keys. Please check!"
}
