#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include libvirt.sh

test_fqdn_to_mac() {
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
}

# load shunit2
source /usr/share/shunit2/shunit2
