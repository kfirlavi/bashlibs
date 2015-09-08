all_cmake_project_files() {
    local path=$1

    find $path \
        -type f \
        -name CMakeLists.txt \
        -exec grep -l "project (" {} \;
}
