args_without_extra_args() {
    args \
        | sed 's/\(.*\) -- .*/\1/'
}

extra_args() {
    args \
        | sed 's/.* -- \(.*\)/\1/'
}

cmdline_args_provided() {
    args \
        | grep -q "[^ ]"
}
