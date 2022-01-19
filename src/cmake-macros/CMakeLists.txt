cmake_minimum_required (VERSION 2.6)
project (cmake-macros)


list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_SOURCE_DIR}/Modules")

include(SetAppVersion)
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "cmake (>= 2.6)")
include(PackageCreator)
include(InstallDocs)

message(STATUS "App version: ${APPLICATION_VERSION}")

install(
    DIRECTORY "Modules"
    DESTINATION "usr/share/${PROJECT_NAME}"
)
