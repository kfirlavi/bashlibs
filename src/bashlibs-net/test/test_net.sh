#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include net.sh
source __BASHLIBS_PROJECT_TESTS_DIR__/support_net.sh

tmp_bridge() {
    echo test_bridge
}

bridge_suffix() {
    echo _br
}

tmp_tap() {
    echo test_tap
}

tmp_vlan() {
    echo 123
}

bridge_instances() {
    echo 1 2 3 4
}

tmp_mac() {
    echo aa:bb:cc:dd:ee:f1
}

oneTimeSetUp() {
    allow_vlan_networking
    allow_tap_networking
}

setUp() {
    add_bridge $(tmp_bridge)
}

tearDown() {
    del_bridge $(tmp_bridge)
    true
}

test_iface_exist() {
    return_true "iface_exist $(tmp_bridge)"
    del_bridge $(tmp_bridge)
    return_false "iface_exist $(tmp_bridge)"
}

test_iface_is_part_of_bridge() {
    add_tap $(tmp_tap)
    return_false "iface_is_part_of_bridge $(tmp_tap) $(tmp_bridge)"
    del_bridge $(tmp_bridge)
    add_bridge $(tmp_bridge) $(tmp_tap)
    return_true "iface_is_part_of_bridge $(tmp_tap) $(tmp_bridge)"
}

test_interface_up() {
    # very hard to test with tap device as it needs
    # a program that will bind to it
    # bridge will change state to UNKNOWN but not UP
    interface_down $(tmp_bridge)
    interface_up $(tmp_bridge)
    return_true "is_interface_up $(tmp_bridge)"
}

test_interface_down() {
    interface_up $(tmp_bridge)
    interface_down $(tmp_bridge)
    return_true "is_interface_down $(tmp_bridge)"
}

test_is_interface_up() {
    interface_up $(tmp_bridge)
    return_true "is_interface_up $(tmp_bridge)"

    interface_down $(tmp_bridge)
    return_false "is_interface_up $(tmp_bridge)"
}

test_is_interface_down() {
    interface_up $(tmp_bridge)
    return_false "is_interface_down $(tmp_bridge)"

    interface_down $(tmp_bridge)
    return_true "is_interface_down $(tmp_bridge)"
}

test_bridge_exist() {
    return_false "bridge_exist ''"
    return_true "bridge_exist $(tmp_bridge)"
    del_bridge $(tmp_bridge)
    return_false "bridge_exist $(tmp_bridge)"
}

test_add_bridge() {
    add_bridge $(tmp_bridge)
    return_true "iface_exist $(tmp_bridge)"
}

test_del_bridge() {
    del_bridge $(tmp_bridge)
    return_false "iface_exist $(tmp_bridge)"
}

test_add_bridge_with_multi_ifaces() {
    del_bridge $(tmp_bridge)
    add_tap my_tap1
    add_tap my_tap2
    add_tap my_tap3
    add_tap my_tap4

    add_bridge $(tmp_bridge) my_tap1 my_tap2
    return_true "iface_is_part_of_bridge my_tap1 $(tmp_bridge)"
    return_true "iface_is_part_of_bridge my_tap2 $(tmp_bridge)"
    return_false "iface_is_part_of_bridge my_tap3 $(tmp_bridge)"
    return_false "iface_is_part_of_bridge my_tap4 $(tmp_bridge)"

    add_bridge $(tmp_bridge) my_tap3 my_tap4
    return_true "iface_is_part_of_bridge my_tap1 $(tmp_bridge)"
    return_true "iface_is_part_of_bridge my_tap2 $(tmp_bridge)"
    return_true "iface_is_part_of_bridge my_tap3 $(tmp_bridge)"
    return_true "iface_is_part_of_bridge my_tap4 $(tmp_bridge)"
}

test_del_bridge_with_multi_ifaces() {
    del_bridge $(tmp_bridge)
    add_bridge $(tmp_bridge) my_tap1 my_tap2 my_tap3 my_tap4
    del_bridge $(tmp_bridge)
    return_false "iface_is_part_of_bridge my_tap1 $(tmp_bridge)"
    return_false "iface_is_part_of_bridge my_tap2 $(tmp_bridge)"
    return_false "iface_is_part_of_bridge my_tap3 $(tmp_bridge)"
    return_false "iface_is_part_of_bridge my_tap4 $(tmp_bridge)"
    return_false "iface_exist $(tmp_bridge)"
    del_tap my_tap1
    del_tap my_tap2
    del_tap my_tap3
    del_tap my_tap4
}

