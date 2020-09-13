include(SetAppVersion)
include(InstallDocs)

set(CPACK_PACKAGING_INSTALL_PREFIX "/")

set(BASH_LIBS_DIR 
    "usr/lib/bashlibs")

set(BASH_LIBS_TESTS_DIR 
    "usr/share/bashlibs/test/${CMAKE_PROJECT_NAME}")

set(BASH_LIBS_BIN_DIR 
    "usr/bin")

file(GLOB _libs lib/*.sh)
INSTALL(FILES ${_libs} DESTINATION ${BASH_LIBS_DIR})

file(GLOB _tests test/*.sh)
INSTALL(FILES ${_tests} DESTINATION ${BASH_LIBS_TESTS_DIR})

file(GLOB _files_dir test/files)
INSTALL(DIRECTORY ${_files_dir} DESTINATION ${BASH_LIBS_TESTS_DIR})

file(GLOB _bin bin/*)
INSTALL(PROGRAMS ${_bin} DESTINATION ${BASH_LIBS_BIN_DIR})
