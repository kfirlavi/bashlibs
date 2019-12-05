fqdn_to_mac() {
    local domain=$1

    echo $domain \
        | md5sum \
        | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/54:\1:\2:\3:\4:\5/'
}

virsh_dumpxml() {
    local vm_name=$1
    local xml_file=$2
    
    [[ -z $xml_file ]] \
        && virsh dumpxml $vm_name \
        || virsh dumpxml $vm_name > $xml_file
}

virsh_domiflist() {
    local vm_name=$1
    
    virsh domiflist $vm_name
}

vm_bridge() {
    local vm_name=$1
    
    virsh_dumpxml $vm_name \
        | grep network \
        | grep bridge \
        | cut -d "'" -f 4
}

vm_mac() {
    local vm_name=$1

    virsh_domiflist $vm_name \
        | grep ':' \
        | awk '{print $5}'
}

libvirt_var_dir() {
    echo /var/lib/libvirt
}

libvirt_dhcp_leases_file() {
    local vm_name=$1

    echo $(libvirt_var_dir)/dnsmasq/$(vm_bridge $vm_name).status
}

vm_ip() {
    local vm_name=$1

    grep -B 1 "\"mac-address\": \"$(vm_mac $vm_name)\"" $(libvirt_dhcp_leases_file $vm_name) \
        | grep ip-address \
        | cut -d '"' -f 4
}

libvirt_dhcp_leases_file_contain_mac() {
    local vm_name=$1

    grep -q \
        "\"mac-address\": \"$(vm_mac $vm_name)\"" \
        $(libvirt_dhcp_leases_file $vm_name)
}

wait_for_vm_to_obtain_ip() {
    local vm_name=$1

    vinfo "Waiting for vm $vm_name to obtain ip address"

    while ! $(libvirt_dhcp_leases_file_contain_mac $vm_name)
    do
        is_verbose_level_set_to_info \
            && echo -n '.' \
            && local print_line_end=true

        sleep 1
    done

    is_verbose_level_set_to_info \
        && [[ $print_line_end ]] \
            && echo " $(vm_ip $vm_name)"
}

enable_nested_kvm() {
    local root=$1
    local modprobe_dir=$root/etc/modprobe.d

    dir_exist $modprobe_dir \
        || eexit "$modprobe_dir does not exist. Can't configure nested kvm"

	cat <<- EOF > $modprobe_dir/kvm_intel.conf
	options kvm_intel nested=1
	EOF
}

enable_vmx_in_vm_xml() {
    local xml_file=$1

    sed -i \
        "/<\/cpu>/i <feature policy='require' name='vmx'/>" \
        $xml_file
}

vm_already_defined() {
    local vm_name=$1

    virsh list --all \
        | grep -q $vm_name
}

shutdown_vm() {
    local vm_name=$1

    virsh shutdown $vm_name
}

destroy_vm() {
    local vm_name=$1

    virsh destroy $vm_name
}

undefine_vm() {
    local vm_name=$1

    virsh undefine $vm_name
}

vm_is_running() {
    local vm_name=$1

    virsh list --all \
        | grep $vm_name \
        | grep -q running
}

vm_is_shut_off() {
    local vm_name=$1

    virsh list --all \
        | grep $vm_name \
        | grep -q 'shut off'
}

wait_for_vm_to_shut_off() {
    local vm_name=$1

    vdebug "waiting for $vm_name to shut off"

    for i in $(seq 1 10)
    do
        vm_is_shut_off $vm_name \
            && break
        
        sleep 1
    done

    destroy_vm $vm_name
}
