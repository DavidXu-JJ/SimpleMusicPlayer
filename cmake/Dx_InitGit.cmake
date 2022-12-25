
message(STATUS "include Dx_InitGit.cmake")

macro(Dx_InitGit)
    message(STATUS "----------")
    find_package(Git REQUIRED)
    message(STATUS "GIT_FOUND: ${GIT_FOUND}")
    message(STATUS "GIT_EXECUTABLE: ${GIT_EXECUTABLE}")
    message(STATUS "GIT_VERSION_STRING: ${GIT_VERSION_STRING}")
endmacro()

function(Dx_UpdateSubModule)
    if(NOT GIT_FOUND)
        message(FATAL_ERROR "you should call Dx_InitGit() before Dx_UpdateSubModule()")
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )
endfunction()