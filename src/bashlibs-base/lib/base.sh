intree_include() {
    [[ -d $BASHLIBS_SOURCE_TREE/src ]]
}

find_library() {
    local library_name=$1

    find $(libraries_path) \
        -type f \
        -name "$library_name"
}

library_does_no_exist() {
    local library_name=$1

    [[ ! -f $(find_library $library_name) ]]
}

exit_if_library_does_not_exists() {
    local library_name=$1

    if library_does_no_exist $library_name; then
        echo "can't find library '$library_name' in $(libraries_path)" 
        exit 1
    fi
}

libraries_path() {
    intree_include \
        && echo $BASHLIBS_SOURCE_TREE/src \
        || echo /usr/lib/bashlibs
}

source $(find_library header.sh)
source $(find_library include.sh)
