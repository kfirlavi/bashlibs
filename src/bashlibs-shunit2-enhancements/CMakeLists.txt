cmake_minimum_required (VERSION 2.6)
project (bashlibs-shunit2-enhancements)

list(APPEND CMAKE_MODULE_PATH
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "shunit2,
    bashlibs-checks,
    bashlibs-utils (>= 0.0.6)")
include(PackageCreator)

