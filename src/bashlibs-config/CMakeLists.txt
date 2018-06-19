cmake_minimum_required (VERSION 2.6)
project (bashlibs-config)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "bashlibs-shunit2-enhancements (>= 0.0.16),
    bashlibs-string (>= 0.0.8),
    bashlibs-utils")
include(PackageCreator)

