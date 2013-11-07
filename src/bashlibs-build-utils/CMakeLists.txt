cmake_minimum_required (VERSION 2.6)
project (bashlibs-build-utils)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "shunit2, bash, bashlibs-utils")
include(PackageCreator)

