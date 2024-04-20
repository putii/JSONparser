cmake_minimum_required(VERSION 3.26)

project(
  JSONparser # used to be doublyLinkedList
  VERSION 1.0
  DESCRIPTION ""
  HOMEPAGE_URL ""
  LANGUAGES CXX) # This enables the CXX (C++) language and triggers compiler detection

# Tools used for debuging purposes
message("C++ compiler ID: ${CMAKE_CXX_COMPILER_ID}") # added to show what compiler is chosen
# cannot print linker here as it is set through:
# ProjectOptions.cmake/doublyLinkedList_local_options MACRO call below in this CMakeLists.txt file
# mentioned macro calls cmake/Linker.cmake/doublyLinkedList_configure_linker MACRO
# which sets linker (if user linker enabled) and stores this linker data in doublyLinkedList_options INTERFACE library

if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  message(AUTHOR_WARNING
          "You are using Clang.
Be aware that the llvm-18 release binary packages for Ubuntu Jammy (22.04) published on the LLVM Debian/Ubuntu nightly packages don't seem to include the LLVMgold.so plugin required for LTO support. You may want to use clang from other source.
issue:
https://github.com/llvm/llvm-project/issues/87553")
  #[[
    https://github.com/llvm/llvm-project/issues/87553
    https://github.com/llvm/llvm-project
    https://apt.llvm.org/
    about lacking gold plugin: https://llvm.org/docs/GoldPlugin.html
    about LTO on ubuntu: https://wiki.ubuntu.com/ToolChain/LTO
    thinLTO: https://clang.llvm.org/docs/ThinLTO.html
    LLVM on LTO: https://llvm.org/docs/LinkTimeOptimization.html
  ]]
endif()



# Google Test fetch
include(FetchContent)
FetchContent_Declare(googletest # Specify the commit you depend on and update it regularly.
                     URL https://github.com/google/googletest/archive/refs/heads/main.zip)

# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt
        ON
        CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Only set the cxx_standard if it is not set by someone else
if(NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 23)
endif()

# I want this, people use it even tho it is absent in Json Turner CMake Template
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# strongly encouraged to enable this globally to avoid conflicts between
# -Wpedantic being enabled and -std=c++20 and -std=gnu++20 for example
# when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS OFF)

# IDK what is it for
include(cmake/PreventInSourceBuilds.cmake)

# Project options - can be edited to fulfill project needs
include(ProjectOptions.cmake)

# there go all build options, especially compile flags, chosen sanitizers, fuzz testing etc.
doublyLinkedList_setup_options() # defined in ./ProjectOptions.cmake


# This macro call enables listed features based on set flags:
#  - IPO
#  - ASAN + UBSAN (_supports_sanitizers MACRO)
#  - hardening (about UBSAN minimal runtime feature)
doublyLinkedList_global_options() # defined in ./ProjectOptions.cmake



include(Dependencies.cmake)

# Manages dependencies i.e. extra libraries (download them if not present)
# these are: fmtlib, spdlog, catch2, cli11, screen, tools
doublyLinkedList_setup_dependencies() # defined in ./Dependencies.cmake, included above

# creates and sets according to chosen configs 2 cmake interface libraries:
# doublyLinkedList_warnings and doublyLinkedList_options
# they can be then used as set of properties/flags to link in target_link_libraries()
doublyLinkedList_local_options() # defined in ./ProjectOptions.cmake

# Printing of set doublyLinkedList_warnings and doublyLinkedList_options INTERFACE libraries properties

get_target_property(WARNINGS doublyLinkedList_warnings INTERFACE_COMPILE_OPTIONS)
message(AUTHOR_WARNING "doublyLinkedList_warnings INTERFACE_COMPILE_OPTIONS: ${WARNINGS}")

get_target_property(OPTIONS doublyLinkedList_options INTERFACE_COMPILE_OPTIONS)
message(AUTHOR_WARNING "doublyLinkedList_options INTERFACE_COMPILE_OPTIONS: ${OPTIONS}")

get_target_property(OPTIMIZATION_FLAG optimization_flags_interface_library INTERFACE_COMPILE_OPTIONS)
message(AUTHOR_WARNING "optimization_flags_interface_library INTERFACE_COMPILE_OPTIONS: ${OPTIMIZATION_FLAG}")


# don't know if this should be set globally from here or not...
# IFD What the fck it is
set(CMAKE_CXX_VISIBILITY_PRESET hidden)


#################################################

# IDK why is it here ... kinda messy
target_compile_features(doublyLinkedList_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})


# Extra aliases, idk what for; maybe b/c you cannot add properties to library alias (u need to use original library name)
add_library(doublyLinkedList::doublyLinkedList_options ALIAS doublyLinkedList_options)
add_library(doublyLinkedList::doublyLinkedList_warnings ALIAS doublyLinkedList_warnings)

#add_library(doublyLinkedList::doublyLinkedList_options INTERFACE IMPORTED)
#add_library(doublyLinkedList::doublyLinkedList_warnings INTERFACE IMPORTED)

# configure files based on CMake configuration options
add_subdirectory(configured_files)

############################### SOME BUILDING OPTIONS #########################################

# Adding the src:
add_subdirectory(src)

# Don't even look at tests if we're not top level
if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()

# Adding the tests, setting BUILD_TESTING=true:
include(CTest)

if(BUILD_TESTING)
  message(AUTHOR_WARNING "Building Tests.")
  add_subdirectory(test)
endif()


if(doublyLinkedList_BUILD_FUZZ_TESTS)
  message(AUTHOR_WARNING "Building Fuzz Tests, using fuzzing sanitizer https://www.llvm.org/docs/LibFuzzer.html")
  if (NOT doublyLinkedList_ENABLE_SANITIZER_ADDRESS AND NOT doublyLinkedList_ENABLE_SANITIZER_THREAD) # THERE WAS A TYPO
    message(WARNING "You need asan or tsan enabled for meaningful fuzz testing")
  endif()
  add_subdirectory(fuzz_test)
endif()

############################# SOME MSVC BS #############################

# If MSVC is being used, and ASAN is enabled, we need to set the debugger environment
# so that it behaves well with MSVC's debugger, and we can run the target from visual studio
if(MSVC)
  get_all_installable_targets(all_targets)
  message("all_targets=${all_targets}")
  set_target_properties(${all_targets} PROPERTIES VS_DEBUGGER_ENVIRONMENT "PATH=$(VC_ExecutablePath_x64);%PATH%")
endif()

# set the startup project for the "play" button in MSVC
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT intro)


################# BUILDING PACKAGE OR STH ################################

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

include(cmake/PackageProject.cmake)

# Add other targets that you want installed here, by default we just package the one executable
# we know we want to ship
doublyLinkedList_package_project(
        TARGETS # this is type of multivalue arg, it says that the next 3 args are values of this multi-val TARGET arg, i.e. they are target to be build, i.e. "please build me this intro target(main.cpp) with flags described in doublyLinkedList_warnings and doublyLinkedList_options library interfaces"
        main # target created by "add_executable(main main.cpp)" command in src/CMakeLists.txt
        doublyLinkedList_options # cmake interface library, i.e. options flags
        doublyLinkedList_warnings # cmake interface library, i.e. warnings flags
)

# Experience shows that explicit package naming can help make it easier to sort
# out potential ABI related issues before they start, while helping you
# track a build to a specific GIT SHA
set(CPACK_PACKAGE_FILE_NAME
        "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${GIT_SHORT_SHA}-${CMAKE_SYSTEM_NAME}-${CMAKE_BUILD_TYPE}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}"
)

include(CPack)


