#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include hosts.sh

setUp() {
    create_temp_file hosts_file
	cat<<-EOF > $(hosts_file)
	10.0.0.1 host1
	10.0.0.1 host1_dup
	192.168.0.2 host2 my_host2 entry2
	EOF
}

tearDown() {
    delete_temp_file hosts_file
}

test_delete_hosts_entries_by_ip() {
    delete_hosts_entries_by_ip 10.0.0.1
    return_false "line_in_file $(hosts_file) '10.0.0.1 host1'"
    return_false "line_in_file $(hosts_file) '10.0.0.1 host1_dup'"

    delete_hosts_entries_by_ip 192.168.0.2
    return_false "line_in_file $(hosts_file) '192.168.0.2 host2 my_host2 entry2'"
}

test_add_hosts_entry() {
    add_hosts_entry 1.1.1.1 test1
    return_true "line_in_file $(hosts_file) 1.1.1.1 test1"

    add_hosts_entry 2.2.2.2 test2 test2_dup
    return_true "line_in_file $(hosts_file) 2.2.2.2 test2 test2_dup"
}

# load shunit2
source /usr/share/shunit2/shunit2
