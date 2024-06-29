include(FetchContent)

set(LV_CONF_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}/src/lv_conf.h
    CACHE STRING "" FORCE)

FetchContent_Declare(lvgl
  GIT_REPOSITORY https://github.com/lvgl/lvgl.git
  GIT_TAG v9.1.0
)
FetchContent_MakeAvailable(lvgl)