################################ LIFETIME CLASS PLAYGROUND ################################

add_executable(lifetime lifetime.cpp)

################################ CharParser STATIC LIBRARY ################################
add_library(Parser Parser.cpp)

# Include the directory containing the header file
target_include_directories(Parser
        PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/Parser>
)

################################ CharParser STATIC LIBRARY ################################
add_library(CharParser CharParser.cpp)

# Include the directory containing the header file
target_include_directories(CharParser
        PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/CharParser>
)

################################ JsonValue STATIC LIBRARY ################################
add_library(JsonValue JsonValue.cpp)

# Include the directory containing the header file
target_include_directories(JsonValue
        PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/JsonValue>
)

################################ Functor STATIC LIBRARY ################################
add_library(Functor Functor.cpp)

# Include the directory containing the header file
target_include_directories(Functor
        PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/Functor>
)

################### MAIN BINARY ###################
# Create executable target for your main source file
add_executable(main main.cpp)

# Link the library to the executable
target_link_libraries(main
        #PRIVATE DoublyLinkedSortedList
        #        optimization_flags_interface_library
)


############################################################################################################
################### Node STATIC LIBRARY ###################
#[[
#[=[
  This one doesn't shout compilation warnings for you b/c
  you haven't target linked interface_libraries with warnings
  and options
]=]

add_library(Node Node.cpp)

# Include the directory containing the header file
target_include_directories(Node
        PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/Node>
)

target_link_libraries(Node PRIVATE optimization_flags_interface_library)
]]

################### DoublyLinkedSortedList STATIC LIBRARY ###################
#[[
#[=[
  This one doesn't shout compilation warnings for you b/c
  you haven't target linked interface_libraries with warnings
  and options
]=]

add_library(DoublyLinkedSortedList DoublyLinkedSortedList.cpp)

# Include the directory containing the header file
target_include_directories(DoublyLinkedSortedList
        PUBLIC  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/Node>
                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/DoublyLinkedSortedList>
) # once we do this PUBLIC dir include of .hpp files we can now
  # in test/CMakeLists.txt link "DoublyLinkedSortedList" library to testsTarget
  # and once we do it the #include <DoublyLinkedSortedList.hpp> directive will work just fine
  # compiler/preprocessor/builder/clangd/whatever IDK will see these included .hpp dirs as well
  # but if we did PRIVATE include above these includes wouldnt be visible for our test target
  # after linking DoublyLinkedSortedList

target_link_libraries(DoublyLinkedSortedList
        PRIVATE Node # we are linking Node static library to DLSList library
        PRIVATE optimization_flags_interface_library)
]]



