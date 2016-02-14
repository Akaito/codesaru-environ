cmake_minimum_required(VERSION 3.2)

# Could file(GLOB_RECURSE ...) for these, but specifying each one
#	manually means the build system knows when something changes.
set(src_files
	src/foo.cpp
	src/bar.cpp
)
set(header_files
	include/LIBNAME.h
)

# CSaruDir must be set in your environment variables!  It should point to a
#	directory with src/bin/pkg directories (or at least src; others can be
#	created later).  Open CSaru.cmake in a text editor to see what it's doing.
#	CSaru_Lib() has been written with the intent of being broken out in this
#	file if you need finer control over your project.
include($ENV{CSaruDir}/cmake/CSaru.cmake)

# Pass the version of your project; it's not related to the CSaruEnviron.
CSaru_Lib(0.1 "${src_files}" "${header_files}")

# Custom stuff hand-edited into this CMakeLists ...

set(CXX_STANDARD_REQUIRED true)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

