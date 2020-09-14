include(SetAppVersion)
include(InstallDocs)
include(CPackSimple)

set(BASHLIBS_PATH_PREFIX "usr")
set(BASHLIBS_LIB_DIR   "${BASHLIBS_PATH_PREFIX}/lib/bashlibs")
set(BASHLIBS_BIN_DIR   "${BASHLIBS_PATH_PREFIX}/bin")
set(BASHLIBS_SHARE_DIR "${BASHLIBS_PATH_PREFIX}/share/bashlibs")
set(BASHLIBS_TESTS_DIR "${BASHLIBS_SHARE_DIR}/test")
set(BASHLIBS_CONF_DIR  "etc/bashlibs")

set(BASHLIBS_PROJECT_SHARE_DIR "${BASHLIBS_SHARE_DIR}/${CMAKE_PROJECT_NAME}")
set(BASHLIBS_PROJECT_TESTS_DIR "${BASHLIBS_TESTS_DIR}/${CMAKE_PROJECT_NAME}")
set(BASHLIBS_PROJECT_CONF_DIR  "${BASHLIBS_CONF_DIR}/${CMAKE_PROJECT_NAME}")


function(install_dir)

    set(src ${CMAKE_SOURCE_DIR}/${ARGV0})
    set(dst ${ARGV1})

    if(IS_DIRECTORY ${src})

         message(STATUS "Found: ${src}")
         message(STATUS "Installing ${src} to ${dst}")
         install(DIRECTORY ${src}/ DESTINATION ${dst})

    endif()

endfunction()


function(install_programs_dir)

    set(src ${CMAKE_SOURCE_DIR}/${ARGV0})
    set(dst ${ARGV1})

    if(IS_DIRECTORY ${src})

        file(GLOB filelist ${src}/*)
        list(REMOVE_ITEM filelist "${src}/CMakeLists.txt")

        if(filelist)

            message(STATUS "Found programs dir: ${src}")
            message(STATUS "Programs found: ${filelist}")
            message(STATUS "Installing programs to ${dst}")
            install(PROGRAMS ${filelist} DESTINATION ${dst})

        else(filelist)

            message(WARNING "Found an empty programs dir: ${src}")

        endif(filelist)

    endif(IS_DIRECTORY ${src})

endfunction(install_programs_dir)


function(search_and_replace_sources)

    set(ORIGINAL_STRING ${ARGV0})
    set(NEW_STRING ${ARGV1})
    message(STATUS "replacing '${ORIGINAL_STRING}' with '${NEW_STRING}'")

    execute_process(COMMAND find ${CMAKE_CURRENT_SOURCE_DIR} -type f -not -name "CMake*" -and -not -name "BashLibs.cmake" -print0 
                    COMMAND xargs -0 sed -i "s@${ORIGINAL_STRING}@${NEW_STRING}@g")

endfunction(search_and_replace_sources)


function(bashlibs_cmake_main)

    install_dir(lib   ${BASHLIBS_LIB_DIR})
    install_dir(share ${BASHLIBS_PROJECT_SHARE_DIR})
    install_dir(test  ${BASHLIBS_PROJECT_TESTS_DIR})
    install_programs_dir(bin ${BASHLIBS_BIN_DIR})

    search_and_replace_sources(__BASHLIBS_LIB_DIR__           /${BASHLIBS_LIB_DIR})
    search_and_replace_sources(__BASHLIBS_BIN_DIR__           /${BASHLIBS_BIN_DIR})
    search_and_replace_sources(__BASHLIBS_SHARE_DIR__         /${BASHLIBS_SHARE_DIR})
    search_and_replace_sources(__BASHLIBS_PROJECT_SHARE_DIR__ /${BASHLIBS_PROJECT_SHARE_DIR})
    search_and_replace_sources(__BASHLIBS_TESTS_DIR__         /${BASHLIBS_TESTS_DIR})
    search_and_replace_sources(__BASHLIBS_PROJECT_TESTS_DIR__ /${BASHLIBS_PROJECT_TESTS_DIR})

endfunction(bashlibs_cmake_main)
bashlibs_cmake_main()
