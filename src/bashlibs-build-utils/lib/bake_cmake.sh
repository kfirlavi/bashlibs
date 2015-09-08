all_cmake_files() {
    local path=$1

    find $path \
        -type f \
        -name CMakeLists.txt
}

all_cmake_project_files() {
    local path=$1

    local i

    for i in $(all_cmake_files $path)
    do
        grep -l "project (" $i
    done
}

cmake_project_file() {
    local project_name=$1
    local path=$2
    local i

    for i in $(all_cmake_project_files $path)
    do
        grep -l "project ($project_name)" $i
    done
}

project_exist() {
    local project_name=$1
    local path=$2

    [[ -n $(cmake_project_file $project_name $path) ]]
}

exit_if_project_not_found() {
    local project_name=$1
    local path=$2

    project_exist $project_name $path \
        || eexit "Can't find project '$project' in sources dir $path"
}

extract_project_name_from_cmake_file() {
    local cmake_file=$1

    grep project $cmake_file \
        | cut -d '(' -f 2 \
        | cut -d ')' -f 1
}
