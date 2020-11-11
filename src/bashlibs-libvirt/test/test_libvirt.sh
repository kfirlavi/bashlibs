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
	<cpu mode='custom' match='exact' check='full'>
	  <model fallback='forbid'>Nehalem</model>
	  <vendor>Intel</vendor>
	  <feature policy='require' name='vme'/>
	  <feature policy='require' name='ss'/>
	  <feature policy='require' name='x2apic'/>
	  <feature policy='require' name='tsc-deadline'/>
	  <feature policy='require' name='hypervisor'/>
	  <feature policy='require' name='arat'/>
	  <feature policy='require' name='tsc_adjust'/>
	  <feature policy='require' name='umip'/>
	  <feature policy='require' name='rdtscp'/>
	</cpu>

	<interface type='network'>
	  <mac address='54:b1:04:34:50:5c'/>
	  <source network='default' portid='7399f49b-ec1e-4478-a0fb-f809a6f28730' bridge='virbr0'/>
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

test_enable_vmx_in_vm_xml() {
	create_temp_file vm_xml

	virsh_dumpxml > $(vm_xml)
	return_false "grep -q vmx $(vm_xml)"
	enable_vmx_in_vm_xml $(vm_xml)
	return_true "grep -q vmx $(vm_xml)"

	delete_temp_file vm_xml
}

# load shunit2
source /usr/share/shunit2/shunit2
