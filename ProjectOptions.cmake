include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)

#[[
 This file seems to provide 4 macros:
 - doublyLinkedList_supports_sanitizers
    - only called within _setup_options and _global_options
 - doublyLinkedList_setup_options
    - there goes all build options, especially compile flags, chosen sanitizers, fuzz testing etc.
 - doublyLinkedList_global_options
 - doublyLinkedList_local_options

]]
macro(doublyLinkedList_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
    message(STATUS "UBSAN TURNED ON")
  else()
    set(SUPPORTS_UBSAN OFF)
    message(STATUS "UBSAN TURNED OFF")
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
    message(STATUS "ASAN TURNED OFF")
  else()
    set(SUPPORTS_ASAN ON)
    message(STATUS "ASAN TURNED ON")
  endif()
endmacro()

macro(doublyLinkedList_setup_options)
  if(CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_MESSAGE_LOG_LEVEL DEBUG) # Make messages of type DEBUG visible for CMAKE_BUILD_TYPE="Debug"
    add_compile_definitions(DEBUG) # so that you can use #ifdef DEBUG <CODE> #endif for code to be added only in DEBUG builds
  endif()

  # rest of setup

  option(doublyLinkedList_ENABLE_HARDENING "Enable hardening" ON)
  option(doublyLinkedList_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
          doublyLinkedList_ENABLE_GLOBAL_HARDENING
          "Attempt to push hardening options to built dependencies"
          ON
          doublyLinkedList_ENABLE_HARDENING
          OFF)

  doublyLinkedList_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR doublyLinkedList_PACKAGING_MAINTAINER_MODE)
    option(doublyLinkedList_ENABLE_IPO "Enable IPO/LTO" OFF) # IPO - Inter Procedural Optimization, a nice feature
    option(doublyLinkedList_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(doublyLinkedList_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(doublyLinkedList_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(doublyLinkedList_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(doublyLinkedList_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(doublyLinkedList_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(doublyLinkedList_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(doublyLinkedList_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(doublyLinkedList_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(doublyLinkedList_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(doublyLinkedList_ENABLE_PCH "Enable precompiled headers" OFF)
    option(doublyLinkedList_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(doublyLinkedList_ENABLE_IPO "Enable IPO/LTO" ON) # IPO - Inter Procedural Optimization, a nice feature
    option(doublyLinkedList_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(doublyLinkedList_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(doublyLinkedList_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(doublyLinkedList_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(doublyLinkedList_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(doublyLinkedList_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(doublyLinkedList_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(doublyLinkedList_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(doublyLinkedList_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(doublyLinkedList_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(doublyLinkedList_ENABLE_PCH "Enable precompiled headers" OFF)
    option(doublyLinkedList_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
            doublyLinkedList_ENABLE_IPO # IPO - Inter Procedural Optimization, a nice feature
            doublyLinkedList_WARNINGS_AS_ERRORS
            doublyLinkedList_ENABLE_USER_LINKER
            doublyLinkedList_ENABLE_SANITIZER_ADDRESS
            doublyLinkedList_ENABLE_SANITIZER_LEAK
            doublyLinkedList_ENABLE_SANITIZER_UNDEFINED
            doublyLinkedList_ENABLE_SANITIZER_THREAD
            doublyLinkedList_ENABLE_SANITIZER_MEMORY
            doublyLinkedList_ENABLE_UNITY_BUILD
            doublyLinkedList_ENABLE_CLANG_TIDY
            doublyLinkedList_ENABLE_CPPCHECK
            doublyLinkedList_ENABLE_COVERAGE
            doublyLinkedList_ENABLE_PCH
            doublyLinkedList_ENABLE_CACHE)
  endif()

  doublyLinkedList_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (doublyLinkedList_ENABLE_SANITIZER_ADDRESS OR doublyLinkedList_ENABLE_SANITIZER_THREAD OR doublyLinkedList_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(doublyLinkedList_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

#[[
  This macro enables listed features based on set flags:
  - IPO
  - ASAN + UBSAN (_supports_sanitizers MACRO)
  - hardening (about UBSAN minimal runtime feature)
  It does only that. Nothing else.
  And it prints messages during cmake resolution/execution whatever.
]]
macro(doublyLinkedList_global_options)
  if(doublyLinkedList_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    doublyLinkedList_enable_ipo()
  endif()

  doublyLinkedList_supports_sanitizers()

  if(doublyLinkedList_ENABLE_HARDENING AND doublyLinkedList_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
            OR doublyLinkedList_ENABLE_SANITIZER_UNDEFINED
            OR doublyLinkedList_ENABLE_SANITIZER_ADDRESS
            OR doublyLinkedList_ENABLE_SANITIZER_THREAD
            OR doublyLinkedList_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else() # when no sanitizers enabled - enable UBSAN minimal runtime
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${doublyLinkedList_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${doublyLinkedList_ENABLE_SANITIZER_UNDEFINED}")
    doublyLinkedList_enable_hardening(doublyLinkedList_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()


#[[
  doublyLinkedList_local_options MACRO
  This one is an important SOAB, as it adds 2 cmake interface libraries:
  - doublyLinkedList_warnings
  - doublyLinkedList_options
  So
]]
macro(doublyLinkedList_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(doublyLinkedList_warnings INTERFACE)
  add_library(doublyLinkedList_options INTERFACE)

  ######### MY OWN INTERFACE LIBRARIES AKA "OPTIONS" AND ITS SETTING #########

  add_library(optimization_flags_interface_library INTERFACE)
  target_compile_options(optimization_flags_interface_library INTERFACE
    -O0 # HERE YOU SET OPTIMISATION FLAG ...
  )

  ############################################################################
  include(cmake/CompilerWarnings.cmake)
  doublyLinkedList_set_project_warnings(
          doublyLinkedList_warnings
          ${doublyLinkedList_WARNINGS_AS_ERRORS}
          ""
          ""
          ""
          "")

  # set(doublyLinkedList_ENABLE_USER_LINKER ON) # brute force # as far as I remember the problem was in using cache by cmake ...
  # so remember to delete cache if you change some settings in cmake files
  # message(AUTHOR_WARNING "WE ARE IN /ProjectOptions.cmake/macro(doublyLinkedList_local_options) before if(doublyLinkedList_ENABLE_USER_LINKER) statement; doublyLinkedList_ENABLE_USER_LINKER = ${doublyLinkedList_ENABLE_USER_LINKER}" ) # obsolete
  if(doublyLinkedList_ENABLE_USER_LINKER)
    # message(AUTHOR_WARNING "inside if(doublyLinkedList_ENABLE_USER_LINKER), so i assume doublyLinkedList_ENABLE_USER_LINKER = ON" ) # obsolete
    include(cmake/Linker.cmake)
    doublyLinkedList_configure_linker(doublyLinkedList_options)
  # else()
    # message(AUTHOR_WARNING "inside else() so i assume doublyLinkedList_ENABLE_USER_LINKER = OFF" )
  endif()

  include(cmake/Sanitizers.cmake)
  doublyLinkedList_enable_sanitizers(
          doublyLinkedList_options
          ${doublyLinkedList_ENABLE_SANITIZER_ADDRESS}
          ${doublyLinkedList_ENABLE_SANITIZER_LEAK}
          ${doublyLinkedList_ENABLE_SANITIZER_UNDEFINED}
          ${doublyLinkedList_ENABLE_SANITIZER_THREAD}
          ${doublyLinkedList_ENABLE_SANITIZER_MEMORY})

  set_target_properties(doublyLinkedList_options PROPERTIES UNITY_BUILD ${doublyLinkedList_ENABLE_UNITY_BUILD})

  if(doublyLinkedList_ENABLE_PCH)
    target_precompile_headers(
            doublyLinkedList_options
            INTERFACE
            <vector>
            <string>
            <utility>)
  endif()

  if(doublyLinkedList_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    doublyLinkedList_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(doublyLinkedList_ENABLE_CLANG_TIDY)
    doublyLinkedList_enable_clang_tidy(doublyLinkedList_options ${doublyLinkedList_WARNINGS_AS_ERRORS})
  endif()

  if(doublyLinkedList_ENABLE_CPPCHECK)
    doublyLinkedList_enable_cppcheck(${doublyLinkedList_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(doublyLinkedList_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    doublyLinkedList_enable_coverage(doublyLinkedList_options)
  endif()

  if(doublyLinkedList_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(doublyLinkedList_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(doublyLinkedList_ENABLE_HARDENING AND NOT doublyLinkedList_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
            OR doublyLinkedList_ENABLE_SANITIZER_UNDEFINED
            OR doublyLinkedList_ENABLE_SANITIZER_ADDRESS
            OR doublyLinkedList_ENABLE_SANITIZER_THREAD
            OR doublyLinkedList_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    doublyLinkedList_enable_hardening(doublyLinkedList_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

  # Printing of set doublyLinkedList_warnings and doublyLinkedList_options INTERFACE libraries properties

#  get_target_property(WARNINGS doublyLinkedList_warnings INTERFACE_COMPILE_OPTIONS)
#  message(VERBOSE "doublyLinkedList_warnings INTERFACE_COMPILE_OPTIONS: ${WARNINGS}")
#
#  get_target_property(OPTIONS doublyLinkedList_options INTERFACE_COMPILE_OPTIONS)
#  message(VERBOSE "doublyLinkedList_options INTERFACE_COMPILE_OPTIONS: ${OPTIONS}")

endmacro()
