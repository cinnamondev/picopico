include(FetchContent)
FetchContent_Declare(perf_counter
  GIT_REPOSITORY https://github.com/GorgonMeducer/perf_counter.git
  GIT_TAG 68d33968ab1967040cae8cd913d1ab9be9dd8c26 # release (2.3.1)
)
FetchContent_Populate(perf_counter)

include_directories(${perf_counter_SOURCE_DIR})
