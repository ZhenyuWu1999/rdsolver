cmake_minimum_required(VERSION 3.17)
project(rd LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(RD_BUILD_2D "Build the two-dimensional solver" ON)
option(RD_BUILD_3D "Build the three-dimensional solver" ON)

# Homebrew installs these dependencies outside the system search paths.
if(APPLE)
    find_program(HOMEBREW_EXECUTABLE brew)
    if(HOMEBREW_EXECUTABLE)
        execute_process(COMMAND "${HOMEBREW_EXECUTABLE}" --prefix
            OUTPUT_VARIABLE HOMEBREW_PREFIX OUTPUT_STRIP_TRAILING_WHITESPACE)
        list(APPEND CMAKE_PREFIX_PATH
            "${HOMEBREW_PREFIX}/opt/openblas" "${HOMEBREW_PREFIX}/opt/libomp")
    endif()
    find_path(RD_OMP_INCLUDE_DIR omp.h
        HINTS "${HOMEBREW_PREFIX}/opt/libomp/include")
    find_library(RD_OMP_LIBRARY omp
        HINTS "${HOMEBREW_PREFIX}/opt/libomp/lib")
    if(RD_OMP_INCLUDE_DIR AND RD_OMP_LIBRARY)
        set(OpenMP_CXX_FLAGS "-Xpreprocessor -fopenmp")
        set(OpenMP_CXX_LIB_NAMES "omp")
        set(OpenMP_omp_LIBRARY "${RD_OMP_LIBRARY}")
        set(OpenMP_CXX_INCLUDE_DIR "${RD_OMP_INCLUDE_DIR}")
    endif()
endif()

find_package(OpenBLAS REQUIRED CONFIG)
find_package(OpenMP REQUIRED COMPONENTS CXX)

# Keep editable constants.h files supported; otherwise use the tracked templates.
function(rd_configure_constants filename)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${filename}")
        set(config_source "${CMAKE_CURRENT_SOURCE_DIR}/${filename}")
    else()
        set(config_source "${CMAKE_CURRENT_SOURCE_DIR}/${filename}.TEMPLATE")
    endif()
    configure_file("${config_source}" "${CMAKE_CURRENT_BINARY_DIR}/${filename}" COPYONLY)
endfunction()

function(rd_link_dependencies target)
    target_include_directories(${target} PRIVATE
        "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}"
        ${OpenBLAS_INCLUDE_DIRS})
    target_link_libraries(${target} PRIVATE ${OpenBLAS_LIBRARIES} OpenMP::OpenMP_CXX)
endfunction()

if(RD_BUILD_2D)
    rd_configure_constants(constants.h)
    add_executable(rd2D main.cpp base.cpp inverse.cpp io2D.cpp
        setup2D.cpp source2D.cpp timestep.cpp)
    rd_link_dependencies(rd2D)
endif()

if(RD_BUILD_3D)
    rd_configure_constants(constants3D.h)
    add_executable(rd3D main3D.cpp base.cpp inverse.cpp io3D.cpp
        setup3D.cpp source3D.cpp timestep.cpp)
    target_compile_definitions(rd3D PRIVATE RD_BUILD_3D)
    rd_link_dependencies(rd3D)
endif()
