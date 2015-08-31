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
	$(item s server 'IP or hostname of the target system')
	$(item p project-path 'path to the project you want to build')
	$(item f find 'project name you want to build - case insensitive (project name provided by CMakeLists.txt)')
	$(item l list 'list all projects in the tree')
	$(item d depend 'provide a list of packages that must be installed before compilation. $(progname) will install them before compilation.')
	$(item u apt-update 'update apt on ubuntu/debian like os after compilation')
	$(item c cmake-options 'cmake extra options')
	$(item r repository "repository name. Default is 'archive'. Will be created in $(repositories_dir). This option can be specified multiple times.")
	$(item m portage-tree-name "uniqeue name for the remote portage tree. It will be coppied to $(gentoo_local_portage_path)<name> on the server") 
	$(item e portage-tree "local portage tree. Will be copied to the server to $(gentoo_local_portage_path)<name>. Name is provided with -n")
	$(items_test_help_verbose_debug)
	
	$(section_examples)
	$(example_description 'Build a debian package')
	$(example $(progname) --server 192.168.1.2 --project-path src/bashlibs-verbose)

	$(example_description 'Same as above but using --find flag')
	$(example $(progname) --server 192.168.1.2 --find bashlibs-verbose)

	$(example_description 'Build a gentoo tbz package')
	$(example $(progname) --server 192.168.1.2 --find bashlibs-verbose --portage-tree portage --portage-tree-name aaa)

	$(example_description 'compilation require flex and bison')
	$(example $(progname) --server 192.168.1.2 --find bashlibs-verbose --depend flex --depend bison)

	$(example_description 'Add cmake definition, for example TARGET_OS=Linux, when building debian package')
	$(example $(progname) --server 192.168.1.2 --find bashlibs-verbose --cmake-options '-DTARGET_OS=Linux')

	$(example_description "This will create the repository 'aaa' in $(repositories_dir)")
	$(example $(progname) --server 192.168.1.2 --find bashlibs-verbose --repository aaa)
	$(example_description "Same as before but the package will reside in 'aaa' and 'bbb' repositories")
	$(example $(progname) --server 192.168.1.2 --find bashlibs-verbose --repository aaa --repository bbb)

	$(example_test $(progname))
	EOF
}

cmdline() {
    exit_if_args_are_empty $@

    # got this idea from here:
    # http://kirk.webfinish.com/2009/10/bash-shell-script-to-use-getopts-with-gnu-style-long-positional-parameters/
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            #translate --gnu-long-options to -g (short options)
         --project-path) args="${args}-p ";;
                 --find) args="${args}-f ";;
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
                --debug) args="${args}-x ";;
                      #pass through anything else
                      *) [[ "${arg:0:1}" == "-" ]] || delim="\""
                          args="${args}${delim}${arg}${delim} ";;
        esac
    done
     
    #Reset the positional parameters to the short options
    eval set -- $args

    while getopts "vhxlut:p:f:d:s:k:c:r:m:e:" OPTION
    do
        case $OPTION in
        v)
            VERBOSE=$(($VERBOSE+1))
            export readonly VERBOSE
            ;;
        h)
            usage
            exit
            ;;
        x)
            set -x
            ;;
        t)
            RUN_TESTS=$OPTARG
            vinfo "Running tests"
            ;;
        s)
            readonly TARGET_BUILD_HOST=$OPTARG
            ;;
        p)
            readonly PROJECT_PATH=$(cd $OPTARG; pwd)
            ;;
        f)
            readonly PROJECT_NAME=$OPTARG
            readonly PROJECT_CMAKE_FILE=$(cmake_project_file $PROJECT_NAME)
            readonly PROJECT_PATH=$(cd $(dirname $PROJECT_CMAKE_FILE); pwd)
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

    [[ -n $LIST_PROJECTS ]] \
        && list_projects

    # commandline arguments have precedence on configuration files
    if_defined_declare_readonly REPOSITORIES_NAMES
    if_defined_declare_readonly CMAKE_OPTIONS
    if_defined_declare_readonly PORTAGE_TREE
    if_defined_declare_readonly PORTAGE_TREE_NAME
    if_defined_declare_readonly PRE_COMPILE_DEPEND
    if_defined_declare_readonly TARGET_BUILD_HOST

    load_configuration_files

    readonly REPOSITORIES_NAMES
    readonly CMAKE_OPTIONS
    readonly PORTAGE_TREE
    readonly PORTAGE_TREE_NAME
    readonly PRE_COMPILE_DEPEND

    [[ -z $PROJECT_NAME && -z $PROJECT_PATH ]] \
        && eexit "project name or project path need to be provided. None was given."
    check_project_name
    check_project_path
    verify_target_build_host
    check_gentoo_commands
}
