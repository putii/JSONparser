cmake_minimum_required(VERSION 3.26)

project(CmakeConfigPackageTests
        LANGUAGES CXX)

# I DO NOT WANT BELOW, HERE IS WHY: https://stackoverflow.com/a/23995391/19280755
# set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g") # may not be needed
# message("Tests Debug flags: ${CMAKE_CXX_FLAGS_DEBUG}")
#################### GOOGLE TESTS ####################

add_executable(testsTarget tests.cpp)
enable_testing()
# Printing of set doublyLinkedList_warnings and doublyLinkedList_options INTERFACE libraries properties

get_target_property(WARNINGS doublyLinkedList_warnings INTERFACE_COMPILE_OPTIONS)
message(VERBOSE "testsTarget WARNINGS: ${WARNINGS}")

get_target_property(OPTIONS doublyLinkedList_options INTERFACE_COMPILE_OPTIONS)
message(VERBOSE "testsTarget OPTIONS: ${OPTIONS}")

target_link_libraries(testsTarget
    PRIVATE doublyLinkedList::doublyLinkedList_warnings
            doublyLinkedList::doublyLinkedList_options
            optimization_flags_interface_library # optimization flag -O<[0,1,2,3]>
            gtest_main
            DoublyLinkedSortedList)

add_test(NAME mainZeroArgs COMMAND main)
