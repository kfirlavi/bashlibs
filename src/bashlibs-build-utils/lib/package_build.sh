#!/bin/bash
include verbose.sh
include colors.sh

cmake_project_name() {
	grep -i "project" $(project_path)/CMakeLists.txt \
		| head -1 \
		| cut -d '(' -f 2 | cut -d ')' -f 1 \
		| tr ' ' '.'
}

tmp_dir() {
    echo /tmp/$(progname)
}

check_project_path() {
    [[ -z $(project_path) ]] \
        && eexit "You need to provide a project path"

    [[ ! -d $(project_path) ]] \
        && eexit "project path '$(project_path)': is not a directory!"

    [[ ! -f $(project_path)/CMakeLists.txt ]] \
        && eexit "You need to provide a cmake source dir. $(project_path)/CMakeLists.txt not found!"
}

verify_target_build_host() {
    local remote_host=$1

    run_remote ls / > /dev/null \
        || eexit "host $remote_host should respond to 'ssh root@$remote_host' without password prompt. Use ssh-keygen and ssh-copy-id to solve the problem."
}

create_dir_if_needed() {
    local dir=$1

    [[ -d $dir ]] \
        || mkdir -p $dir

    readlink -m $dir
}

app_version() {
	cat $(project_path)/version
}

gen_changelog() {
	cd $(project_path)
	git --no-pager log . > ChangeLog
	cd - > /dev/null 2>&1
}

print_ruler() {
    local sign=${1:-'*'}
    local length=${2:-80}

    printf "${sign}%.0s" $(eval echo {1..$length})
    echo
}

gap() {
    local length=$1

    printf " %.0s" $(eval echo {1..$length})
}

print_header_midline() {
    local package_name=$1
    local name_color=$2
    local sign=$3
    local box_color=$4
    local line_length=$5
    local length=${#package_name}
    local side=$(((line_length - length)/2 - 1))

    color $box_color
    echo -n "$sign"
    gap $side

    color $name_color
    echo -n $package_name

    color $box_color
    gap $((side+length%2))
    echo -n "$sign"

    no_color
}

print_header() {
    local package_name=$1
    local name_color=$2
    local sign=$3
    local box_color=$4
    local header_size=$5

    echo
    color blue
    print_ruler "$sign" $header_size

    print_header_midline \
        $package_name \
        yellow \
        "$sign" \
        blue \
        $header_size

    echo
    color blue
    print_ruler "$sign" $header_size

    echo
    no_color
}

run_cmake() {
    print_header \
        $(cmake_project_name) \
        yellow \
        "*" \
        blue \
        80

    vinfo "Making package"
    run_remote \
        "cd $(get_target_cmp_dir) \
        && cmake $(get_target_src_dir) $(cmake_options) \
        && make package"
}

copy_deb_to_apt_archives() {
    run_remote \
        cp \
        $(get_target_cmp_dir)/*deb \
        /var/cache/apt/archives/
}

install_deb() {
    vinfo "Installing $(cmake_deb_filename) on $(host)"
	run_remote \
        dpkg -i --force-depends \
        /var/cache/apt/archives/$(cmake_deb_filename)
}

get_target_cmp_dir() {
	remote_mkdir $(tmp_dir)/$(cmake_project_name)/cmp
}

get_target_src_dir() {
	remote_mkdir $(tmp_dir)/$(cmake_project_name)/src
}

copy_sources_to_target() {
	cd $(project_path)

	rsync \
		-a \
		--exclude='*swp' \
		--delete-excluded \
		--delete \
		* root@$(host):$(get_target_src_dir)

	cd - > /dev/null 2>&1
}

clean_remote_dirs() {
	run_remote "rm -Rf $(tmp_dir)"
}

archive_deb() {
	local remote_deb_file=$1
    local repository_path=$2

    vinfo "Saving $(cmake_deb_filename) to $repository_path"
    scp root@$(host):$remote_deb_file $repository_path
}

cmake_deb_filename() {
	echo $(cmake_project_name)-$(app_version)-Linux.deb
}

run_remote() {
	ssh root@$(host) $@
}

remote_mkdir() {
	local dir=$1

	run_remote "mkdir -p $dir"
	echo $dir
}

host() {
    echo $(target_build_host)
}
