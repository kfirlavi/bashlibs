set(version_file ${CMAKE_SOURCE_DIR}/version)

macro(SET_APP_VERSION)

    if(NOT EXISTS ${version_file})
        message(
            FATAL_ERROR
            "version file not found. You must supply a version file containing version like this: 0.0.4 for example.")
    endif()

    file(READ ${version_file} _ver)

    string(REGEX MATCH
        "^([0-9]+)\\.([0-9]+)\\.([0-9]+)"
        _output_match
        ${_ver})

	set(APP_VER_MAJOR ${CMAKE_MATCH_1})
	set(APP_VER_MINOR ${CMAKE_MATCH_2})
	set(APP_VER_PATCH ${CMAKE_MATCH_3})

    set(APPLICATION_VERSION
        "${APP_VER_MAJOR}.${APP_VER_MINOR}.${APP_VER_PATCH}")

    set(LIBRARY_VERSION
        "${APPLICATION_VERSION}")

    set(LIBRARY_SOVERSION
        ${APP_VER_MAJOR})

endmacro(SET_APP_VERSION)

if(NOT DEFINED APPLICATION_VERSION)
    SET_APP_VERSION()
    message(STATUS "App version: ${APPLICATION_VERSION}")
    message(STATUS "Library version: ${LIBRARY_VERSION}")
    message(STATUS "Library soversion: ${LIBRARY_SOVERSION}")
endif(NOT DEFINED APPLICATION_VERSION)
