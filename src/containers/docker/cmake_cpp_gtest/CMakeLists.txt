cmake_minimum_required(VERSION 3.09)

# Locate GTest
find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS})
message("${GTEST_INCLUDE_DIRS}")

add_subdirectory(libs)

# Link runTests with what we want to test and the GTest and pthread library
add_executable(runTests test/trandom.cpp)
target_link_libraries(runTests GTest::GTest GTest::gmock pthread random turtle)
