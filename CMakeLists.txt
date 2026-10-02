cmake_minimum_required(VERSION 3.15)
project(BounceClassic C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# Raylib is built from the source included in dependencies/raylib (no download needed).
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
add_subdirectory(dependencies/raylib)

# Put the finished game in ./bin (same place on every OS and build type).
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")
foreach(cfg DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
  set("CMAKE_RUNTIME_OUTPUT_DIRECTORY_${cfg}" "${CMAKE_SOURCE_DIR}/bin")
endforeach()

add_executable(BounceClassic finalGameShowdown.c)
target_link_libraries(BounceClassic PRIVATE raylib)

# Emscripten/Web build: preload all game assets into the virtual filesystem and
# use the custom browser shell with the first-click audio unlock screen.
if(EMSCRIPTEN)
  set_target_properties(BounceClassic PROPERTIES SUFFIX ".html")
  target_link_options(BounceClassic PRIVATE
    "--shell-file=${CMAKE_SOURCE_DIR}/web/shell.html"
    "--preload-file=${CMAKE_SOURCE_DIR}/assets@assets"
    "-sALLOW_MEMORY_GROWTH=1"
    "-sINITIAL_MEMORY=67108864"
    "-sSTACK_SIZE=8388608"
    "-sSTACK_OVERFLOW_CHECK=2"
    "-sASYNCIFY=1"
    "-sASYNCIFY_STACK_SIZE=1048576"
    "-sEXPORTED_RUNTIME_METHODS=HEAPF32"
    "-sNO_EXIT_RUNTIME=1"
  )

  # Cache-bust the generated Emscripten JavaScript loader so browsers cannot
  # reuse an older JS/WASM combination after a new Web build.
  add_custom_command(TARGET BounceClassic POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E env python3 -c
      "from pathlib import Path; p=Path('${CMAKE_SOURCE_DIR}/bin/BounceClassic.html'); s=p.read_text(); old='src=BounceClassic.js'; new='src=BounceClassic.js?v=20261002'; assert old in s, 'BounceClassic.js script tag not found'; p.write_text(s.replace(old,new,1))"
    VERBATIM
  )
endif()
if(NOT WIN32)
  target_link_libraries(BounceClassic PRIVATE m)
endif()
if(MSVC)
  target_compile_definitions(BounceClassic PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
# The game loads "assets/..." and "leaderboard.txt" relative to the project folder.
set_target_properties(BounceClassic PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
