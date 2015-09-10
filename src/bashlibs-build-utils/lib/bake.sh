if_defined_declare_readonly() {
    local var_name=$1

    [[ -n ${!var_name} ]] \
        && readonly $var_name
}

repository_color() {
    local rep_name=$1
    local rep_color_var=REPOSITORY_COLOR_$rep_name

    echo ${!rep_color_var}
}

repositories_names_of_project() {
    local project_path=$1

    PROJECT_PATH=$project_path
    load_configuration_files > /dev/null 2>&1

    local i=

    for i in $REPOSITORIES_NAMES
    do
        echo -n "$(color $(repository_color $i))"
        echo -n "$i"
        echo -n "$(no_color) "
    done \
        | sort \
        | sed 's/ /,/g' \
        | sed 's/,$//'

    echo

    PROJECT_PATH=
}

package_version() {
    local project_path=$1

    cat $project_path/version
}

list_projects() {
    local i=

    for i in $(all_cmake_project_files)
    do
        local project_path=$(dirname $i)
        echo -n "$(extract_project_name_from_cmake_file $i)-"
        echo -n "$(package_version $project_path) "
        echo -n "$project_path "
        echo "$(repositories_names_of_project $project_path)"
    done \
        | sort \
        | column -t

    exit
}

target_build_host() {
    echo $TARGET_BUILD_HOST
}

target_os_is_gentoo() {
    run_remote [[ -f /etc/gentoo-release ]]
}

target_os_is_ubuntu() {
    run_remote [[ -f /etc/lsb-release ]]
}

target_os() {
    target_os_is_gentoo \
        && echo gentoo

    target_os_is_ubuntu \
        && echo ubuntu
}

target_os_with_color() {
    target_os_is_gentoo \
        && echo $(color purple)gentoo$(no_color)

    target_os_is_ubuntu \
        && echo $(color yellow)ubuntu$(no_color)
}

package_type() {
    target_os_is_gentoo \
        && echo tbz
    target_os_is_ubuntu \
        && echo deb
}

cmake_options() {
    echo $CMAKE_OPTIONS
}

portage_tree() {
    echo $PORTAGE_TREE
}

portage_tree_name() {
    echo $PORTAGE_TREE_NAME
}

gentoo_local_portage_path() {
    echo /usr/local/portage-$(portage_tree_name)
}

building_for_gentoo() {
    [[ $(package_type) == tbz ]]
}

check_gentoo_commands() {
    if building_for_gentoo ; then
        [[ -z $(portage_tree) ]] \
            && eexit "parameter --portage-tree must be set"
        [[ -z $(portage_tree_name) ]] \
            && eexit "parameter --portage-tree-name must be set"
    fi
}

repositories_names() {
    local i

    for i in archive $REPOSITORIES_NAMES
    do
        echo -n "${i}-repository "
    done
}

im_root() {
    [[ $(whoami) == root ]]
}

repository_dir_name() {
    echo repositories
}

create_user_repositories_dir() {
    im_root \
        && create_dir_if_needed /root/$(repository_dir_name) \
        || create_dir_if_needed /home/$(whoami)/$(repository_dir_name)
}

repositories_dir() {
    running_in_src_tree \
        && create_dir_if_needed $(top_level_path)/$(repository_dir_name) \
        || create_user_repositories_dir
}

show_build_info() {
    local project_name=$1
    local project_path=$2

    vdebug "$(progname) dir is $(progdir)"
    vinfo "Building project: $(color purple)$project_name$(no_color)"
    vinfo "Project Path: $(color green)$project_path$(no_color)"
    vinfo "Sources path: $(color yellow)$(top_level_path)$(no_color)"
    vinfo "Target build host $(color red)$(target_build_host)$(no_color) is $(target_os_with_color)"
    vinfo "Building $(color blue)$(package_type)$(no_color) package for $(target_os_with_color)"
}

sources_root_dir() {
    pwd
}

create_function_to_return_static_string() {
    local function_name=$1;shift
    local string=$@

    eval "$function_name() { echo $string; }"
}

set_project_name_and_project_path() {
    local user_project_input=$1
    local project_path
    local project_name

    if is_path $user_project_input
    then
        project_path=$user_project_input

        is_valid_project_path $project_path \
            || eexit "$project_path is not a valid project path"

        project_name=$(extract_project_name_from_path \
            $project_path)
    else
        project_name=$user_project_input

        exit_if_project_not_found \
            $project_name \
            $(top_level_path)
        
        project_path=$(cmake_project_path \
                $project_name \
                $(top_level_path))
    fi

    create_function_to_return_static_string \
        project_name \
        $project_name

    create_function_to_return_static_string \
        project_path \
        $(realpath $project_path)

}

work_from_source_tree_root() {
    local path=$(pwd)
    local root_path

    [[ -n $SOURCES_TREE_ROOT ]] \
        && path=$SOURCES_TREE_ROOT

    root_path=$(find_root_sources_path $path)

    if [[ -z $root_path ]]
    then
        eexit "Can't find the sources root dir, maybe you need to use --root or run $(progname) from the sources root dir"
    else
        cd $root_path
        set_top_level_path $root_path
    fi
}

list_projects_if_needed() {
    [[ -n $LIST_PROJECTS ]] \
        && list_projects
}

verify_project_provided() {
    [[ -z $PROJECTS ]] \
        && eexit "project name or project path need to be provided. None was given."
}

show_on_which_hosts_we_build() {
    vinfo "Building on hosts: $(color red)$TARGET_BUILD_HOSTS$(no_color)"
}

foreach_host_do() {
    local cmd=$@
    local host

    for host in $TARGET_BUILD_HOSTS
    do
        vdebug "Running command '$cmd $host' on host '$host'"
        $cmd $host
    done
}

verify_all_hosts() {
    foreach_host_do \
        verify_target_build_host
}
