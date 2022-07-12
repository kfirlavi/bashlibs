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

nmap_open() {
	cat<<-EOF
	Starting Nmap 7.80 ( https://nmap.org ) at 2021-11-18 16:56 IST
	Nmap scan report for localhost (127.0.0.1)
	Host is up (0.00013s latency).

	PORT   STATE SERVICE
	22/tcp open  ssh

	Nmap done: 1 IP address (1 host up) scanned in 0.15 seconds
	EOF
}

nmap_closed() {
	cat<<-EOF
	Starting Nmap 7.80 ( https://nmap.org ) at 2021-11-18 16:56 IST
	Nmap scan report for localhost (127.0.0.1)
	Host is up (0.00013s latency).

	PORT   STATE SERVICE
	22/tcp closed  ssh

	Nmap done: 1 IP address (1 host up) scanned in 0.15 seconds
	EOF
}

test_ssh_port_is_open() {
    nmap() {
        nmap_open
    }

    return_true "ssh_port_is_open dummy_host"
}

test_ssh_port_is_closed() {
    nmap() {
        nmap_closed
    }

    return_true "ssh_port_is_closed dummy_host"
}

test_wait_for_ssh_connection() {
    nmap() {
        nmap_closed
    }

    set_verbose_level_to_info
    return_true "wait_for_ssh_connection dummy_host 2 | grep -q Error"
    set_verbose_level_to_error
}

test_socket_name() {
    returns /tmp/root@gu64.sock "socket_name root gu64"
}

test_remove_ssh_socket() {
    local socket=$(socket_name root gu64)

    return_false "file_exist $socket"
    return_true "remove_ssh_socket root gu64"
    touch $socket
    return_true "file_exist $socket"
    return_true "remove_ssh_socket root gu64"
    return_false "file_exist $socket"
}

test_set_rsync_ssh_connection_with_socket() {
    set_rsync_ssh_connection_with_socket root gu64
    returns "ssh -S /tmp/root@gu64.sock" \
        "echo $RSYNC_RSH"
}

# load shunit2
source /usr/share/shunit2/shunit2
