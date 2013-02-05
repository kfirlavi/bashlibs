export readonly _PROGNAME=$(basename $0)
export readonly _PROGDIR=$(readlink -m $(dirname $0))
export readonly _WORKING_DIR=$(pwd)
export readonly _ARGS="$@"

progname() {
    echo $_PROGNAME
}

progdir() {
    echo $_PROGDIR
}

working_directory() {
    echo $_WORKING_DIR
}

args() {
    echo $_ARGS
}

