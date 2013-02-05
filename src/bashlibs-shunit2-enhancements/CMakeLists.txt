cmake_minimum_required (VERSION 2.6)
project (bashlibs-shunit2-enhancements)

list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/cmake-macros/Modules")
list(APPEND CMAKE_MODULE_PATH 
    "/usr/share/bashlibs/cmake-macros/Modules")

include(BashLibs)
include(SetAppVersion)
SET_APP_VERSION(0 0 6)
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "shunit2, 
    bashlibs-utils (>= 0.0.6),
    bash")
include(PackageCreator)

include(InstallDocs)
