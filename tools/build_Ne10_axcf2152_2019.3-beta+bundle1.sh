#!/bin/bash
# Build Ne10
# URL: https://github.com/projectNe10/Ne10

print_usage()
{
    echo ""
    echo "  -t      Path to CMake toolchain file."
    echo "          Can also be specified from the"
    echo "          environment variable CMAKE_TOOLCHAIN_FILE"
    echo "  -p      Path to the SDK installation root directory."
    echo "          Can also be specified from the environment"
    echo "          variable SDKROOT"
    echo ""
    echo "Usage:"
    echo ""
    echo "  $(basename "$0") -t /opt/pxc/2019.0/toolchain.cmake -p /opt/pxc/2019.0"
    echo ""
}

## Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

while getopts t:p: option
do
    case "${option}" in
        t) CMAKE_TOOLCHAIN_FILE="${OPTARG}";;
        p) SDKROOT="${OPTARG}";;
        ?) print_usage
           exit 1
    esac
done

if [ ! -d "${SDKROOT}" ]; then
    echo "Error: SDKROOT directory not found."
    print_usage
    exit 2
elif [ ! -f "${CMAKE_TOOLCHAIN_FILE}" ]; then
    echo "Error: CMAKE_TOOLCHAIN_FILE file not found."
    print_usage
    exit 3
fi

# Run CMake
cmake \
-G "Ninja" \
-D CMAKE_BUILD_TYPE=Release \
-D BUILD_TESTING=OFF \
-D BUILD_SHARED_LIBS=ON \
-D "CMAKE_STAGING_PREFIX=${DIR}/../build/axcf2152_2019.3-beta+bundle1/out" \
-D "CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}" \
-D "ARP_TOOLCHAIN_ROOT=${SDKROOT}" \
-D BUILD_DEBUG=OFF \
-D GNULINUX_PLATFORM=ON \
-D NE10_LINUX_TARGET_ARCH=armv7 \
-D NE10_BUILD_STATIC=OFF \
-D NE10_BUILD_SHARED=ON \
-D NE10_BUILD_EXAMPLES=OFF \
-D NE10_BUILD_UNIT_TEST=OFF \
-S "${DIR}/../external/Ne10-1.2.1" \
-B "${DIR}/../build/axcf2152_2019.3-beta+bundle1/external/Ne10" \

# Build the project
cmake --build "${DIR}/../build/axcf2152_2019.3-beta+bundle1/external/Ne10"
