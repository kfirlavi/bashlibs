fqdn_to_mac() {
    local domain=$1

    echo $domain \
        | md5sum \
        | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/54:\1:\2:\3:\4:\5/'
}

virsh_dumpxml() {
    local vm_name=$1
    
    virsh dumpxml $vm_name
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
