# Copyright (c) 2015 Christopher Higgins Barrett
#
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgement in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.


# CMake-style include guard.
if (CSaru_included)
	return()
endif()
set(CSaru_included true)

# Error without CSaruDir environment variable.
if (NOT DEFINED ENV{CSaruDir})
	message(SEND_ERROR "Missing \"CSaruDir\" environment variable!  Should be an absolute path to a directory containing 'bin', 'pkg', and 'src' directories.")
endif()

find_package(Git QUIET)

# Root all installation paths at the CSaruEnviron root.
# (Not available on Windows.)
#set(DESTDIR "$ENV{CSaruDir}")

# Make install() calls go to the CSaruEnviron dir (they choose between bin and pkg).
set(CMAKE_INSTALL_PREFIX "$ENV{CSaruDir}")

# Make find_package() calls check the CSaruEnvrion package dir.
if (CMAKE_PREFIX_PATH)
	set(CMAKE_PREFIX_PATH "$ENV{CSaruDir}/pkg;${CMAKE_PREFIX_PATH}")
else()
	set(CMAKE_PREFIX_PATH "$ENV{CSaruDir}/pkg")
endif()


# ---------- CSaru_Lib macro ----------
#
# Use this when you're making a library and want:
#	- A <project>Config.cmake to be created for you (only when missing).
#	- A <project>ConfigVersion.cmake to be created for you each
#		"cmake .".
#	- CMAKE_INSTALL_PREFIX to be setup for you.
#
macro(CSaru_Lib)
	#CSaru_Init_Paths(${PROJECT_NAME}) # Is there any reason to do this?

	# If there isn't already a <project>Config.cmake, generate a basic one for libraries.
	if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}Config.cmake)
		configure_file($ENV{CSaruDir}/cmake/StaticLibraryConfig.cmake.in
			${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}Config.cmake
			@ONLY # Only replace @VAR@ from .in file, not ${VAR}.
			)
	endif()

	# Take advantage of a CMake module to write a
	#	<project>ConfigVersion.cmake file for us.  Having this file
	#	installed alongside our config package's <project>Config.cmake
	#	file allows other projects to require certain versions of ours.
	#	If the requirement isn't met, the other project will
	#	appropriately error and tell the builder what's wrong.
	include(CMakePackageConfigHelpers)
	write_basic_package_version_file(
		"${PROJECT_SOURCE_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
		VERSION ${PROJECT_VERSION}
		COMPATIBILITY AnyNewerVersion
		)

	# Set the target directory for other modules to find this one in.
	#	CMake's install() calls will root themselves to
	#	CMAKE_INSTALL_PREFIX.  Then append anything the user provides in
	#	their install() calls.
	set(CMAKE_INSTALL_PREFIX "$ENV{CSaruDir}/pkg/${PROJECT_NAME}")
endmacro()


# ---------- CSaru_Init_Paths macro ----------
#
# Maybe add project_version, target platform, etc. in the future (so versions don't stomp each other).
#
macro(CSaru_Init_Paths project_name)
	# Get LIBRARY_OUTPUT_DIRECTORY started in the CSaruEnviron.
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "$ENV{CSaruDir}/pkg/${project_name}/lib")
	# Get PDB_OUTPUT_DIRECTORY started in the CSaruEnviron.
	set(CMAKE_PDB_OUTPUT_DIRECTORY "$ENV{CSaruDir}/pkg/${project_name}/lib")
	# Until we add version/target platform/configuration information, just stomp PDBs with one-another.
	set(CMAKE_PDB_OUTPUT_DIRECTORY_DEBUG "$ENV{CSaruDir}/pkg/${project_name}/lib")
	set(CMAKE_PDB_OUTPUT_DIRECTORY_RELEASE "$ENV{CSaruDir}/pkg/${project_name}/lib")
	# Put executables into the CSaruEnviron bin directory.
	#	On DLL platforms (Windows), also put shared libraries (.dll) here.
	#	On other platforms, shared libraries (.so) go in the LIBRARY directory instead.
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "$ENV{CSaruDir}/bin")
	# Use a unified, intermediate build directory.
	#	Helps with add_subdirectory() and reusing intermediate files.
	#set(CSaru_build_dir "$ENV{CSaruDir}/build")
endmacro()


