cmake_minimum_required (VERSION 2.6)
project (bashlibs-os-detection)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
include(SetAppVersion)
SET_APP_VERSION(0 0 3)
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "bashlibs-utils (>= 0.0.6),
    bashlibs-code-clarity")
include(PackageCreator)

include(InstallDocs)
