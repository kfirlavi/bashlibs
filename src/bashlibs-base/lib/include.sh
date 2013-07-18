libraries_tests_dir() {
    echo /usr/share/bashlibs/test
}

clean_library_included() {
    export _LIBRARIES_INCLUDED=
}

is_library_included() {
    local library_name=$1

    [[ "$_LIBRARIES_INCLUDED" =~ $library_name ]]
}

save_library_as_included() {
    local library_name=$1

    export _LIBRARIES_INCLUDED

    is_library_included $library_name \
        || _LIBRARIES_INCLUDED="$_LIBRARIES_INCLUDED $library_name"
}

include() {
    local library_name=$1

    is_library_included $library_name \
        || source $(find_library $library_name)

    save_library_as_included $library_name
}
save_library_as_included base.sh

