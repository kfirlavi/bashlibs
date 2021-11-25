cmake_minimum_required (VERSION 2.6)
project (bashlibs-net)

list(APPEND CMAKE_MODULE_PATH
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "bashlibs-utils,
    bashlibs-sysfs (>=0.0.11),
    bashlibs-config,
    bashlibs-directories,
    bridge-utils")
include(PackageCreator)

