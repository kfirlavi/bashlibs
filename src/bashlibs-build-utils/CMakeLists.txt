cmake_minimum_required (VERSION 2.6)
project (bashlibs-build-utils)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_PACKAGE_DEPENDS 
    "shunit2,
    bash,
    bashlibs-shunit2-enhancements (>= 0.0.9),
    bashlibs-usage (>= 0.0.8),
    bashlibs-utils (>= 0.0.11)")
include(PackageCreator)

add_subdirectory(bin)
