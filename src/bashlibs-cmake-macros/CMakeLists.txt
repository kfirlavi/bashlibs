cmake_minimum_required (VERSION 2.6)
project (bashlibs-cmake-macros)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")

include(SetAppVersion)
SET_APP_VERSION(0 0 2)

set(CPACK_PACKAGING_INSTALL_PREFIX "/")
include(PackageCreator)

include(InstallDocs)

install(DIRECTORY "Modules" DESTINATION "usr/share/bashlibs/cmake-macros")
