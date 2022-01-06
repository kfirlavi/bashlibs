add_openrc_service_to_startup() {
    local service=$1

    vinfo "add service $service to startup"

    rc-update add $service
}

remove_openrc_service_from_startup() {
    local service=$1

    vinfo "remove service $service from startup"

    rc-update del $service
}

command_openrc_service() {
    local service=$1
    local cmd=$2
    local pre_cmd=$3

    vinfo "$cmd service $service"

    $pre_cmd /etc/init.d/$service $cmd
}

start_openrc_service() {
    local service=$1
    local pre_cmd=$2

    command_openrc_service $service start $pre_cmd
}

stop_openrc_service() {
    local service=$1
    local pre_cmd=$2

    command_openrc_service $service stop $pre_cmd
}

restart_openrc_service() {
    local service=$1
    local pre_cmd=$2

    command_openrc_service $service restart $pre_cmd
}
