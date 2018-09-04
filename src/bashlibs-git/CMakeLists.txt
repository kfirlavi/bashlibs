cmake_minimum_required (VERSION 2.6)
project (bashlibs-git)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "bashlibs-utils,
    bashlibs-directories,
    git,
    bashlibs-shunit2-enhancements (>=0.0.17)")
include(PackageCreator)

