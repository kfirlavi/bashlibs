all_cmake_files() {
    local path=$1

    find $path \
        -type f \
        -name CMakeLists.txt
}

cmakefile_should_be_ignored() {
    local cmake_file=$1
    local i=$cmake_file
    local ret=false

    while [[ $i != ./ && $i != / && $i != . ]]
    do
        [[ -f $i/.bake_ignore_below ]] \
            && ret=true \
            && break
        i=$(dirname $i)
    done
    $ret
}

all_cmake_project_files() {
    local path=$1

    local i

    for i in $(all_cmake_files $path)
    do
        cmakefile_should_be_ignored $i \
            || grep -l "project[ ]*(" $i
    done
}

cmake_project_file() {
    local project_name=$1
    local path=$2
    local i

    for i in $(all_cmake_project_files $path)
    do
        grep -l "project[ ]*($project_name)" $i
    done
}

cmake_project_path() {
    local project_name=$1
    local path=$2

    local cmake_file=$(cmake_project_file $project_name $path)

    [[ -f $cmake_file ]] \
        && dirname $cmake_file
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

    grep 'project[ ]*(' $cmake_file \
        | head -1 \
        | cut -d '(' -f 2 \
        | cut -d ')' -f 1
}

cmake_file() {
    local path=$1

    echo $path/CMakeLists.txt
}

cmake_file_exist() {
    local path=$1

    [[ -f $(cmake_file $path) ]]
}

extract_project_name_from_path() {
    local path=$1

    extract_project_name_from_cmake_file \
        $(cmake_file $path)
}

is_path() {
    local path=$1

    [[ -d $path ]]
}

is_valid_project_path() {
    local path=$1

    cmake_file_exist $path \
        && [[ -n $(extract_project_name_from_path $path) ]]
}

set_project_name_and_project_path() {
    local user_project_input=$1
    local project_path
    local project_name

    if is_valid_project_path $user_project_input
    then

        project_path=$user_project_input

        project_name=$(extract_project_name_from_path \
            $project_path)

    elif project_exist $user_project_input
    then

        project_name=$user_project_input

        exit_if_project_not_found \
            $project_name \
            $(top_level_path)
        
        project_path=$(cmake_project_path \
                $project_name \
                $(top_level_path))

    else

        eexit "'$user_project_input' is not a valid project name or project path"
        
    fi

    create_function_to_return_static_string \
        project_name \
        $project_name

    create_function_to_return_static_string \
        project_path \
        $(realpath $project_path)

}
