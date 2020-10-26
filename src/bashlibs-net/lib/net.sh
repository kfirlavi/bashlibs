include sysfs.sh

iface_color() {
    local if_type=$1

    case $if_type in
        bridge) echo green ;;
           tap) echo cyan ;;
          vlan) echo purple ;;
             *) echo yellow ;;
    esac
}

colorize_iface() {
    local if_type=$1
    local iface=$2

    echo -e "$(color $(iface_color $if_type))$iface$(no_color)"
}

net_debug() {
    local if_type=$1; shift
    local iface=$1; shift
    local message=$@

    vdebug "$message: $(colorize_iface $if_type $iface)"
}

allow_tap_networking() {
    [[ -e /dev/net/tun ]] \
        || load_kernel_module tun
}

allow_vlan_networking() {
    load_kernel_module 8021q
}

iface_exist() {
    local iface=$1

    ip link show $iface > /dev/null 2>&1
}

iface_is_part_of_bridge() {
    local iface=$1
    local bridge=$2

    brctl show $bridge \
        | grep -q -e "$iface\$"
}

set_interface_state() {
    local iface=$1
    local state=$2

    ip link set dev $iface $state
}

interface_up() {
    local iface=$1

    set_interface_state $iface up
}

interface_down() {
    local iface=$1

    set_interface_state $iface down
}

is_interface_up() {
    local iface=$1

    ip link show $iface \
        | grep state \
        | grep -qv 'state DOWN'
}

is_interface_down() {
    local iface=$1

    ip link show $iface \
        | grep state \
        | grep -q 'state DOWN'
}

bridge_exist() {
    local bridge=$1

    brctl show \
        | awk '{print $1}' \
        | grep -q $bridge
}

add_bridge() {
    local bridge=$1; shift
    local ifaces="$@"
    local iface=

    bridge_exist $bridge \
        && return

    net_debug bridge $bridge "creating bridge"
    ip link add $bridge type bridge
    interface_up $bridge

    for iface in $ifaces
    do
        add_iface_to_bridge $iface $bridge
    done
}

del_bridge() {
    local bridge=$1; shift
    local ifaces="$@"
    local iface=

    bridge_exist $bridge \
        || return

    for iface in $ifaces
    do
        del_iface_from_bridge $iface $bridge
    done

    interface_down $bridge
    ip link del $bridge type bridge
    net_debug bridge $bridge "delete bridge"
}

add_vlan() {
    local iface=$1
    local vlan=$2

    net_debug vlan $iface.$vlan "creating vlan"
    interface_up $iface
    ip link add link $iface name $iface.$vlan type vlan id $vlan
    interface_up $iface.$vlan
}

del_vlan() {
    local iface=$1
    local vlan=$2

    net_debug vlan $iface.$vlan "removing vlan"
    interface_down $iface.$vlan
    ip link del $iface.$vlan type vlan
}

add_tap() {
    local ifaces="$@"
    local iface=

    for iface in $ifaces
    do
        net_debug tap $iface "creating tap interface"
        ip tuntap add $iface mode tap
        interface_up $iface
    done
}

del_tap() {
    local ifaces="$@"
    local iface=

    for iface in $ifaces
    do
        net_debug tap $iface "removing tap interface"
        interface_down $iface
        ip tuntap del $iface mode tap
        sleep 0.5
    done
}

add_iface_to_bridge() {
    local iface=$1
    local bridge=$2

    vdebug "adding $(colorize_iface none $iface) to bridge: $(colorize_iface bridge $bridge)"
    ip link set $iface master $bridge
    interface_up $iface
}

del_iface_from_bridge() {
    local iface=$1
    local bridge=$2

    vdebug "removing $(colorize_iface none $iface) from bridge: $(colorize_iface bridge $bridge)"
    ip link set $iface nomaster
}

iface_have_ip() {
    local iface=$1
    local ip=$2

    ip addr show $iface \
        | grep -q $ip
}

set_ip_to_interface() {
    local iface=$1
    local ip=$2 # should be ip/mask 3.3.3.3/24

    vdebug "setting ip $ip to interface $(colorize_iface none $iface)"
    ip addr add $ip dev $iface
    interface_up $iface
}

del_ip_from_interface() {
    local iface=$1
    local ip=$2 # should be ip/mask 3.3.3.3/24

    vdebug "removing ip $ip from interface $(colorize_iface none $iface)"
    ip addr del $ip dev $iface
}

add_bridge_with_tap_iface() {
    local bridge=$1
    local iface=$2

    add_bridge $bridge
    add_tap $iface
    add_iface_to_bridge $iface $bridge
}

del_bridge_with_tap_iface() {
    local bridge=$1
    local iface=$2

    del_iface_from_bridge $iface $bridge
    del_tap $iface
}

dissable_igmp_snooping_on_bridge() {
    local bridge=$1

    sysfs_option_off \
        /sys/devices/virtual/net/$bridge/bridge/multicast_snooping
}

set_arp_proxy_for_interface() {
    local on_or_off=$1
    local iface=$2

    sysfs_option_$on_or_off \
        /proc/sys/net/ipv4/conf/$iface/proxy_arp
}

set_ip_forward() {
    local on_or_off=$1

    sysfs_option_$on_or_off \
        /proc/sys/net/ipv4/ip_forward
}

dissable_ipv6() {
    local i

    for i in all default lo
    do
        sysfs_option_on \
            /proc/sys/net/ipv6/conf/$i/disable_ipv6
    done
}

set_iface_mac() {
    local iface=$1
    local mac=$2

    ip link set dev $iface address $mac
}

iface_mac() {
    local iface=$1

    ip link show $iface \
        | grep ether \
        | awk '{print $2}'
}

iface_mac_octate() {
    local iface=$1
    local n=$2

    iface_mac $iface \
        | cut -d ':' -f $n
}

enable_vlan_filtering_on_bridge() {
    local bridge=$1

    net_debug bridge $bridge "enable vlan filtering on bridge"
    ip link set dev $bridge type bridge vlan_filtering 1
}

add_vlan_filter_to_bridge() {
    local iface=$1
    local vlan=$2

    net_debug vlan $vlan "adding bridge vlan filter for iface $(colorize_iface none $iface)"
    bridge vlan add vid $vlan dev $iface
}

del_vlan_filter_from_bridge() {
    local iface=$1
    local vlan=$2

    net_debug vlan $vlan "removing bridge vlan filter for iface $(colorize_iface none $iface)"
    bridge vlan del vid $vlan dev $iface
}
