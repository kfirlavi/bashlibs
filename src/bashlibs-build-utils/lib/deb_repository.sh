#!/bin/bash
include package_build.sh

repository_name() {
    echo bashlibs-repository
}

repository_store_dir() {
    create_dir_if_needed \
        $(progdir)/../debian
}

repository_dir() {
    local repo_name=${1:-$(repository_name)}

    create_dir_if_needed \
        $(repository_store_dir)/$repo_name/$(repository_architecture)
}

deb_archive_dir() {
    repository_dir deb-archive
}

repository_binary_dir() {
    create_dir_if_needed \
        $(repository_dir)/binary
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
    generate_binary_index
    generate_sources_index
}

repository_index_file_name() {
    local index_type=$1 # binary, source

    case $index_type in
        binary) echo Packages ;;
        source) echo Sources  ;;
    esac
}

generate_repository_index() {
    local repo_type=$1 # binary, source
    local arch=$2
    local repository_dir=$(realpath $3)
    local index_file_path=$repository_dir/$arch/$repo_type
    local index_file=$index_file_path/$(repository_index_file_name $repo_type).gz

    vinfo "Generating deb repository index"
    vinfo "repository path: $repository_dir"
    vinfo "repository architecture: $arch"
    vinfo "repository type: $repo_type"


    create_dir_if_needed $index_file_path > /dev/null

    cd $repository_dir/$arch

    dpkg-scanpackages $repo_type /dev/null 2> /dev/null \
        | gzip -9c > $index_file

    [[ -f $index_file ]] \
        && vinfo "$index_file generated" \
        || eexit "$index_file wasn't generated"

    cd - > /dev/null 2>&1
}

generate_binary_index() {
    generate_repository_index \
        binary \
        $(repository_architecture) \
        $(repository_dir)/..
}

generate_sources_index() {
    generate_repository_index \
        source \
        $(repository_architecture) \
        $(repository_dir)/..
}
