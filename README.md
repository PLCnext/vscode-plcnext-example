---
title: Use Visual Studio Code with PLCnext
author:
  - name: Björn Sauer
    email: bjoern.sauer@phoenixcontact.de
    company: PHOENIX CONTACT Deutschland GmbH
version: "01"
date: "2019-03-28"
---

# PLCnext with Visual Studio Code

This example shows how to create PLCnext Component libraries with Visual Studio Code. The project layout should be capable of handling multiple PLCnext SDK versions and different controller targets.

This example was made with the following software:

* Ubuntu 18.04.02 LTS as development environment.
* Visual Studio Code version 1.32.3  
* Visual Studio Code Extensions:
    * CMake (twxs.cmake) version 0.0.17
    * CMake Tools (ms-vscode.cmake-tools) version 1.2.3
    * C/C++ (ms-vscode.cpptools) version 0.22.1
* PLCnext SDK 2019.0 LTS for AXC F 2152
* PLCnext SDK 2019.3 beta bundle 1 for AXC F 2152

# Extensions

Install the listed extension into Visual Studio Code

* CMake Tools (ms-vscode.cmake-tools)
* CMake (twxs.cmake)
* C/C++ (ms-vscode.cpptools)

Optional extensions

* EditorConfig for VS Code (editorconfig.editorconfig)  
  Support [EditorConfig](https://editorconfig.org) files in Visual Studio Code.

* sftp (liximomo.sftp)  
  Easy sftp file transfer out of Visual Studio Code.

* markdownlint (davidanson.vscode-markdownlint)  
  Markdown/CommonMark linting and style checking for Visual Studio Code.

* XML Tools (dotjoshjohnson.xml)  
  XML file formatter.

* Code Spell Checker (streetsidesoftware.code-spell-checker) with according language packs.  
  Spelling Checker for Visual Studio Code.

# Project layout

Create the project layout. The project layout uses the [Pitchfork layout convention](https://api.csswg.org/bikeshed/?force=1&url=https://raw.githubusercontent.com/vector-of-bool/pitchfork/develop/data/spec.bs).

```no-highlight
mkdir workspace-folder
cd workspace-folder
mkdir {cmake,build,tools,external,libs}
```

Create the PLCnext Component library project. We use `ExampleA13b` as root namespace.

```no-highlight
plcncli new project -n MyLibrary -c MyComponent -p MyProgram -s ExampleA13b.MyLibrary -o libs/MyLibrary
```

The PLCnext project is created in the `libs` subdirectory because of the plcncli command line tool. This tool is needed later on to parse the project source files. If the tool is called from the workspace root directory it would also scan all source directories of external third party projects and would fail.

Create the top level `CMakeLists.txt` file in the workspace root directory.

```cmake
cmake_minimum_required(VERSION 3.14)
project(plcnext-vscode-example)
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
add_subdirectory(libs/MyLibrary)
```

The workspace `cmake` folder is appended to the `CMAKE_MODULE_PATH` list. Workspace wide CMake scripts and Find Modules can be placed in this location.

Create the `.gitignore` file in the workspace root directory.

```no-highlight
.vscode/
build/
```

This excludes the `.vscode` and `build` folder from being versioned by git.

The file `.editorconfig` in the workspace root directory defines editor settings for file types.

```no-highlight
root = true

[*]
end_of_line = lf
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true

[*.{md,markdown}]
trim_trailing_whitespace = false
```

The file `.clang-format` in the workspace root directory defines formatting rules for c/c++ files. The format rules can be applied by triggering the `Format Document` Command from withing vscode. The clang-format executable is included in the cpptools extension from Microsoft.

```no-highlight
---
Language: Cpp
Standard: Cpp11
UseTab: Never
IndentWidth: 4
AccessModifierOffset: -4
BreakBeforeBraces: Allman
BreakConstructorInitializers: BeforeComma
Cpp11BracedListStyle: true
DerivePointerAlignment: true
FixNamespaceComments: true
AllowShortIfStatementsOnASingleLine: false
IndentCaseLabels: false
ColumnLimit: 0
...
```

# CMake Tools extension

Edit the vscode workspace settings located in  `./vscode/settings.json`. Change the CMake Build Directory setting. CMake Tools should place the build directories of the different targets and SDK version in separate directories. So the build directory don't has to be overwritten just by changing the target to compile for.

```json
{
    "cmake.buildDirectory": "${workspaceFolder}/build/${buildKit}",
}
```

There are two variables used in the build Directory. The variable `workspaceFolder` points to the current workspace directory opened by vscode. The second variable `buildKit` is defined from the CMake Tools extension and expands to the name of the selected cmake-kit.

Create the CMake Kits file `./vscode/cmake-kits.json`. The CMake Kits file is used from the CMake Tools extension and defines so called build kits to configure the CMake build environment.

```json
[
    {
        "name": "axcf2152_2019.0",
        "toolchainFile": "/opt/pxc/axcf2152_2019.0/toolchain.cmake",
        "cmakeSettings": {
            "CMAKE_EXPORT_COMPILE_COMMANDS": "ON",
            "CMAKE_STAGING_PREFIX": "${workspaceFolder}/build/${buildKit}/out",
            "CMAKE_PREFIX_PATH": [
                "${workspaceFolder}/build/${buildKit}/out",
                "${workspaceFolder}/build/${buildKit}/external/Ne10",
                "${workspaceFolder}/external/Ne10-1.2.1"
            ],
            "ARP_TOOLCHAIN_ROOT": "/opt/pxc/axcf2152_2019.0",
            "ARP_DEVICE": "AXCF2152",
            "ARP_DEVICE_VERSION": "2019.0 LTS (19.0.0.17548  )"
        },
        "preferredGenerator": {
            "name": "Ninja"
        }
    },
    {
        "name": "axcf2152_2019.3-beta+bundle1",
        "toolchainFile": "/opt/pxc/axcf2152_2019.3-beta+bundle1/toolchain.cmake",
        "cmakeSettings": {
            "CMAKE_EXPORT_COMPILE_COMMANDS": "ON",
            "CMAKE_STAGING_PREFIX": "${workspaceFolder}/build/${buildKit}/out",
            "CMAKE_PREFIX_PATH": [
                "${workspaceFolder}/build/${buildKit}/out",
                "${workspaceFolder}/build/${buildKit}/external/Ne10",
                "${workspaceFolder}/external/Ne10-1.2.1"
            ],
            "ARP_TOOLCHAIN_ROOT": "/opt/pxc/axcf2152_2019.3-beta+bundle1",
            "ARP_DEVICE": "AXCF2152",
            "ARP_DEVICE_VERSION": "2019.3 (19.3.0.18161 beta)"
        },
        "preferredGenerator": {
            "name": "Ninja"
        }
    }
]
```

In the CMake Kits file there are two build kits declared. The build kit `axcf2152_2019.0.0` is the build configuration for the 2019.0 LTS release of the PLCnext SDK. The build kit `axcf2152_2019.3-beta+bundle1` is the build configuration for the 2019.3 beta Bundle 1 release of the PLCnext SDK. Other targets and SDK version could be declared in the same manner.

The build kit names follow the notation `TargetName_SdkVersionName[-PreRelease][+BuildMeta]`. This naming scheme is used in the workspace to name the different targets and SDKs in use. Ideally the SDK is also installed in an location that follows this naming.

The `CMAKE_PREFIX_PATH` variable includes several prefix location to find external dependencies that are used by the project. The declared paths are explained later on.

The variable `${buildKit}` is defined from the CMake Tools extension and expands to the name of the currently selected build kit.

The `toolchainFile` option points to the CMake Toolchain file that is used in the CMake build environment.

The `cmakeSettings` option is a map of variables that are passed to the CMake configure call.

* CMAKE_EXPORT_COMPILE_COMMANDS:  
  CMake creates an compilation database file `compile_commands.json` in the build directory. This file is used later on to set up the intellisense configuration for the project.

* CMAKE_STAGING_PREFIX:  
  Installation prefix on cross compiling. This path is used on install time when cross compiling.

* CMAKE_PREFIX_PATH:  
  A list of additional search prefix paths to search for files, libraries, etc.

* ARP_TOOLCHAIN_ROOT:  
  PLCnext toolchain specific variable. This variable must point to the installation directory of the used PLCnext SDK.

* ARP_DEVICE:
  PLCnext toolchain specific variable. This variable must be set to the used Controller type.

* ARP_DEVICE_VERSION:  
  PLCnext toolchain specific variable. This variable must be set to the exact version string of the used PLCnext SDK. This variable is used to check the SDK compatibility. This compatibility check can be disabled by setting the variable `ARP_CHECK_DEVICE_VERSION=OFF`.

The `preferredGenerator` option defines the preferred CMake generator to use. The executable of the generator has to be found in the system PATH environment variable. The executable can also be directly specified by setting the CMake variable `CMAKE_MAKE_PROGRAM` to the absolute path to the native build executable. This is needed if the Unix Makefiles generator is used on a Windows based build host. The `CMAKE_MAKE_PROGRAM` variable should then be set to absolute path to the make.exe executable included in the PLCnext SDK.

The active CMake build kit can now be selected from the status bar in Visual Studio Code.

# Changes to the PLCnext CMake file

Edit the `libs/MyLibrary/CMakeLists.txt` file. First we want to achieve to generate the needed intermediate code and config files of the PLCnext component library with the plcncli tool on each build.

```cmake
################# create target ###############################################

set(WILDCARD_SOURCE *.cpp)
set(WILDCARD_HEADER *.h *.hpp *.hxx)

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

add_library(MyLibrary SHARED
    ${Headers}
    ${Sources}
    ${IntermediateCodeFiles})

add_dependencies(MyLibrary IntermediateCode)

###############################################################################
```

Several changes happened here. The `CONFIGURE_DEPENDS` option was added to the `file` command. This triggers a scan for additional source files on build time.

The `file` command no longer includes the intermediate/code directory. This glob expression was moved to an own command after first calling a process to generate the files on configure time.

The `execute_process` command runs the plcncli tool to generate the intermediate code on CMake configure time. This makes sure that the code files are available for the `file` call that follows the `execute_process`.

The custom target IntermediateCode is defined with the `add_custom_target` command. This target runs the plcncli tool to generate the intermediate code files on build time.

The MyLibrary target depends on this custom target to generate the intermediate code before the library is built.

Notice that the generated code and config files from the plcncli tool are generated in the `PROJECT_BINARY_DIR`. This emits the files in the build directory of the project.

The include paths of the MyLibrary target have to be updated to include the location of the generated code.

```cmake
################# project include-paths #######################################

target_include_directories(MyLibrary
    PUBLIC
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/intermediate/code>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>)

###############################################################################
```

This example of a PLCnext component library uses the [Ne10](https://github.com/projectNe10/Ne10) and [jsoncpp](https://github.com/open-source-parsers/jsoncpp) libraries. These dependencies have to be included in the CMake configuration.


```cmake
################# add link targets ############################################

find_package(ArpDevice REQUIRED)
find_package(ArpProgramming REQUIRED)
find_package(Ne10 REQUIRED)
find_package(jsoncpp REQUIRED)

target_link_libraries(MyLibrary PRIVATE ArpDevice ArpProgramming
    Ne10::Ne10
    jsoncpp_lib)

###############################################################################
```

The `find_package` command includes the target definition of the libraries.

The Ne10 library has a poor out of box CMake support. It comes without a CMake config package file and therefore needs to be included by writing a CMake find module. This user defined `FindNe10.cmake` find module is located in the `cmake` folder in the workspace root directory.

A find module searches all library related files. Then a CMake target for the library is defined that later on can easily be consumed by CMake. To learn more about writing CMake find modules read the official [CMake developer documentation](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html#find-modules).

CMake find module has to find the Ne10 library and header files. To find these files the build and the source directories of the Ne10 library have to be added to the `CMAKE_PREFIX_PATH` variable. This is because the Ne10 headers are located in inc folder of the source directory and the library is generated in the modules folder of the build directory. Look at the CMake Kits `.vscode/cmake-kits.json` file. For each build the `CMAKE_PREFIX_PATH` includes the according directories.

The `cmake/FindNe10.cmake` file

```cmake
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
```

The jsoncpp library comes with support for a CMake config package that can easily be consumed from the install location. The library has just to be installed into a local directory. By including the installation directory into the `CMAKE_PREFIX_PATH` variable CMake can find this package. To learn more about CMake packages read the [CMake packages documentation](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#cmake-packages-7).

The install location for this workspace is always in the build folder of the specific CMake Tools build kit. Take a look at the build kit file `./vscode/build-kits.cmake`. The `CMAKE_STAGING_PREFIX` variable is set to the `out` folder in the build directory.

```json
{
    ...
    "CMAKE_STAGING_PREFIX": "${workspaceFolder}/build/${buildKit}/out",
    ...
}
```

Finally the install command in `libs/MyLibrary/CMakeLists.txt` file is modified to output the library into a standard unix directory layout on install. Libraries will be located in the lib folder, header files in include and binaries in bin. This makes consuming the files with other tooling much more easy.

```cmake
################# install #####################################################

install(TARGETS MyLibrary)

###############################################################################
```

# Building the dependencies

The third party libraries [Ne10](https://github.com/projectNe10/Ne10) and [jsoncpp](https://github.com/open-source-parsers/jsoncpp) that are used by this example have to be cross compiled with the PLCnext toolchain.

For each dependency and target a build script is created in the `tools` folder of the workspace root directory. These scripts build the dependencies with the build system that is used by the project. In case of Ne10 and jsoncpp this is CMake.

The script names are kept in the format `build_ProjectName_TargetName_SdkVersionName[-PreRelease][+BuildMeta].sh`. Each build script should have a corresponding project directory in the `external` folder of the workspace root directory.

In order to keep the build scripts independent from the local build host the CMake variables `CMAKE_TOOLCHAIN_FILE` and `ARP_TOOLCHAIN_ROOT` needed to build the projects with the PLCnext toolchain have to be defined. The scripts expect these settings via the environment variables `CMAKE_TOOLCHAIN_FILE` and `SDKROOT` or the options `-t` and `-p`. These variables have to be set to the local absolute paths of the toolchain that should be used to compile the project.

The script should install the dependencies in the appropriate build directory of the build kit. This is the `out` folder in the build directory of the used build kit `./build/${buildKit}/out`. Keep the `out` directory in a unix file system structure. E.g. place libraries in `lib` and header files in `include` folder.

Example for calling the scripts

```no-highlight
tools/build_jsoncpp_axcf2152_2019.0.sh \
-t /opt/pxc/axcf2152_2019.0/toolchain.cmake \
-p /opt/pxc/axcf2152_2019.0

CMAKE_TOOLCHAIN_FILE=/opt/pxc/axcf2152_2019.3-beta+bundle1/toolchain.cmake \
SDKROOT=/opt/pxc/axcf2152_2019.3-beta+bundle1 \
tools/build_jsoncpp_axcf2152_2019.3-beta+bundle1.sh
```

If there is only one target for which you want to compile. You could also set the environment variables for the terminal in the vscode workspace settings file `.vscode/settings.json`.

```json
{
    "terminal.integrated.env.linux": {
        "CMAKE_TOOLCHAIN_FILE": "/opt/pxc/axcf2152_2019.0/toolchain.cmake",
        "SDKROOT": "/opt/pxc/axcf2152_2019.0"
    }
}
```

# Intellisense

Do not allow the CMake Tools Extension to provide intellisense information for the C/C++ Extension. With the current version CMake Tools 1.1.3 this does not work when cross compiling with sysroot option and hardware specific compiler flags. See issue [#637](https://github.com/vector-of-bool/vscode-cmake-tools/issues/637) on the CMake Tools GitHub project.

Create the `.vscode/c_cpp_properties.json` file to configure intellisense of the C/C++ Extension.

```json
{
    "configurations": [
        {
            "name": "axcf2152_2019.0",
            "compilerPath": "/opt/pxc/axcf2152_2019.0/sysroots/x86_64-pokysdk-linux/usr/bin/arm-pxc-linux-gnueabi/arm-pxc-linux-gnueabi-g++ --sysroot=/opt/pxc/axcf2152_2019.0/sysroots/cortexa9t2hf-neon-pxc-linux-gnueabi -march=armv7-a -mthumb -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9",
            "cStandard": "c11",
            "cppStandard": "c++11",
            "intelliSenseMode": "gcc-x64",
            "compileCommands": "${workspaceFolder}/build/axcf2152_2019.0/compile_commands.json",
            "browse": {
                "limitSymbolsToIncludedHeaders": true,
                "databaseFilename": "${workspaceFolder}/.vscode/axcf2152_2019.0.vc.db"
            }
        },
        {
            "name": "axcf2152_2019.3-beta+bundle1",
            "compilerPath": "/opt/pxc/axcf2152_2019.3-beta+bundle1/sysroots/x86_64-pokysdk-linux/usr/bin/arm-pxc-linux-gnueabi/arm-pxc-linux-gnueabi-g++ --sysroot=/opt/pxc/axcf2152_2019.3-beta+bundle1/sysroots/cortexa9t2hf-neon-pxc-linux-gnueabi -march=armv7-a -mthumb -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9",
            "cStandard": "c11",
            "cppStandard": "c++11",
            "intelliSenseMode": "gcc-x64",
            "compileCommands": "${workspaceFolder}/build/axcf2152_2019.3-beta+bundle1/compile_commands.json",
            "browse": {
                "limitSymbolsToIncludedHeaders": true,
                "databaseFilename": "${workspaceFolder}/.vscode/axcf2152_2019.3-beta+bundle1.vc.db"
            }
        }
    ],
    "version": 4
}
```

The `name` option of the configuration should follow the build kit names of the CMake Tools extension. See the `.vscode/cmake-kits.json` file for the build kit configuration.

The `compilerPath` option has to be specified because we are cross compiling with sysroot option and hardware specific compiler flags. The C/C++ Extension in version 0.22.0 is not able to browse these settings from the compilation database file given with the `compileCommands` option. See issues [#1575](https://github.com/Microsoft/vscode-cpptools/issues/1575) and [#1755](https://github.com/Microsoft/vscode-cpptools/issues/1755) in the GitHub repository of the C/C++ cpptools extension.

The `compilerPath` option has to be set to the compiler of the PLCnext SDK and all hardware specific options have to be given. The Extension will use this compiler and the given options to parse the system include paths and defines from the compiler. The compiler path and flags can be copied from the CMake toolchain file `toolchain.cmake` in the PLCnext SDK directory. See the CMake variables `CMAKE_SYSROOT`, `CMAKE_CXX_COMPILER` and `CMAKE_CXX_FLAGS` in the toolchain file.

The `compileCommands` option has to be set to the compilation database file that is generated from CMake. By setting the CMake variable `CMAKE_EXPORT_COMPILE_COMMANDS` in the CMake Tools build kit, CMake will generate this file in the build directory. The C/C++ extension uses this compilation database file to set the include paths and defines for each included translation unit.

The active IntelliSense configuration can now be switched by choosing the configuration in the lower right corner of the status bar in Visual Studio Code. Remember to select the IntelliSense configuration that matches your selected CMake build kit.

# PLCnext Engineer Library

Use the plcncli command line tool to generate the PLCnext Engineer library. This example does not use the default directory layout that the tool expects. Therefore the options for creating the library have to be specified explicitly.

```no-highlight
plcncli generate library -p libs/MyLibrary \
-m build/axcf2152_2019.0/libs/MyLibrary/intermediate/config \
-o /path/to/workspace-folder/build/axcf2152_2019.0/out/lib \
-t "AXCF2152,19.0.0.17548,build/axcf2152_2019.0/out/lib/libMyLibrary.so"
```

The option `-m` points to the directory where the library metadata files are generated. This is the `intermediate/config` directory in the build directory.

The option `-o` set the output directory. This has to be an absolute path.

The option `-t` specifies a target to include into the library. The Target name, version and path to the shared object have to be given. Note that the version uses the version string 19.0.0.17548 of the used SDK and not the version name e.g. 2019.0 LTS. The full version information can be read from the CMake variable `ARP_VERSION` in the CMake Cache file `CMakeCache.txt` located in the build directory. Also the version is available from the header file `/usr/include/plcnext/Arp/System/Core/ArpVersion.h` in the target sysroot of the SDK.

The plcncli command can also be stored as task in Visual Studio Code. Create the `.vscode/tasks.json` file.

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Engineer Library 2019.0 LTS",
            "type": "shell",
            "command": "plcncli",
            "args": [
                "generate",
                "library",
                "-p",
                "${workspaceFolder}/libs/MyLibrary",
                "-m",
                "${workspaceFolder}/build/axcf2152_2019.0/libs/MyLibrary/intermediate/config",
                "-o",
                "${workspaceFolder}/build/axcf2152_2019.0/out/lib",
                "-t",
                "AXCF2152,19.0.0.17548,${workspaceFolder}/build/axcf2152_2019.0/out/lib/libMyLibrary.so"
            ],
            "options": {
                "cwd": "${workspaceFolder}/libs/MyLibrary"
            },
            "problemMatcher": []
        },
        {
            "label": "Engineer Library 2019.3 beta bundle 1",
            "type": "shell",
            "command": "plcncli",
            "args": [
                "generate",
                "library",
                "-p",
                "${workspaceFolder}/libs/MyLibrary",
                "-m",
                "${workspaceFolder}/build/axcf2152_2019.3-beta+bundle1/libs/MyLibrary/intermediate/config",
                "-o",
                "${workspaceFolder}/build/axcf2152_2019.3-beta+bundle1/out/lib",
                "-t",
                "AXCF2152,19.3.0.18161,${workspaceFolder}/build/axcf2152_2019.3-beta+bundle1/out/lib/libMyLibrary.so"
            ],
            "options": {
                "cwd": "${workspaceFolder}/libs/MyLibrary"
            },
            "problemMatcher": []
        }
    ]
}
```

These tasks can now be called from the vscode command pallette with the entry `Task: Run task`.