# ---------- CSaru_Depends macro ----------
#
macro(CSaru_Depends target_project_name)
	# Have CMake search its CMAKE_PREFIX_PATH for a
	#	<target_project_name>Config.cmake file.  That file should
	#	automatically include_directories() for us, and also provide a
	#	variable we can use with target_link_libraries().
	# Don't REQUIRE the file on this call, so we can try to get
	#	the package first if it's not found.
	find_package(${target_project_name} QUIET CONFIG)
	set(target_dir_var ${${target_project_name}_DIR})
	string(FIND ${target_dir_var} "-NOTFOUND" strtemp)
	if (NOT DEFINED ${target_project_name}_DIR OR ${strtemp} GREATER 0)
		# Check if we have src, and it just needs to be built to make pkg.
		if (EXISTS "$ENV{CSaruDir}/src/${target_project_name}")
			message(FATAL_ERROR "CSaru_Depends() couldn't find \"$ENV{CSaruDir}/pkg/${target_project_name}/${target_project_name}Config.cmake\" CMake project file, but you have the source for this project already.  Please compile/build/install/whatever \"$ENV{CSaruDir}/src/${target_project_name}\" and ensure it outputs at least the aforementioned <ProjectName>Config.cmake file.")
		endif()

		# Look for valid github.com repo-style CSaru_Depends
		string(REGEX REPLACE
			"^github.com/([_a-zA-Z0-9-]*)/([_a-zA-Z0-9-]*)$"
			"\\1;\\2"
			regex_matches
			${target_project_name}
			)
		list(LENGTH regex_matches regex_match_count)
		if (NOT regex_match_count EQUAL 2)
			message(FATAL_ERROR "CSaru_Depends() couldn't find project/package \"${target_project_name}\", and not a \"github.com/<user>/<repo>\"-formatted CSaru_Depends call.  Can't proceed.")
		endif()
		list(GET regex_matches 0 github_user_name)
		list(GET regex_matches 1 github_repo_name)
		#message(FATAL_ERROR "[${github_user_name}] [${github_repo_name}]")
		if (NOT GIT_FOUND)
			message(FATAL_ERROR "CSaru_Depends() couldn't find project/package \"${target_project_name}\", and your Git executable wasn't found.  Please install git first to support CSaru_Depends() auto-downloading.  In this case, \"https://github.com/${github_user_name}/${github_repo_name}.git\" would have been put in place for you.  git-scm.com and github.com are good places from which to get and learn git.")
		endif()

		# Do the git clone.
		execute_process(
			COMMAND ${GIT_EXECUTABLE} clone "https://github.com/${github_user_name}/${github_repo_name}.git" "$ENV{CSaruDir}/src/github.com/${github_user_name}/${github_repo_name}"
			RESULT_VARIABLE exec_result
			)
		if (NOT exec_result EQUAL 0)
			message(FATAL_ERROR "CSaru_Depends() ran \"git clone\" to get \"${target_project_name}\", and git returned an error.  See git's output above for information.  Stopped.")
		endif()

		# Now that we should have the package, REQUIRE it.
		find_package(${target_project_name} REQUIRED CONFIG)
	endif()
	#message(FATAL_ERROR "TODO : HERE")

	# Check to make sure our target told us about its libraries.
	target_link_libraries(${PROJECT_NAME} ${${target_project_name}_LIBRARIES})
	if (NOT DEFINED ${target_project_name}_LIBRARIES)
		message(FATAL_ERROR "${PROJECT_NAME} can't find ${target_project_name}'s libraries.\n"
			"${target_project_name} should have provided a list of its library files in a variable called ${target_project_name}_LIBRARIES."
			"  If it's a CSaruEnviron project, have it call CSaru_Lib() in its CMakeLists.txt file to have it generate files to take care of this for you."
			"  Don't forget to \"include(\$ENV{CSaruDir}/cmake/CSaru.cmake)\" in its CMakeLists.txt first.\n"
			)
	endif()
endmacro()


# ---------- CSaru_Depends2 macro ----------

# WIP, Not currently functional!  (May never be!)
macro(CSaru_Depends2 project_name)
	message(FATAL_ERROR "CSaru_Depends2() is not yet useful!  Use CSaru_Depends() instead!")
	CSaru_Init_Paths("${PROJECT_NAME}")
	#message(FATAL_ERROR "${PROJECT_NAME} -- ${project_name}")
	# add_subdirectory seemed nice and simple, but the target really must be an actual subdirectory.
	#add_subdirectory("$ENV{CSaruDir}/pkg/${project_name}" "${CSaru_build_dir}/${project_name}")
	# ExternalProject_Add also sounded very promising, including supplying git/svn/etc. downloading.
	#	Unfortunately, it's a monolithic solution that does a *ton* of work, making finer settings
	#	like output directories a pain to control.  And an ExternalProject_Add()-ed project can only
	#	do an out-of-source build (if I'm remembering correctly).  Trying not to enforce rules for
	#	how src projects build internally, as long as they output files in the right places (bin/pkg).
endmacro()

