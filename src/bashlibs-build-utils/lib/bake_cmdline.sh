include usage.sh

usage() {
	set_column_indentation_gap 18
	cat <<- EOF
	$(section_usage) $(progname) options
	
	    $(progname) - a package builder utility
	    It can create a deb package for debian or ubuntu systems, and 
	    can create a gentoo source tbz package
	    A repositories dir will be created in the user home i.e /home/user/repositories or for root /root/repositories.
	    Inside the repositories you will find debian and gentoo files.
	    Package type to be generated is determined automatically checking the target os provided with --server.

	$(section_options)
	$(item s server 'IP or hostname of the target system. This option can be specified multiple times, to compile on different hosts')
	$(item p project 'project name or project path. Can be specified multiple times. If not specified, current working directory project will be selected')
	$(item i install 'compile on one traget and then deploy the package on another machine (no compilation). For now just Gentoo is supported')
	$(item C root 'path to sources tree, if current directory is not in the source tree')
	$(item l list 'list all projects in the tree')
	$(item d depend 'provide a list of packages that must be installed before compilation. $(progname) will install them before compilation.')
	$(item u apt-update 'update apt on ubuntu/debian like os after compilation')
	$(item c cmake-options 'cmake extra options')
	$(item r repository "repository name. Default is 'archive'. Will be created in $(repositories_dir). This option can be specified multiple times.")
	$(item m portage-tree-name "uniqeue name for the remote portage tree. It will be coppied to $(gentoo_local_portage_path)<name> on the server") 
	$(item e portage-tree "local portage tree. Will be copied to the server to $(gentoo_local_portage_path)<name>. Name is provided with -n")
	$(items_test_help_verbose_debug)
	
	$(section_examples)
	$(example_description 'Build package bashlibs-verbose for host 192.168.1.2')
	$(example $(progname) --server 192.168.1.2 --project src/bashlibs-verbose)

	$(example_description 'cd into src/bashlibs-verbose and bake will compile bashlibs-verbose, without providing --project')
	$(example $(progname) --server 192.168.1.2)

	$(example_description 'Build package bashlibs-verbose and bashlibs-colors for multiple hosts: gentoo, ubuntu32 and ubuntu64. For bashlibs-verbose we use path, and for bashlibs-colors we use project name and ask bake to find the project for us')
	$(example $(progname) -s gentoo -s ubuntu32 -s ubuntu64 -p src/bashlibs-verbose -p bashlibs-colors)

	$(example_description 'lets say I have few virtual machines that are the same, I want to compile on one but install on all')
	$(example_description 'this will create a fast install on gentoo using quickpkg')
	$(example $(progname) --server vm1 --install vm2 --install vm3 --project bashlibs-verbose)

	$(example_description 'Running outside of the source tree')
	$(example_description 'Lets say we are running bake from /tmp/ and the source tree is in /home/user/code:')
	$(example $(progname) --server 192.168.1.2 --project src/bashlibs-verbose --root /home/user/code)

	$(example_description 'Build a gentoo tbz package')
	$(example $(progname) --server 192.168.1.2 --project bashlibs-verbose --portage-tree portage --portage-tree-name aaa)

	$(example_description 'compilation require flex and bison')
	$(example $(progname) --server 192.168.1.2 --project bashlibs-verbose --depend flex --depend bison)

	$(example_description 'Add cmake definition, for example TARGET_OS=Linux, when building debian package')
	$(example $(progname) --server 192.168.1.2 --project bashlibs-verbose --cmake-options '-DTARGET_OS=Linux')

	$(example_description "This will create the repository 'aaa' in $(repositories_dir)")
	$(example $(progname) --server 192.168.1.2 --project bashlibs-verbose --repository aaa)
	$(example_description "Same as before but the package will reside in 'aaa' and 'bbb' repositories")
	$(example $(progname) --server 192.168.1.2 --project bashlibs-verbose --repository aaa --repository bbb)

	$(example_test $(progname))
	EOF
}

cmdline() {
    exit_if_args_are_empty $@
    SOURCES_TREE_PATH=$(pwd)

    # got this idea from here:
    # http://kirk.webfinish.com/2009/10/bash-shell-script-to-use-getopts-with-gnu-style-long-positional-parameters/
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            #translate --gnu-long-options to -g (short options)
                 --root) args="${args}-C ";;
              --project) args="${args}-p ";;
              --install) args="${args}-i ";;
                 --list) args="${args}-l ";;
               --depend) args="${args}-d ";;
           --update-apt) args="${args}-u ";;
               --server) args="${args}-s ";;
        --cmake-options) args="${args}-c ";;
           --repository) args="${args}-r ";;
    --portage-tree-name) args="${args}-m ";;
         --portage-tree) args="${args}-e ";;
                 --test) args="${args}-t ";;
                 --help) args="${args}-h ";;
              --verbose) args="${args}-v ";;
                --quiet) args="${args}-q ";;
                --debug) args="${args}-x ";;
                      #pass through anything else
                      *) [[ "${arg:0:1}" == "-" ]] || delim="\""
                          args="${args}${delim}${arg}${delim} ";;
        esac
    done
     
    #Reset the positional parameters to the short options
    eval set -- $args

    while getopts "qvhxlutp:d:s:k:c:r:m:e:C:i:" OPTION
    do
        case $OPTION in
        q)
            set_quiet_mode
            ;;
        v)
            increase_verbose_level
            ;;
        h)
            usage
            exit
            ;;
        x)
            set -x
            ;;
        t)
            RUN_TESTS=1
            ;;
        s)
            TARGET_BUILD_HOSTS="$TARGET_BUILD_HOSTS $OPTARG"
            ;;
        C)
            SOURCES_TREE_PATH=$OPTARG
            ;;
        p)
            PROJECTS="$PROJECTS $OPTARG"
            ;;
        i)
            HOSTS_TO_INSTALL_BIN_PACKAGES="$HOSTS_TO_INSTALL_BIN_PACKAGES $OPTARG"
            ;;
        l)
            readonly LIST_PROJECTS=1
            ;;
        d)
            PRE_COMPILE_DEPEND="$PRE_COMPILE_DEPEND $OPTARG"
            ;;
        u)
            readonly UPDATE_APT=1
            ;;
        c)
            CMAKE_OPTIONS="$CMAKE_OPTIONS $OPTARG"
            ;;
        r)
            REPOSITORIES_NAMES="$REPOSITORIES_NAMES $OPTARG"
            ;;
        e)
            PORTAGE_TREE=$OPTARG
            ;;
        m)
            PORTAGE_TREE_NAME=$OPTARG
            ;;
        esac
    done

    # commandline arguments have precedence on configuration files
    if_defined_declare_readonly REPOSITORIES_NAMES
    if_defined_declare_readonly CMAKE_OPTIONS
    if_defined_declare_readonly PORTAGE_TREE
    if_defined_declare_readonly PORTAGE_TREE_NAME
    if_defined_declare_readonly PRE_COMPILE_DEPEND
    if_defined_declare_readonly TARGET_BUILD_HOSTS
    if_defined_declare_readonly HOSTS_TO_INSTALL_BIN_PACKAGES
}

project_names_to_bake_commandline() {
    local project_names=$@
    local i

    for i in $project_names
    do
        echo -n "-p $i "
    done
}
