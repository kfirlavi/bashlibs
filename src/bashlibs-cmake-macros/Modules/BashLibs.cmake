include(SetAppVersion)
include(InstallDocs)

set(BASH_LIBS_DIR 
    "usr/lib/bashlibs")

set(BASH_LIBS_TESTS_DIR 
    "usr/share/bashlibs/test")

file(GLOB _libs lib/*.sh)
INSTALL(FILES ${_libs} DESTINATION ${BASH_LIBS_DIR})

file(GLOB _tests test/*.sh)
INSTALL(FILES ${_tests} DESTINATION ${BASH_LIBS_TESTS_DIR})
