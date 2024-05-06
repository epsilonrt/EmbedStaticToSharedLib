
add_executable(test_filed)
target_sources(test_filed PRIVATE "test_filed.c")
target_link_libraries(test_filed PRIVATE filed)

install(TARGETS test_filed)
# Add the install directory to the rpath of the executable
set_target_properties(test_filed PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
