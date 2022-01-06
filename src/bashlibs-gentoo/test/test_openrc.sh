#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include openrc.sh

rc-update() {
    local params=$@

    echo rc-update $params
}

setUp() {
    set_verbose_level_to_error
}

test_add_openrc_service_to_startup() {
    returns "rc-update add my_service" \
        "add_openrc_service_to_startup my_service"
}

test_remove_openrc_service_from_startup() {
    returns "rc-update del my_service" \
        "remove_openrc_service_from_startup my_service"
}

test_start_openrc_service() {
    returns "/etc/init.d/my_service start" \
        "start_openrc_service my_service echo"
}

test_stop_openrc_service() {
    returns "/etc/init.d/my_service stop" \
        "stop_openrc_service my_service echo"
}

test_restart_openrc_service() {
    returns "/etc/init.d/my_service restart" \
        "restart_openrc_service my_service echo"
}

# load shunit2
source /usr/share/shunit2/shunit2
