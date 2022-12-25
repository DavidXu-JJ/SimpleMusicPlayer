# Ref. https://github.com/Ubpa/UCMake/blob/9646a826977d2bb1b962165007cabfa79abb1b55/cmake/UbpaTool.cmake

# [ Interface ]
#
# ----------------------------------------------------------------------------
#
# Dx_AddSubDirsRec(<path>)
# - add all subdirectories recursively in <path>
#
# ----------------------------------------------------------------------------
#
# Dx_GroupSrcs(PATH <path> SOURCES <sources-list>
# - create filters (relative to <path>) for sources
#
# ----------------------------------------------------------------------------
#
# Dx_GlobGroupSrcs(RST <rst> PATHS <paths-list>)
# - recursively glob all sources in <paths-list>
#   and call Dx_GroupSrcs(PATH <path> SOURCES <rst>) for each path in <paths-list>
# - regex : .+\.(h|hpp|inl|in|c|cc|cpp|cxx)
#
# ----------------------------------------------------------------------------
#
# Dx_GetTargetName(<rst> <targetPath>)
# - get target name at <targetPath>
#
# ----------------------------------------------------------------------------
#
# Dx_AddTarget_GDR(MODE <mode> [QT <qt>] [SOURCES <sources-list>]
#     [LIBS_GENERAL <libsG-list>] [LIBS_DEBUG <libsD-list>] [LIBS_RELEASE <libsR-list>])
# - mode         : EXE / LIB / DLL
# - libsG-list   : auto add DEBUG_POSTFIX for debug mode
# - sources-list : if sources is empty, call Dx_GlobGroupSrcs for currunt path
# - auto set target name, folder, target prefix and some properties
#
# ----------------------------------------------------------------------------
#
# Dx_AddTarget(MODE <mode> [QT <qt>] [SOURCES <sources-list>] [LIBS <libs-list>])
# - call Dx_AddTarget(MODE <mode> SOURCES <sources-list> LIBS_GENERAL <libs-list>)
#
# ----------------------------------------------------------------------------


message(STATUS "include Build.cmake")

