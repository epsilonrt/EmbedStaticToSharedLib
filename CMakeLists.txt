
cmake_minimum_required(VERSION 3.13)
project(embedlib LANGUAGES C)

set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")

if (MSVC)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

# Create a static library with the files library
add_library(files STATIC)
target_include_directories(files PRIVATE "${PROJECT_SOURCE_DIR}/include")
target_sources(files 
    PRIVATE 
        src/file1.c 
        src/file2.c 
    PUBLIC 
        include/files.h)

# Now create a shared library that embeds the files library
add_library(filed SHARED)
target_include_directories(filed PUBLIC "${PROJECT_SOURCE_DIR}/include")
target_sources(filed 
    PRIVATE 
        src/file3.c 
    PUBLIC
        include/filed.h)
set_target_properties(filed PROPERTIES PUBLIC_HEADER "include/filed.h;include/files.h")
add_dependencies(filed files)

# This is a simple example of how to embed a library in another library
# Since CMake 3.24, the CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE feature is available
# see https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_LINK_LIBRARY_USING_FEATURE.html
if(CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
    target_link_options(filed PUBLIC "-force_load" "$<TARGET_FILE:files>")
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU" AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_link_options(filed PUBLIC "-Wl,--whole-archive" "$<TARGET_FILE:files>" "-Wl,--no-whole-archive")
elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    target_link_options(filed PUBLIC "/WHOLEARCHIVE:$<TARGET_FILE:files>")
else()
    # feature not yet supported for the other environments
    message(FATAL_ERROR "CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE not supported")
endif()

install(TARGETS filed PUBLIC_HEADER)

# Add an uninstall target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)
add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

add_subdirectory(test)