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

app_version() {
	cat $(project_path)/version
}

gen_changelog() {
	cd $(project_path)
	git --no-pager log . > ChangeLog
	cd - > /dev/null 2>&1
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

remote_apt_installation_fix() {
    vinfo "fixing apt installation"

	run_remote \
        DEBIAN_FRONTEND=noninteractive \
        apt-get \
            --assume-yes \
            --force-yes \
            --allow-unauthenticated \
            -f \
            install

}

remote_dist_upgrade() {
    remote_apt_installation_fix

    vinfo "issuing dist-upgrade to solve dependencies"

	run_remote \
        DEBIAN_FRONTEND=noninteractive \
        apt-get \
            --assume-yes \
            --force-yes \
            --allow-unauthenticated \
            dist-upgrade

}

install_deb() {
    vinfo "Installing $(cmake_deb_filename) on $(host)"
	run_remote \
        dpkg -i --force-depends \
        /var/cache/apt/archives/$(cmake_deb_filename)

    remote_dist_upgrade
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
