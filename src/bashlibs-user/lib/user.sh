include verbose.sh

current_user() {
    whoami
}

runnin_as_root() {
    [[ $(current_user) == root ]]
}

must_run_as_root() {
    runnin_as_root \
        || eexit "'$(progname)' must be run as root"
}
