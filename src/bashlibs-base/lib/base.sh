intree_include() {
    [[ -d $BASHLIBS_SOURCE_TREE/src ]]
}

find_library() {
    local library_name=$1

    find $(libraries_path) \
        -type f \
        -name "$library_name"
}

libraries_path() {
    intree_include \
        && echo $BASHLIBS_SOURCE_TREE \
        || echo /usr/lib/bashlibs
}

source $(find_library header.sh)
source $(find_library include.sh)
