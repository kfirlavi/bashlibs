#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include libvirt.sh
include directories.sh

test_fqdn_to_mac() {
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
}

virsh_dumpxml() {
	cat<<-EOF
	<interface type='network'>
	  <mac address='54:b1:04:34:50:5c'/>
	  <source network='default' bridge='virbr0'/>
	  <target dev='vnet2'/>
	  <model type='rtl8139'/>
	  <alias name='net0'/>
	  <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
	</interface>
	EOF
}

virsh_domiflist() {
	cat<<-EOF
	Interface  Type       Source     Model       MAC
	-------------------------------------------------------
	vnet2      network    default    rtl8139     54:c1:e4:35:52:8d
	
	EOF
}

virbr0_status() {
	cat<<-EOF
	[
	    {
	        "ip-address": "192.168.122.34",
	        "mac-address": "54:c1:e4:35:52:8d",
	        "hostname": "vm1",
	        "client-id": "01:54:c1:e4:35:52:8d",
	        "expiry-time": 1531063375
	    }
	]
	EOF
}

test_vm_bridge() {
    returns virbr0 "vm_bridge vm1"
}

test_vm_mac() {
    returns '54:c1:e4:35:52:8d' "vm_mac vm1"
}

test_libvirt_dhcp_leases_file() {
    returns '/var/lib/libvirt/dnsmasq/virbr0.status' \
        "libvirt_dhcp_leases_file vm1"
}

test_vm_ip() {
    virbr0_status > /tmp/status
    libvirt_dhcp_leases_file() { echo /tmp/status; }
    returns "192.168.122.34" "vm_ip vm1"
    rm -f /tmp/status
}

test_enable_nested_kvm() {
    local workdir=$(mktemp -d)

    mkdir -p $workdir/etc/modprobe.d
    enable_nested_kvm $workdir
    file_should_exist $workdir/etc/modprobe.d/kvm_intel.conf
    return_true "cat $workdir/etc/modprobe.d/kvm_intel.conf | grep -q nested=1"

    directory_is_in_tmp $workdir \
        && safe_delete_directory_from_tmp $workdir
}


# load shunit2
source /usr/share/shunit2/shunit2
