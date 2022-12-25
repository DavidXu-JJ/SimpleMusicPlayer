# Ref. https://github.com/Ubpa/UCMake/blob/master/cmake/UbpaBasic.cmake
# ----------------------------------------------------------------------------
#
# Dx_List_Print(STRS <string-list> [TITLE <title>] [PREFIX <prefix>])
# - print:
#          <title>
#          <prefix>item0
#          ...
#          <prefix>itemN
#
# ----------------------------------------------------------------------------
#
# Dx_GetDirName(<result-name>)
# - get current directory name
#
# ----------------------------------------------------------------------------
#
# Dx_Path_Back(<rst> <path> <times>
# - get the father dir and return to <rst>
#
# ----------------------------------------------------------------------------

message(STATUS "include Basic.cmake")

function(Dx_List_Print)
    # https://stackoverflow.com/questions/23327687/how-to-write-a-cmake-function-with-more-than-one-parameter-groups
    cmake_parse_arguments(
            ARG # prefix of output variables
            "" # list of names of the boolean arguments (only defined ones will be true)
            "TITLE;PREFIX" # list of names of mono-valued arguments
            "STRS" # list of names of multi-valued arguments (output variables are lists)
            ${ARGN} # arguments of the function to parse, here we take the all original ones
    )
    list(LENGTH ARG_STRS strsLength)
    if(NOT strsLength)
        return()
    endif()
    if(NOT ${ARG_TITLE} STREQUAL "")
        message(STATUS ${ARG_TITLE})
    endif()
    foreach(str ${ARG_STRS})
        message(STATUS "${ARG_PREFIX}${str}")
    endforeach()
endfunction()

function(Dx_GetDirName dirName)
    string(REGEX MATCH "([^/]*)$" TMP ${CMAKE_CURRENT_SOURCE_DIR})
    message(STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
    message(STATUS "Output Dir Name: ${TMP}")
    set(${dirName} ${TMP} PARENT_SCOPE)
endfunction()


function(Dx_Path_Back rst path times)
    math(EXPR stop "${times}-1")
    set(curPath ${path})
    foreach(index RANGE ${stop})
        string(REGEX MATCH "(.*)/" _ ${curPath})
        set(curPath ${CMAKE_MATCH_1})
    endforeach()
    set(${rst} ${curPath} PARENT_SCOPE)
endfunction()