# add dirs with CMakeLists.txt into subdirectory
function(Dx_AddSubDirsRec path)
    message(STATUS "----------")
    file(GLOB_RECURSE children
        LIST_DIRECTORIES true
        ${CMAKE_CURRENT_SOURCE_DIR}/${path}/*
    )
    set(dirs "")
    list(APPEND children "${CMAKE_CURRENT_SOURCE_DIR}/${path}")
    # add dirs with CMakeLists.txt
    foreach(item ${children})
        if(IS_DIRECTORY ${item} AND EXISTS "${item}/CMakeLists.txt")
            list(APPEND dirs ${item})
        endif()
    endforeach ()
    Dx_List_Print(TITLE "directories:" PREFIX "- " STRS ${dirs})
    foreach(dir ${dirs})
        add_subdirectory(${dir})
    endforeach()
endfunction()

function(Dx_GetTargetName rst targetPath)
    # file(RELATIVE_PATH <variable> <directory> <file>)
    # Compute the relative path from a <directory> to a <file> and store it in the <variable>.
    file(RELATIVE_PATH targetRelPath
        "${PROJECT_SOURCE_DIR}/src"
        "${targetPath}"
    )
    # string(REPLACE <match_string>
    #       <replace_string> <output variable>
    #       <input> [<input>...])
    # Replace all occurrences of match_string in the input with replace_string and store the result in the output.
    string(REPLACE "/"
            "_" targetName
            "${PROJECT_NAME}_${targetRelPath}"
    )
    set(${rst} ${targetName} PARENT_SCOPE)
endfunction()

function(_ExpandSources rst _sources)
    set(tmp_rst "")
    foreach(item ${${_sources}})
        if(IS_DIRECTORY ${item})
            file(GLOB_RECURSE itemSrcs
                    # cmake
                    ${item}/*.cmake

                    # msvc
                    ${item}/*.natvis

                    # INTERFACEer files
                    ${item}/*.h
                    ${item}/*.hpp
                    ${item}/*.hxx
                    ${item}/*.inl

                    # source files
                    ${item}/*.c

                    ${item}/*.cc
                    ${item}/*.cpp
                    ${item}/*.cxx

                    # shader files
                    ${item}/*.vert # glsl vertex shader
                    ${item}/*.tesc # glsl tessellation control shader
                    ${item}/*.tese # glsl tessellation evaluation shader
                    ${item}/*.geom # glsl geometry shader
                    ${item}/*.frag # glsl fragment shader
                    ${item}/*.comp # glsl compute shader

                    #${item}/*.hlsl
                    #${item}/*.hlsli
                    #${item}/*.fx
                    #${item}/*.fxh

                    # Qt files
                    ${item}/*.qrc
                    ${item}/*.ui
            )
            list(APPEND tmp_rst ${itemSrcs})
        # not a dir, but a file
        else()
            if(NOT IS_ABSOLUTE "${item}")
                get_filename_component(item "${item}" ABSOLUTE)
            endif()
            list(APPEND tmp_rst ${item})
        endif()
    endforeach()
    set(${rst} ${tmp_rst} PARENT_SCOPE)
endfunction()

function(Dx_GroupSrcs)
    cmake_parse_arguments("ARG" "" "PATH" "SOURCES" ${ARGN})

    set(headerFiles ${ARG_SOURCES})
    list(FILTER headerFiles INCLUDE REGEX ".+\.(h|hpp|inl|in)$")

    set(sourceFiles ${ARG_SOURCES})
    list(FILTER sourceFiles INCLUDE REGEX ".+\.(c|cc|cpp|cxx)$")

    set(qtFiles ${ARG_SOURCES})
    list(FILTER qtFiles INCLUDE REGEX ".+\.(qrc|ui)$")

    foreach(header ${headerFiles})
        get_filename_component(headerPath "${header}" PATH)
        file(RELATIVE_PATH headerPathRel ${ARG_PATH} "${headerPath}")
        if(MSVC)
            string(REPLACE "/" "\\" headerPathRelMSVC "${headerPathRel}")
            set(headerPathRel "Header Files\\${headerPathRelMSVC}")
        endif()
        source_group("${headerPathRel}" FILES "${header}")
    endforeach()

    foreach(source ${sourceFiles})
        get_filename_component(sourcePath "${source}" PATH)
        file(RELATIVE_PATH sourcePathRel ${ARG_PATH} "${sourcePath}")
        if(MSVC)
            string(REPLACE "/" "\\" sourcePathRelMSVC "${sourcePathRel}")
            set(sourcePathRel "Source Files\\${sourcePathRelMSVC}")
        endif()
        source_group("${sourcePathRel}" FILES "${source}")
    endforeach()

    foreach(qtFile ${qtFiles})
        get_filename_component(qtFilePath "${qtFile}" PATH)
        file(RELATIVE_PATH qtFilePathRel ${ARG_PATH} "${qtFilePath}")
        if(MSVC)
            string(REPLACE "/" "\\" qtFilePathRelMSVC "${qtFilePathRel}")
            set(qtFilePathRel "Qt Files\\${qtFilePathRelMSVC}")
        endif()
        source_group("${qtFilePathRel}" FILES "${qtFile}")
    endforeach()
endfunction()

function(Dx_GlobGroupSrcs)
    cmake_parse_arguments("ARG"
            ""
            "RST"
            "PATHS"
            ${ARGN}
    )
    set(sources "")
    foreach(path ${ARG_PATHS})
        file(GLOB_RECURSE pathSources
                "${path}/*.h"
                "${path}/*.hpp"
                "${path}/*.inl"
                "${path}/*.in"
                "${path}/*.c"
                "${path}/*.cc"
                "${path}/*.cpp"
                "${path}/*.cxx"
                "${path}/*.qrc"
                "${path}/*.ui"
                )
        list(APPEND sources ${pathSources})
        Dx_GroupSrcs(PATH ${path} SOURCES ${pathSources})
    endforeach()
    set(${ARG_RST} ${sources} PARENT_SCOPE)
endfunction()

function(Dx_AddTarget_GDR)
    cmake_parse_arguments("ARG"
            ""
            "MODE;QT"
            "SOURCES;LIBS_GENERAL;LIBS_DEBUG;LIBS_RELEASE;EXTERNAL"
            ${ARGN}
    )
    file(RELATIVE_PATH targetRelPath
            "${PROJECT_SOURCE_DIR}/src"
            "${CMAKE_CURRENT_SOURCE_DIR}/.."
    )
    set(folderPath "${PROJECT_NAME}/${targetRelPath}")
    Dx_GetTargetName(targetName ${CMAKE_CURRENT_SOURCE_DIR})

    list(LENGTH ARG_SOURCES sourceNum)
    if(${sourceNum} EQUAL 0)
        # get from current source dir
        Dx_GlobGroupSrcs(RST ARG_SOURCES PATHS ${CMAKE_CURRENT_SOURCE_DIR})
        list(LENGTH ARG_SOURCES sourceNum)
        if(sourcesNum EQUAL 0)
            message(WARNING "Target [${targetName}] has no source")
            return()
        endif()
    endif()

    # may need to be configured
    Dx_GlobGroupSrcs(RST ARG_EXTERNAL_SOURCES PATHS ${PROJECT_SOURCE_DIR}/external/${ARG_EXTERNAL})

    message(STATUS "----------")
    message(STATUS "- name: ${targetName}")
    message(STATUS "- folder : ${folderPath}")
    message(STATUS "- mode: ${ARG_MODE}")
    Dx_List_Print(STRS ${ARG_SOURCES}
            TITLE  "- sources:"
            PREFIX "    "
    )
    Dx_List_Print(STRS ${ARG_EXTERNAL_SOURCES}
            TITLE  "- external sources:"
            PREFIX "    "
            )

    list(LENGTH ARG_LIBS_GENERAL generalLibNum)
    list(LENGTH ARG_LIBS_DEBUG debugLibNum)
    list(LENGTH ARG_LIBS_RELEASE releaseLibNum)
    if(${debugLibNum} EQUAL 0 AND ${releaseLibNum} EQUAL 0)
        if(NOT ${generalLibNum} EQUAL 0)
            Dx_List_Print(STRS ${ARG_LIBS_GENERAL}
                    TITLE  "- lib:"
                    PREFIX "    "
            )
        endif()
    else()
        message(STATUS "- libs:")
        Dx_List_Print(STRS ${ARG_LIBS_GENERAL}
                TITLE  "  - general:"
                PREFIX "      "
        )
        Dx_List_Print(STRS ${ARG_LIBS_DEBUG}
                TITLE  "  - debug:"
                PREFIX "      "
        )
        Dx_List_Print(STRS ${ARG_LIBS_RELEASE}
                TITLE  "  - release:"
                PREFIX "      "
        )
    endif()

    if(${ARG_QT})
        Dx_QtBegin()
    endif()

    if(${ARG_MODE} STREQUAL "EXE")
        add_executable(${targetName}
                ${ARG_SOURCES}
                # may need to be configured
                ${ARG_EXTERNAL_SOURCES})
#        if(MSVC)
#            set_target_properties(${targetName} PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/bin")
#        endif()
        set_target_properties(${targetName} PROPERTIES DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})
    elseif(${ARG_MODE} STREQUAL "LIB")
        add_library(${targetName} ${ARG_SOURCES})
    elseif(${ARG_MODE} STREQUAL "DLL")
        add_library(${targetName} SHARED ${ARG_SOURCES})
    else()
        message(FATAL_ERROR "mode [${ARG_MODE}] is not supported")
        return()
    endif()

    target_include_directories(${targetName} PRIVATE
            ${CMAKE_CURRENT_BINARY_DIR}
            # may need to be configured
            ${PROJECT_SOURCE_DIR}/external/${ARG_EXTERNAL}
    )

    # folder for VS
#    set_target_properties(${targetName} PROPERTIES FOLDER ${folderPath})

    foreach(lib ${ARG_LIBS_GENERAL})
        target_link_libraries(${targetName} general ${lib})
    endforeach()
    foreach(lib ${ARG_LIBS_DEBUG})
        target_link_libraries(${targetName} debug ${lib})
    endforeach()
    foreach(lib ${ARG_LIBS_RELEASE})
        target_link_libraries(${targetName} optimized ${lib})
    endforeach()
    install(TARGETS ${targetName}
            RUNTIME DESTINATION "bin"
            ARCHIVE DESTINATION "lib"
            LIBRARY DESTINATION "lib"
    )

    if(${ARG_QT})
        Dx_QtEnd()
    endif()
endfunction()

function(Dx_AddTarget)
    cmake_parse_arguments("ARG"
            ""
            "MODE;QT"
            "SOURCES;LIBS;EXTERNAL"
            ${ARGN}
    )
    Dx_AddTarget_GDR(MODE ${ARG_MODE}
            QT ${ARG_QT}
            SOURCES ${ARG_SOURCES}
            LIBS_GENERAL ${ARG_LIBS}
            EXTERNAL ${ARG_EXTERNAL}
    )
endfunction()