cmake_minimum_required(VERSION 3.24)

set(FETCHCONTENT_OFFLINE_CACHE_DIR "${CMAKE_SOURCE_DIR}/.offline_cache" CACHE PATH "")
file(MAKE_DIRECTORY ${FETCHCONTENT_OFFLINE_CACHE_DIR})

function(offline_cache_provide_dependency method package_name)
    FetchContent_GetProperties(${package_name})

    if(NOT ${package_name}_POPULATED)
        # convert imporant arguments to hash
        set(options BYPASS_PROVIDER)
        set(one_value_args URL_HASH URL_MD5 GIT_REPOSITORY GIT_TAG GIT_SUBMODULES_RECURSE GIT_SHALLOW SOURCE_SUBDIR)
        set(multi_value_args URL GIT_SUBMODULES PATCH_COMMAND)
        cmake_parse_arguments(FETCHCONTENT_ARGS "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

        # prevent recursive fetch
        if(FETCHCONTENT_ARGS_BYPASS_PROVIDER)
            return()
        endif()

        foreach(item IN LISTS one_value_args multi_value_args)
            list(APPEND fetch_args_list "${item}:${FETCHCONTENT_ARGS_${item}}")
        endforeach()
        string(MD5 prop_hash  "${fetch_args_list}")
        
        # declare and make available
        cmake_path(APPEND_STRING FETCHCONTENT_OFFLINE_CACHE_DIR "/${package_name}-${prop_hash}.tar.gz" OUTPUT_VARIABLE cache_file)

        set(one_value_args SOURCE_DIR BINARY_DIR SOURCE_SUBDIR)
        cmake_parse_arguments(FETCHCONTENT_ARGS "" "${one_value_args}" "" ${ARGN})

        if(EXISTS ${cache_file})
            message(STATUS "[OFFLINE CACHE]: ${package_name}")
            FetchContent_Declare(${package_name}_cache
                BYPASS_PROVIDER
                URL ${cache_file}
                SOURCE_DIR ${FETCHCONTENT_ARGS_SOURCE_DIR}
                BINARY_DIR ${FETCHCONTENT_ARGS_BINARY_DIR}
                SOURCE_SUBDIR ${FETCHCONTENT_ARGS_SOURCE_SUBDIR}
            )
        else()
            FetchContent_Declare(${package_name}_cache BYPASS_PROVIDER ${ARGN})
        endif()

        FetchContent_MakeAvailable(${package_name}_cache)
        FetchContent_SetPopulated(${package_name} SOURCE_DIR ${FETCHCONTENT_ARGS_SOURCE_DIR} BINARY_DIR ${FETCHCONTENT_ARGS_BINARY_DIR})

        # save cache file
        cmake_path(GET FETCHCONTENT_ARGS_SOURCE_DIR PARENT_PATH FETCHCONTENT_ARGS_SOURCE_DIR_PARENT)

        if(NOT EXISTS ${cache_file})
            execute_process(COMMAND ${CMAKE_COMMAND} -E tar cz ${cache_file} ${FETCHCONTENT_ARGS_SOURCE_DIR} WORKING_DIRECTORY ${FETCHCONTENT_ARGS_SOURCE_DIR_PARENT})
        endif()
    endif()
endfunction()

cmake_language(
    SET_DEPENDENCY_PROVIDER offline_cache_provide_dependency
    SUPPORTED_METHODS FETCHCONTENT_MAKEAVAILABLE_SERIAL
)