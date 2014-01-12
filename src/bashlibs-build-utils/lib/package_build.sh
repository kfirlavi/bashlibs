#!/bin/bash
include verbose.sh
include colors.sh
include directories.sh

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

app_version() {
	cat $(project_path)/version
}

gen_changelog() {
	cd $(project_path)
	git --no-pager log . > ChangeLog
	cd - > /dev/null 2>&1
}

terminal_size() {
    tput cols
}

print_ruler() {
    local sign=${1:-'*'}
    local length=${2:-$(terminal_size)}

    printf "${sign}%.0s" $(eval echo {1..$length})
    echo
}

print_box_sides() {
    local sign=${1:-'*'}
    local length=${2:-$(terminal_size)}

    echo -n "$sign"
    print_gap $(( length - 2 ))
    echo "$sign"
}

print_gap() {
    local length=$1

    printf " %.0s" $(eval echo {1..$length})
}

print_header_midline() {
    local package_name=$1
    local name_color=$2
    local sign=$3
    local box_color=$4
    local line_length=${5:-$(terminal_size)}
    local package_name_length=${#package_name}
    local side=$(((line_length - package_name_length)/2 - 1))

    color $box_color
    echo -n "$sign"
    print_gap $side

    color $name_color
    echo -n $package_name

    color $box_color
    print_gap $((side + (line_length - package_name_length)%2))
    echo -n "$sign"

    no_color
}

print_header() {
    local package_name=$1
    local name_color=$2
    local sign=$3
    local box_color=$4

    echo
    color $box_color
    print_ruler "$sign"
    print_box_sides "$sign"

    print_header_midline \
        $package_name \
        $name_color \
        "$sign" \
        $box_color

    echo
    color $box_color
    print_box_sides "$sign"
    print_ruler "$sign"

    echo
    no_color
}

run_cmake() {
    print_header \
        $(cmake_project_name) \
        green \
        "*" \
        blue

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
	ssh -t root@$(host) $@
}

remote_mkdir() {
	local dir=$1

	run_remote "mkdir -p $dir"
	echo $dir
}

host() {
    echo $(target_build_host)
}

package_types() {
    echo deb tbz
}

valid_package_type() {
    local ptype=$1

    [[ $(package_types) =~ $ptype ]]
}

dir_project_name() {
	basename $(project_path)
}

tbz_filename_prefix() {
	echo $(cmake_project_name)-$(app_version)-Source
}

tbz_filename() {
	echo $(tbz_filename_prefix).tar.bz2
}

top_dir() {
    local dir=$1

    echo $dir \
        | cut -d '/' -f 2
}

dir_in_tmp() {
    local dir=$1

    [[ $(top_dir $dir) == tmp ]]
}

is_directory() {
    local dir=$1

    [[ -d $dir ]]
}

clean_dir_in_tmp() {
    local dir=$1

    dir_in_tmp $dir \
        && is_directory $dir \
        && rm -Rf $dir
}

clean_tmp_dir() {
    clean_dir_in_tmp $(tmp_dir)
}

workdir() {
    create_dir_if_needed \
        $(tmp_dir)/$(tbz_filename_prefix)
}

copy_sources_to_workdir() {
    cd $(project_path)
    rsync -r --exclude=*swp * $(workdir)/
    cd - > /dev/null 2>&1
}

distfiles_directory() {
    create_dir_if_needed \
        /usr/portage/distfiles
}

local_distfiles_directory() {
    create_dir_if_needed \
        $(progdir)/../gentoo/distfiles
}

tar_sources() {
    local f=$(local_distfiles_directory)/$(tbz_filename)

    cd $(tmp_dir)
	tar cjf $f * \
	    && vinfo "File $f created."
    cd - > /dev/null 2>&1
}

copy_package_to_portage_distfiles_directory() {
    cp $(local_distfiles_directory)/$(tbz_filename) \
        $(distfiles_directory)
}
