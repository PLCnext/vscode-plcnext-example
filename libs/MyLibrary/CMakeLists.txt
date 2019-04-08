cmake_minimum_required(VERSION 3.14)

project(MyLibrary)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

################# create target #######################################################

set (WILDCARD_SOURCE *.cpp)
set (WILDCARD_HEADER *.h *.hpp *.hxx)

file(GLOB_RECURSE Headers CONFIGURE_DEPENDS src/${WILDCARD_HEADER})
file(GLOB_RECURSE Sources CONFIGURE_DEPENDS src/${WILDCARD_SOURCE})

execute_process(
    COMMAND plcncli generate code -o "${PROJECT_BINARY_DIR}/intermediate/code"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}")

file(GLOB_RECURSE IntermediateCodeFiles CONFIGURE_DEPENDS
    ${PROJECT_BINARY_DIR}/intermediate/code/${WILDCARD_SOURCE}
    ${PROJECT_BINARY_DIR}/intermediate/code/${WILDCARD_HEADER})

add_custom_target(IntermediateCode
    COMMENT "Generating intermediate files with 'plcncli' tool."
    COMMAND plcncli generate code -o "${PROJECT_BINARY_DIR}/intermediate/code"
    COMMAND plcncli generate config -o "${PROJECT_BINARY_DIR}/intermediate/config"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    SOURCES ${IntermediateCodeFiles})

add_library(MyLibrary SHARED ${Headers} ${Sources} ${IntermediateCodeFiles})

add_dependencies(MyLibrary IntermediateCode)

#######################################################################################

################# project include-paths ###############################################

target_include_directories(MyLibrary
    PUBLIC
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/intermediate/code>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>)

#######################################################################################

################# include arp cmake module path #######################################

list(INSERT CMAKE_MODULE_PATH 0 "${ARP_TOOLCHAIN_CMAKE_MODULE_PATH}")

#######################################################################################

################# set link options ####################################################
# WARNING: Without --no-undefined the linker will not check, whether all necessary    #
#          libraries are linked. When a library which is necessary is not linked,     #
#          the firmware will crash and there will be NO indication why it crashed.    #
#######################################################################################

target_link_options(MyLibrary PRIVATE LINKER:--no-undefined)

#######################################################################################

################# add link targets ####################################################

find_package(ArpDevice REQUIRED)
find_package(ArpProgramming REQUIRED)
find_package(Ne10 REQUIRED)
find_package(jsoncpp REQUIRED)

target_link_libraries(MyLibrary PRIVATE ArpDevice ArpProgramming
    Ne10::Ne10
    jsoncpp_lib)

#######################################################################################

################# install ############################################################

install(TARGETS MyLibrary)

#######################################################################################
