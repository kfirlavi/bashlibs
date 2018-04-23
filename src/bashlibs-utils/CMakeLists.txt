cmake_minimum_required (VERSION 2.6)
project (bashlibs-utils)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "bashlibs-shunit2-enhancements (>= 0.0.2),
    bashlibs-code-clarity (>= 0.0.2),
    bashlibs-verbose (>= 0.0.5),
    bashlibs-usage (>= 0.0.2),
    bashlibs-base (>= 0.0.7)")
include(PackageCreator)
