libraries_tests_dir() {
    echo /usr/share/bashlibs/test
}

libraries_included() {
    echo
}

clean_library_included() {
    libraries_included() {
        echo
    }
}

is_library_included() {
    local library_name=$1

    [[ " $(libraries_included) " =~ " $library_name " ]]
}

save_library_as_included() {
    local library_name=$1

    is_library_included $library_name \
        && return

    eval "libraries_included() { echo $(libraries_included) $library_name ;}"
}

include() {
    local library_name=$1

    exit_if_library_does_not_exists $library_name

    is_library_included $library_name \
        || source $(find_library $library_name)

    save_library_as_included $library_name
}

save_library_as_included base.sh
