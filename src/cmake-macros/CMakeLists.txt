cmake_minimum_required (VERSION 2.6)
project (cmake-macros)


set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/Modules")

include(SetAppVersion)
SET_APP_VERSION(0 0 2)
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "cmake (>= 2.6)")
include(PackageCreator)
include(InstallDocs)

install(
    DIRECTORY "Modules" 
    DESTINATION "usr/share/${PROJECT_NAME}"
)
