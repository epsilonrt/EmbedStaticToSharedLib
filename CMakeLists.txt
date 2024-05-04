
cmake_minimum_required(VERSION 3.22)
project(embedlib LANGUAGES C)

if (MSVC)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

add_library(files STATIC)
target_include_directories(files PRIVATE "${PROJECT_SOURCE_DIR}/include")
target_sources(files 
    PRIVATE 
        src/file1.c 
        src/file2.c 
    PUBLIC 
        include/files.h)


add_library(filed SHARED)
target_include_directories(filed PUBLIC "${PROJECT_SOURCE_DIR}/include")
target_sources(filed 
    PRIVATE 
        src/file3.c 
    PUBLIC
        include/filed.h)
if (CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE)
#    target_compile_definitions(files PRIVATE "WHOLE_ARCHIVE")
#    target_link_libraries(filed PRIVATE "$<LINK_LIBRARY:WHOLE_ARCHIVE,files>")
else()
    message(WARNING "CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE not supported")
endif()
    
add_executable(main)
target_sources(main PRIVATE "src/main.c")
target_link_libraries(main PRIVATE filed)

#install(TARGETS libfiled FILE_SET HEADERS)
