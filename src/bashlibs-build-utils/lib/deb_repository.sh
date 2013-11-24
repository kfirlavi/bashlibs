#!/bin/bash
include package_build.sh

repository_name() {
    echo bashlibs-repository
}

repository_dir() {
    create_dir_if_needed \
        $(progdir)/../debian/$(repository_name)/$(repository_architecture)
}

repository_binary_dir() {
    create_dir_if_needed \
        $(repository_dir)/binary
}

run_remote() {
    ssh root@$(host) -- $@
}

target_architecture() {
    run_remote "uname -i"
}

repository_architecture() {
    local arch=$(target_architecture)

    case $arch in
        armv7l) echo armhf ;;
          i686) echo i386  ;;
          i386) echo i386  ;;
        x86_64) echo amd64 ;;
    esac
}

deb_archive_dir() {
    create_dir_if_needed \
        $(progdir)/../debian/deb-archive/$(repository_architecture)
}

copy_deb_to_repository() {
    local debfile=$1

    rsync -a \
        $debfile \
        $(repository_binary_dir)
}

uniq_packages() {
    local dir=$1
    local package=

    for package in $(ls -1 $dir/*deb)
    do
        package_name $package
    done \
        | sort \
        | uniq
}

package_name_part() {
    local package=$1
    local field=$2

    echo $package \
        | rev \
        | cut -d '-' -f $field \
        | rev
}

package_name() {
    local package=$1

    package_name_part $package 3-
}

package_version() {
    local package=$1

    package_name_part $package 2
}

package_postfix() {
    local package=$1

    package_name_part $package 1
}

packages_versions() {
    local packages=$@
    local package=

    for package in $packages
    do
        package_version $package
    done
}

sort_versions() {
    local versions=$@

    echo $versions \
        | tr ' ' '\n' \
        | sort -k1,1n -k2,2n -k3,3n -t.
}

max_version() {
    local versions=$@

    sort_versions $versions \
        | tr ' ' '\n' \
        | tail -1
}

all_versions_of_pacakge() {
    local package_prefix=$1

    echo $(ls -1 ${package_prefix}*)
}

package_by_version() {
    local package_prefix=$1
    local version=$2
    local path=$(dirname $package_prefix)

    find $path -ipath "${package_prefix}-${version}*"
}

newest_package() {
    local package_prefix=$1
    local all_packages=$(all_versions_of_pacakge $package_prefix)
    local all_versions=$(packages_versions $all_packages)
    local max_ver=$(max_version $all_versions)

    echo $(package_by_version $package_prefix $max_ver)
}

copy_newest_debs_to_repository() {
    local i

    for i in $(uniq_packages $(deb_archive_dir))
    do
        copy_deb_to_repository \
            $(newest_package $i)
    done
}

create_repository() {
    copy_newest_debs_to_repository
    $(progdir)/debrepos $(repository_dir)
}
