cmake_minimum_required(VERSION 3.2)

set(src_files
	src/main.cpp
	)

set(header_files
	)

# CSaruDir must be set in your environment variables!  It should point to a
#	directory with src/bin/pkg directories (or at least src; others can be
#	created later).  Open CSaru.cmake in a text editor to see what it's doing.
#	CSaru_Lib() has been written with the intent of being broken out in this
#	file if you need finer control over your project.
include($ENV{CSaruDir}/cmake/CSaru.cmake)
# Pass the version of your project; it's not related to the CSaruEnviron.
CSaru_Bin_Console(1.5 "${src_files}" "${header_files}")

# Custom stuff hand-edited into this CMakeLists ...

set(CXX_STANDARD_REQUIRED true)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

CSaru_Depends("csaru-chip8")
CSaru_Depends("csaru-core-cpp")

# The SDL2-finding code below is from
# http://stackoverflow.com/questions/23850472/how-to-use-sdl2-and-sdl-image-with-cmake

include(FindPkgConfig)
pkg_search_module(SDL2 REQUIRED sdl2)

include_directories(${SDL2_INCLUDE_DIRS})
target_link_librariES(${PROJECT_NAME} ${SDL2_LIBRARIES})

