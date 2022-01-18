#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include libvirt.sh
include directories.sh
include config.sh

oneTimeSetUp() {
    create_workdir
}

oneTimeTearDown() {
    remove_workdir
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
	    },
	    {
	        "ip-address": "192.168.122.35",
	        "mac-address": "54:c1:e4:35:52:8d",
	        "hostname": "vm1",
	        "client-id": "01:54:c1:e4:35:52:8d",
	        "expiry-time": 1531063375
	    },
	    {
	        "ip-address": "192.168.122.37",
	        "mac-address": "54:c1:e4:35:52:11",
	        "hostname": "vm2",
	        "client-id": "01:54:c1:e4:35:52:11",
	        "expiry-time": 1531063375
	    },
	    {
	        "ip-address": "192.168.122.36",
	        "mac-address": "54:c1:e4:35:52:8d",
	        "hostname": "vm1",
	        "client-id": "01:54:c1:e4:35:52:8d",
	        "expiry-time": 1531063375
	    }
	]
	EOF
}

test_fqdn_to_mac() {
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
    returns '54:cc:51:15:e6:77' 'fqdn_to_mac vm_name'
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

mock_dhcp_lease_file() {
    var_to_function \
        libvirt_dhcp_leases_file \
        $(workdir)/status

    virbr0_status > $(workdir)/status
}

test_vm_ip() {
    mock_dhcp_lease_file

    returns \
        "192.168.122.34 192.168.122.35 192.168.122.36" \
        "vm_ip vm1"

    var_to_function vm_mac 54:c1:e4:35:52:11
    returns "192.168.122.37" "vm_ip vm2"
}

test_clean_all_dhcp_leases_by_mac() {
    mock_dhcp_lease_file

    clean_all_dhcp_leases_by_mac vm1 54:c1:e4:35:52:8d

    var_to_function vm_mac 54:c1:e4:35:52:8d
    returns_empty "vm_ip vm1"

    var_to_function vm_mac 54:c1:e4:35:52:11
    returns "192.168.122.37" "vm_ip vm2"
}

test_enable_nested_kvm() {
    mkdir -p $(workdir)/etc/modprobe.d
    enable_nested_kvm $(workdir)
    file_should_exist $(workdir)/etc/modprobe.d/kvm_intel.conf
    return_true "cat $(workdir)/etc/modprobe.d/kvm_intel.conf | grep -q nested=1"
}

test_enable_vmx_in_vm_xml() {
	var_to_function vm_xml $(workdir)/vm.xml

	virsh_dumpxml > $(vm_xml)
	return_false "grep -q vmx $(vm_xml)"
	enable_vmx_in_vm_xml $(vm_xml)
	return_true "grep -q vmx $(vm_xml)"
}

# load shunit2
source /usr/share/shunit2/shunit2
