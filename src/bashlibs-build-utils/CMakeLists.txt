cmake_minimum_required (VERSION 2.6)
project (bashlibs-build-utils)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS 
    "bashlibs-shunit2-enhancements (>= 0.0.11),
    realpath,
    dpkg-dev,
    bashlibs-cmdline (>= 0.0.2),
    bashlibs-base (>= 0.0.10),
    bashlibs-usage (>= 0.0.11),
    bashlibs-directories (>= 0.0.4),
    bashlibs-verbose (>= 0.0.25),
    bashlibs-utils (>= 0.0.11)")
include(PackageCreator)
