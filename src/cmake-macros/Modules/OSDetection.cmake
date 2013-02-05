# This module will define the compilation variable
# OS_LINUX

IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	message(STATUS "Using Linux specific code")
	SET(OS "Linux")
	add_definitions(-DOS_LINUX)
	add_definitions(-DLINUX)
	add_definitions(-DLinux)
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
