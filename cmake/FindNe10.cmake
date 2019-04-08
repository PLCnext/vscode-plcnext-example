# CMake Find Module for Ne10
# Project URL: https://github.com/projectNe10/Ne10
#
# Usage:
#
# Point the CMAKE_PREFIX_PATH variable to the Ne10 build and source directory.
#   find_package(Ne10 REQUIRED)

find_path(Ne10_INCLUDE_DIR NAMES NE10.h PATH_SUFFIXES "inc")
find_library(Ne10_LIBRARY NAMES NE10 PATH_SUFFIXES "modules")

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(Ne10
    DEFAULT_MSG
    Ne10_LIBRARY Ne10_INCLUDE_DIR
)

if(Ne10_FOUND)
    set(Ne10_LIBRARIES ${Ne10_LIBRARY})
    set(Ne10_INCLUDE_DIRS ${Ne10_INCLUDE_DIR})
endif()

if(Ne10_FOUND AND NOT TARGET Ne10::Ne10)
    add_library(Ne10::Ne10 UNKNOWN IMPORTED)
    set_target_properties(Ne10::Ne10 PROPERTIES
        IMPORTED_LOCATION "${Ne10_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Ne10_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(
    Ne10_INCLUDE_DIR Ne10_INCLUDE_DIRS
    Ne10_LIBRARY Ne10_LIBRARIES)
