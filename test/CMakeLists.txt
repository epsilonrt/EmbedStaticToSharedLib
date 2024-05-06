
# message (STATUS "Creating test_filed executable, linking to filed library in ${CMAKE_INSTALL_PREFIX}/bin") 
add_executable(test_filed)
target_sources(test_filed PRIVATE "test_filed.c")
#target_include_directories(test_filed PRIVATE "${CMAKE_INSTALL_PREFIX}/include")
#target_link_directories(test_filed PRIVATE "${CMAKE_INSTALL_PREFIX}/bin")
target_link_libraries(test_filed PRIVATE filed)

install(TARGETS test_filed)
# Add the install directory to the rpath of the executable
set_target_properties(test_filed PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
