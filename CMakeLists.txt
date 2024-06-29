cmake_minimum_required(VERSION 3.17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(PROJECT picopico)

include(pico_sdk_import.cmake)
project(${PROJECT} C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()

include(cmake/perf_counter.cmake) # GorgonMeducer/perf_counter
include(cmake/lvgl.cmake) # lvgl/lvgl
include(cmake/cmsis.cmake)
add_executable(${PROJECT} 
  src/main.c
  ${perf_counter_SOURCE_DIR}/perf_counter.c
)

# The target "MyFirmware" depends on LVGL
target_link_libraries(${PROJECT} PRIVATE pico_stdlib lvgl::lvgl)

pico_enable_stdio_usb(${PROJECT} 0)
pico_enable_stdio_uart(${PROJECT} 1)