test_add_vlan() {
    add_vlan $(tmp_bridge) $(tmp_vlan)
    return_true "is_interface_up $(tmp_bridge).$(tmp_vlan)"
}

test_del_vlan() {
    add_vlan $(tmp_bridge) $(tmp_vlan)
    del_vlan $(tmp_bridge) $(tmp_vlan)
    return_false "is_interface_up $(tmp_bridge).$(tmp_vlan)"
}

test_add_tap() {
    del_tap $(tmp_tap)
    add_tap $(tmp_tap)
    return_true "is_interface_up $(tmp_tap)"
}

test_del_tap() {
    del_tap $(tmp_tap)
    return_false "is_interface_up $(tmp_tap)"
}

test_add_multiple_taps() {
    add_tap tap1 tap2 tap3
    return_true "is_interface_up tap1"
    return_true "is_interface_up tap2"
    return_true "is_interface_up tap3"
}

test_del_multiple_taps() {
    del_tap tap1 tap2 tap3
    return_false "is_interface_up tap1"
    return_false "is_interface_up tap2"
    return_false "is_interface_up tap3"
}

test_add_iface_to_bridge() {
    add_tap $(tmp_tap)
    interface_down $(tmp_tap)
    add_bridge $(tmp_bridge)
    add_iface_to_bridge $(tmp_tap) $(tmp_bridge)
    return_true "iface_is_part_of_bridge $(tmp_tap) $(tmp_bridge)"
    return_true "is_interface_up $(tmp_tap)"
}

test_del_iface_from_bridge() {
    del_iface_from_bridge $(tmp_tap) $(tmp_bridge)
    return_false "iface_is_part_of_bridge $(tmp_tap) $(tmp_bridge)"
    del_bridge $(tmp_bridge)
    del_tap $(tmp_tap)
}

test_iface_have_ip() {
    return_false "iface_have_ip $(tmp_bridge) '2.2.2.2/24'"
    interface_down $(tmp_bridge)
    set_ip_to_interface $(tmp_bridge) '2.2.2.2/24'
    return_true "iface_have_ip $(tmp_bridge) '2.2.2.2/24'"
}

test_set_ip_to_interface() {
    interface_down $(tmp_bridge)
    set_ip_to_interface $(tmp_bridge) '2.2.2.2/24'
    return_true "is_interface_up $(tmp_bridge)"
    return_true "iface_have_ip $(tmp_bridge) '2.2.2.2/24'"
    set_ip_to_interface $(tmp_bridge) '1.1.1.1/16'
    return_true "is_interface_up $(tmp_bridge)"
    return_true "iface_have_ip $(tmp_bridge) '2.2.2.2/24'"
    return_true "iface_have_ip $(tmp_bridge) '1.1.1.1/16'"
}

test_del_ip_from_interface() {
    interface_down $(tmp_bridge)
    set_ip_to_interface $(tmp_bridge) '2.2.2.2/24'
    del_ip_from_interface $(tmp_bridge) '2.2.2.2/24'
    return_false "iface_have_ip $(tmp_bridge) '2.2.2.2/24'"
    del_bridge $(tmp_bridge)
}

test_add_bridge_with_tap_iface() {
    add_bridge_with_tap_iface bt-br0 bt1 bt2 bt3

    return_true "bridge_exist bt-br0"

    local i
    for i in 1 2 3
    do
        return_true "iface_exist bt$i"
        return_true "is_interface_up bt$i"
        return_true "iface_is_part_of_bridge bt$i bt-br0"
    done
}

test_del_bridge_with_tap_iface() {
    del_bridge_with_tap_iface bt-br0 bt1 bt2 bt3

    return_false "bridge_exist bt-br0"

    local i
    for i in 1 2 3
    do
        return_false "iface_exist bt$i"
        return_false "is_interface_up bt$i"
        return_false "iface_is_part_of_bridge bt$i bt-br0"
    done

    return_false "bridge_exist bt-br0"
}

test_dissable_igmp_snooping_on_bridge() {
    local bridge=igmp_test_br
    add_bridge $bridge

    dissable_igmp_snooping_on_bridge $bridge
    returns 0 "cat /sys/devices/virtual/net/$bridge/bridge/multicast_snooping"

    del_bridge $bridge
}

