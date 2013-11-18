#!/bin/bash
include verbose.sh
include colors.sh

package_source_dir() {
    local dir=$(echo $(args) | awk '{print $1}')

    echo $dir \
        | grep -q '^/' \
        && echo $dir \
        || echo $(working_directory)/$dir
}

cmake_project_name() {
	grep -i "project" $(package_source_dir)/CMakeLists.txt \
		| head -1 \
		| cut -d '(' -f 2 | cut -d ')' -f 1 \
		| tr ' ' '.'
}

tmp_dir() {
    echo /tmp/$(progname)
}

check_source_dir() {
    [[ ! -d $(package_source_dir) ]] \
        && eexit "\"$(args)\": is not a directory!"

    [[ ! -f $(package_source_dir)/CMakeLists.txt ]] \
        && eexit "You need to provide a cmake source dir. $(package_source_dir)/CMakeLists.txt not found!"
}

check_remote_host() {
    local remote_host=$1

    [[ -z $remote_host ]] \
        && eexit "You need to provide remote computer"

    run_remote ls / > /dev/null \
        || eexit "host $remote_host should respond to 'ssh root@$remote_host' without password prompt. Use ssh-keygen and ssh-copy-id to solve the problem."
}

cmake_options() {
    local args=($(args))

    echo ${args[@]:2:${#args[@]}}
}

create_dir_if_needed() {
    local dir=$1

    [[ -d $dir ]] \
        || mkdir -p $dir

    readlink -m $dir
}

app_version() {
	cat $(package_source_dir)/version
}

gen_changelog() {
	cd $(package_source_dir)
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

print_header() {
    local package_name=$1
    local length=${#package_name}
    local side=$(((80 - length)/2 - 1))
    local sign='*'


    color blue
    echo
    print_ruler "$sign" 80
    echo -n "$sign"
    gap $side
    color yellow
    echo -n $package_name
    color blue
    gap $side
    echo -n "$sign"
    echo
    print_ruler "$sign" 80
    echo
    no_color

}

run_cmake() {
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
	cd $(package_source_dir)

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
    echo $(args) \
        | awk '{print $2}'
}

cmdline() {
    check_source_dir
    check_remote_host $(host)
}
