include directories.sh
include nice_header.sh
include ssh.sh
include checks.sh
include bake_gentoo.sh
include os_detection.sh

run_remote() {
    local cmd=$@

    run_on_host \
        root \
        $(host) \
        $cmd
}

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
    local i

    load_configuration_files $project_path > /dev/null 2>&1

    for i in $REPOSITORIES_NAMES
    do
        echo -n "$(color $(repository_color $i))"
        echo -n "$i"
        echo "$(no_color) "
    done \
        | sort \
        | uniq \
        | sed 's/ /,/g' \
        | tr -d '\n' \
        | sed 's/,$//'

    echo
}

package_version() {
    local project_path=$1

    cat $project_path/version
}

list_projects() {
    local i path name version ebuild

    load_configuration_files > /dev/null 2>&1

    for i in $(all_cmake_project_files)
    do
        path=$(dirname $i)
        name=$(extract_project_name_from_cmake_file $i)
        version=$(package_version $path)
        ebuild=$(find_ebuild_for_package $name $version $(sources_root_path)/$(portage_tree))

        echo -n "${name}-$version "
        echo -n "$path "
        echo -n "$(repositories_names_of_project $path) "
        echo "$ebuild"
    done \
        | sort \
        | $(which column) -t

    exit
}

target_build_host() {
    echo $TARGET_BUILD_HOST
}

target_os_is_gentoo() {
    [[ $(target_os) == gentoo ]]
}

target_os() {
    os_detection_remote root $(host) distro_name
}

target_os_with_color() {
    case $(target_os) in
        gentoo) color purple ;;
        debian) color green ;;
        ubuntu) color yellow ;;
    esac

    echo -n $(target_os)

    no_color
}

package_type() {
    case $(target_os) in
        gentoo) echo tbz ;;
        debian) echo deb ;;
        ubuntu) echo deb ;;
    esac
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
    echo /var/cache/bake/overlays/$(portage_tree_name)
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

repository_dir_name() {
    echo repositories
}

root_repositories_dir() {
    create_dir_if_needed \
        /root/$(repository_dir_name)
}

user_repositories_dir() {
    create_dir_if_needed \
        /home/$(whoami)/$(repository_dir_name)
}

create_user_repositories_dir() {
    im_root \
        && root_repositories_dir \
        || user_repositories_dir
}

repositories_dir() {
    running_in_src_tree \
        && create_dir_if_needed $(top_level_path)/$(repository_dir_name) \
        || create_user_repositories_dir
}

show_build_info() {
    local project_name=$1
    local project_path=$2

    is_quiet_mode_on \
        && return

    print_header \
        $project_name-$(package_version $project_path) \
        green \
        "*" \
        blue

    vdebug "$(progname) dir is $(progdir)"
    vinfo "Building project: $(color purple)$project_name$(no_color)"
    vinfo "Project Path: $(color green)$project_path$(no_color)"
    vinfo "Sources path: $(color yellow)$(top_level_path)$(no_color)"
    vinfo "Target build host $(color red)$(target_build_host)$(no_color) is $(target_os_with_color)"
    vinfo "Building $(color blue)$(package_type)$(no_color) package for $(target_os_with_color)"
}

create_function_to_return_static_string() {
    local function_name=$1;shift
    local string=$@

    eval "$function_name() { echo $string; }"
}

work_from_source_tree_root() {
    local path=${1:-$SOURCES_TREE_PATH}
    local root=$(sources_root_path $path)

    cd $root
    set_top_level_path $root
}

list_projects_if_needed() {
    [[ -n $LIST_PROJECTS ]] \
        && list_projects
}

current_directory_project() {
    is_valid_project_path $(working_directory) \
        && extract_project_name_from_path $(working_directory)
}

add_current_directory_project_if_no_projects_supplied() {
    [[ -z $PROJECTS ]] \
        && is_valid_project_path $(working_directory) \
            && PROJECTS="$(current_directory_project)"
}

verify_project_provided() {
    [[ -z $PROJECTS ]] \
        && eexit "project name or project path need to be provided with --project, or working directory should be of a valid project."
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
        set_and_test_ssh_connection_with_keys root $(host)
}
