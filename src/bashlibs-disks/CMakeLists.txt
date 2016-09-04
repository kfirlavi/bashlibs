cmake_minimum_required (VERSION 2.6)
project (bashlibs-disks)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "bashlibs-utils,
    util-linux")
include(PackageCreator)

