# This module will define the compilation variable
# OS_LINUX

IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	message(STATUS "Using Linux specific code")
	SET(OS "Linux")
	add_definitions(-DOS_LINUX)
	add_definitions(-DLINUX)
	add_definitions(-DLinux)
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

execute_process(COMMAND "bashlibs" "--include os_detection.sh --run is_ubuntu"
    RESULT_VARIABLE LINUX_UBUNTU)

execute_process(COMMAND "bashlibs" "--include os_detection.sh --run is_gentoo"
    RESULT_VARIABLE LINUX_GENTOO)

if(LINUX_UBUNTU MATCHES 0)
    set(LINUX_DISTRO ubuntu)
    add_definitions(-DLINUX_UBUNTU)
endif(LINUX_UBUNTU MATCHES 0)

if(LINUX_GENTOO MATCHES 0)
    set(LINUX_DISTRO gentoo)
    add_definitions(-DLINUX_GENTOO)
endif(LINUX_GENTOO MATCHES 0)

if(LINUX_DISTRO)
    message(STATUS "Linux distro is ${LINUX_DISTRO}")
    message(STATUS "Defining variable: LINUX_DISTRO=${LINUX_DISTRO}")
endif(LINUX_DISTRO)
