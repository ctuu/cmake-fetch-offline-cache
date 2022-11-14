set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES ${CMAKE_SOURCE_DIR}/cmake/offline_cache_provider.cmake)

cmake_minimum_required(VERSION 3.24)
project(hello)

include(FetchContent)

FetchContent_Declare(fmt URL https://github.com/fmtlib/fmt/archive/refs/tags/9.0.0.tar.gz)
FetchContent_MakeAvailable(fmt)