cmake_minimum_required (VERSION 2.6)
project (bashlibs-ssh)

list(APPEND CMAKE_MODULE_PATH
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "nmap,
    sshpass,
	bashlibs-verbose (>= 0.0.32),
	bashlibs-directories (>= 0.0.18),
	bashlibs-utils")
include(PackageCreator)

