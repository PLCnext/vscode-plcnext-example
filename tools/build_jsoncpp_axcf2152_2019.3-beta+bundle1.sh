#!/bin/bash
# Build jsoncpp
# URL: https://github.com/open-source-parsers/jsoncpp

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

echo "${CMAKE_TOOLCHAIN_FILE}"
echo "${SDKROOT}"

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
-D JSONCPP_WITH_TESTS=OFF \
-D JSONCPP_WITH_POST_BUILD_UNITTEST=OFF \
-D JSONCPP_WITH_WARNING_AS_ERROR=OFF \
-D JSONCPP_WITH_STRICT_ISO=OFF \
-D JSONCPP_WITH_CMAKE_PACKAGE=ON \
-D BUILD_STATIC_LIBS=OFF \
-S "${DIR}/../external/jsoncpp-1.8.4" \
-B "${DIR}/../build/axcf2152_2019.3-beta+bundle1/external/jsoncpp" \

# Build the project
cmake --build "${DIR}/../build/axcf2152_2019.3-beta+bundle1/external/jsoncpp" --target install
