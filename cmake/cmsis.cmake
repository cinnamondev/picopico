include(FetchContent)

FetchContent_Declare(cmsis
  GIT_REPOSITORY https://github.com/ARM-software/CMSIS_6.git
  GIT_TAG v6.1.0
)
FetchContent_Populate(cmsis)
include_directories(${cmsis_SOURCE_DIR}/CMSIS/Core/Include)
#include_directories("CMSIS/Device/ST/STM32F1xx/Include)