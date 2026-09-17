cmake_minimum_required(VERSION 3.5)
project(CannKitCost)

set(NATIVE_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${NATIVE_ROOT})
include_directories(${HMOS_SDK_NATIVE}/sysroot/usr/lib)

find_library(CANN_LIBRARY hiai_foundation)

add_library(cannkit_cost SHARED
    CannKitNapi.cpp
    CannModelRunner.cpp)

target_link_libraries(cannkit_cost PUBLIC
    libace_napi.z.so
    libhilog_ndk.z.so
    librawfile.z.so
    ${CANN_LIBRARY}
    libneural_network_core.so)