test_set_arp_proxy_for_interface() {
    add_tap $(tmp_tap)

    set_arp_proxy_for_interface on $(tmp_tap)
    returns "1" "cat /proc/sys/net/ipv4/conf/$(tmp_tap)/proxy_arp"

    set_arp_proxy_for_interface off $(tmp_tap)
    returns "0" "cat /proc/sys/net/ipv4/conf/$(tmp_tap)/proxy_arp"

    del_tap $(tmp_tap)
}

test_set_ip_forward() {
    set_ip_forward on
    returns "1" "cat /proc/sys/net/ipv4/ip_forward"

    set_ip_forward off
    returns "0" "cat /proc/sys/net/ipv4/ip_forward"

    add_tap $(tmp_tap)

    set_ip_forward on $(tmp_tap)
    returns "1" "cat /proc/sys/net/ipv4/conf/$(tmp_tap)/forwarding"

    set_ip_forward off $(tmp_tap)
    returns "0" "cat /proc/sys/net/ipv4/conf/$(tmp_tap)/forwarding"

    del_tap $(tmp_tap)
}

test_iface_mac() {
    add_tap $(tmp_tap)
    set_iface_mac $(tmp_tap) $(tmp_mac)

    returns "$(tmp_mac)" \
        "iface_mac $(tmp_tap)"

    del_tap $(tmp_tap)
}

test_iface_mac_octate() {
    add_tap $(tmp_tap)
    set_iface_mac $(tmp_tap) $(tmp_mac)

    returns aa "iface_mac_octate $(tmp_tap) 1"
    returns bb "iface_mac_octate $(tmp_tap) 2"
    returns cc "iface_mac_octate $(tmp_tap) 3"
    returns dd "iface_mac_octate $(tmp_tap) 4"
    returns ee "iface_mac_octate $(tmp_tap) 5"
    returns f1 "iface_mac_octate $(tmp_tap) 6"

    del_tap $(tmp_tap)
}

test_enable_vlan_filtering_on_bridge() {
    enable_vlan_filtering_on_bridge $(tmp_bridge)
    returns "1" "cat /sys/class/net/$(tmp_bridge)/bridge/vlan_filtering"
}

test_add_vlan_filter_to_bridge() {
    enable_vlan_filtering_on_bridge $(tmp_bridge)
    add_tap $(tmp_tap)
    add_iface_to_bridge $(tmp_tap) $(tmp_bridge)
    add_vlan_filter_to_bridge $(tmp_tap) 45
    return_true "bridge vlan show | grep -A 2 $(tmp_tap) | grep -q 45"

    del_tap $(tmp_tap)
}

test_add_vlan_filter_to_bridge_as_pvid() {
    enable_vlan_filtering_on_bridge $(tmp_bridge)
    add_tap $(tmp_tap)
    add_iface_to_bridge $(tmp_tap) $(tmp_bridge)

    add_vlan_filter_to_bridge $(tmp_tap) 45
    return_false "bridge vlan show | grep -A 2 $(tmp_tap) | grep 45 | grep -q PVID"

    add_vlan_filter_to_bridge $(tmp_tap) 45 pvid
    return_true "bridge vlan show | grep -A 2 $(tmp_tap) | grep 45 | grep -q PVID"

    add_vlan_filter_to_bridge $(tmp_tap) 45 untagged
    return_true "bridge vlan show | grep -A 2 $(tmp_tap) | grep 45 | grep -q 'Egress Untagged'"

    add_vlan_filter_to_bridge $(tmp_tap) 45 pvid untagged
    return_true "bridge vlan show | grep -A 2 $(tmp_tap) | grep 45 | grep -q 'PVID Egress Untagged'"

    del_tap $(tmp_tap)
}

test_del_vlan_filter_from_bridge() {
    enable_vlan_filtering_on_bridge $(tmp_bridge)
    add_tap $(tmp_tap)
    add_iface_to_bridge $(tmp_tap) $(tmp_bridge)
    add_vlan_filter_to_bridge $(tmp_tap) 45
    return_true "bridge vlan show | grep -A 2 $(tmp_tap) | grep -q 45"

    del_vlan_filter_from_bridge $(tmp_tap) 45
    return_false "bridge vlan show | grep -A 2 $(tmp_tap) | grep -q 45"

    del_tap $(tmp_tap)
}

test_mtu() {
    local mtu=$(mtu $(tmp_bridge))
    increase_mtu $(tmp_bridge) 4
    return_true "(( $(mtu $(tmp_bridge)) == $mtu + 4 ))"
}

# load shunit2
source /usr/share/shunit2/shunit2
