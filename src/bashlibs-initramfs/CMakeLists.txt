cmake_minimum_required (VERSION 2.6)
project (bashlibs-initramfs)

list(APPEND CMAKE_MODULE_PATH
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "cpio,
    bashlibs-utils (>= 0.0.6),
    bashlibs-verbose (>= 0.0.5),
    bashlibs-file-manipulations")
include(PackageCreator)

