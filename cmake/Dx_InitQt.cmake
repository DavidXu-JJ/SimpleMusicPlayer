
message(STATUS "include Dx_InitQt.cmake")

macro(Dx_InitQt)
    message(STATUS "----------")
    cmake_parse_arguments(
            ARG
            ""
            ""
            "COMPONENTS"
            ${ARGN}
    )
    Dx_List_Print(TITLE "Qt Components" PREFIX "  - " STRS ${ARG_COMPONENTS})

    # https://cmake.org/cmake/help/latest/command/find_package.html?highlight=find_packa#command:find_package
    # A package-specific list of required components may be listed after the COMPONENTS keyword.
    # If any of these components are not able to be satisfied, the package overall is considered to be not found.
    # If the REQUIRED option is also present, this is treated as a fatal error, otherwise execution still continues.
    # As a form of shorthand, if the REQUIRED option is present, the COMPONENTS keyword can be omitted and the required components can be listed directly after REQUIRED.
    find_package(Qt6 COMPONENTS REQUIRED ${ARG_COMPONENTS})

    set(CMAKE_INCLUDE_CURRENT_DIR  ON)
#    if(WIN32)
#        Dx_Path_Back(_QtRoot ${Qt6_DIR} 3)
#        foreach(_cmpt ${ARG_COMPONENTS})
#            set(_dllPathR "${_QtRoot}/bin/Qt6${_cmpt}.dll")
#            set(_dllPathD "${_QtRoot}/bin/Qt6${_cmpt}d.dll")
#            if(EXISTS ${_dllPathD} AND EXISTS ${_dllPathR})
#                install(FILES ${_dllPathD} TYPE BIN CONFIGURATIONS Debug)
#                install(FILES ${_dllPathR} TYPE BIN CONFIGURATIONS Release)
#            else()
#                message(WARNING "file not exist: ${_dllPath}(d).dll")
#            endif()
#        endforeach()
#    endif()
    message(STATUS "----------")
endmacro()

function(Dx_QtBegin)
    set(CMAKE_AUTOMOC ON PARENT_SCOPE)
    set(CMAKE_AUTOUIC ON PARENT_SCOPE)
    set(CMAKE_AUTORCC ON PARENT_SCOPE)
endfunction()

function(Dx_QtEnd)
    set(CMAKE_AUTOMOC OFF PARENT_SCOPE)
    set(CMAKE_AUTOUIC OFF PARENT_SCOPE)
    set(CMAKE_AUTORCC OFF PARENT_SCOPE)
endfunction()