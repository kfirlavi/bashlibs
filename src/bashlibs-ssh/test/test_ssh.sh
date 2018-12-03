#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include ssh.sh

setUp() {
    rsa_ssh_key() {
        echo /tmp/rsa_key
    }
}

tearDown() {
    rm -f $(rsa_ssh_key)
    rm -f $(rsa_ssh_public_key)
}

test_rsa_ssh_key() {
    returns "/tmp/rsa_key" \
        "rsa_ssh_key"
}

test_rsa_ssh_public_key() {
    returns "/tmp/rsa_key.pub" \
        "rsa_ssh_public_key"
}

test_rsa_ssh_public_key_exist() {
    return_false "rsa_ssh_public_key_exist"
    create_ssh_key_if_not_exist
    return_true "rsa_ssh_public_key_exist"
}

test_create_ssh_key_if_not_exist() {
    create_ssh_key_if_not_exist
    cp $(rsa_ssh_key){,.save}
    cp $(rsa_ssh_public_key){,.save}
    create_ssh_key_if_not_exist
    files_should_equal $(rsa_ssh_key){,.save}
    files_should_equal $(rsa_ssh_public_key){,.save}
}

test_socket_name() {
    returns /tmp/root@gu64.sock "socket_name root gu64"
}

test_set_rsync_ssh_connection_with_socket() {
    set_rsync_ssh_connection_with_socket root gu64
    returns "ssh -S /tmp/root@gu64.sock" \
        "echo $RSYNC_RSH"
}

# load shunit2
source /usr/share/shunit2/shunit2
