cmake_minimum_required (VERSION 2.6)
project (bashlibs-cmake-macros)

list(APPEND CMAKE_MODULE_PATH
    "/usr/share/cmake-macros/Modules")

list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_SOURCE_DIR}/Modules")

include(BashLibs)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "cmake-macros")
include(PackageCreator)

install(
    DIRECTORY "Modules"
    DESTINATION "${BASHLIBS_SHARE_DIR}/cmake-macros")
