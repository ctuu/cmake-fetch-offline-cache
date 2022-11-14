# cmake-fetch-offline-cache

a non intrusive way to cache your FetchContent response.

using CMake 3.24 [Dependency Providers](https://cmake.org/cmake/help/latest/command/cmake_language.html#dependency-providers) feature.

## Usage

``` cmake
set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES ${CMAKE_SOURCE_DIR}/cmake/offline_cache_provider.cmake)

project(<your_project_name>)
```

