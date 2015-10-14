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

# Make find_package() calls check the CSaruEnvrion package dir.
if (CMAKE_PREFIX_PATH)
	set(CMAKE_PREFIX_PATH "$ENV{CSaruDir}/pkg;${CMAKE_PREFIX_PATH}")
else()
	set(CMAKE_PREFIX_PATH "$ENV{CSaruDir}/pkg")
endif()


# ---------- CSaru_ProjectNamify_Path macro ----------
#
# Turn an absolute path (such as CMAKE_CURRENT_SOURCE_DIR) into a unique
#	project name.  Useful for disambiguating things like forked github
#	projects when searching for a <Project>Config.cmake file.
# Note that CSaru_Depends() expects to be given projects like
#	"github.com/akaito/csaru-core-cpp" so it can auto-git them.
#
macro(CSaru_ProjectNamify_Path absolute_project_src_path outvar)
	string(REGEX REPLACE "^.*/src/" "" temp "${absolute_project_src_path}")
	string(REPLACE " " "_" temp ${temp})
	string(REPLACE "/" "_" temp ${temp})
	set(${outvar} ${temp})
endmacro()


# ---------- CSaru_Lib macro ----------
#
# If you just want CSaru to handle everything, call this.
#	If you want more fine-grained control, but still want CSaru macros to
#	handle some things, copy-paste all the calls below and change them up
#	a little (or exclude some).
#
macro(CSaru_Lib version)
	CSaru_Lib_Project(${version})
	CSaru_Lib_Config()
	CSaru_Lib_InstallPrefix()
	CSaru_Lib_AddLibrary()
	CSaru_Lib_Install()
endmacro()


# ---------- CSaru_Lib_Project macro ----------
#
# Wraps project() call to give effortlessly consistent project naming.
#	While the names end up pretty long in some cases, it's nice for
#	disambiguating between forks of one repo in the same CSaruEnviron,
#	automatically git cloning the right repo when a dependency is missing, etc.
#
macro(CSaru_Lib_Project version)
	# Automatically use the path after 'src/' as the project name.
	#	Feel free to delete these next two lines and manually set this instead.
	#	Just note that CSaru_Depends() expects to be given packages like
	#	"github.com/akaito/csaru-core-cpp" so it can auto-git them.
	#get_filename_component(project_name ${CMAKE_CURRENT_SOURCE_DIR} NAME)
	set(project_name ${CMAKE_CURRENT_SOURCE_DIR})
	string(REPLACE " " "_" project_name ${project_name})
	string(REPLACE "/" "_" project_name ${project_name})
	CSaru_ProjectNamify_Path(${CMAKE_CURRENT_SOURCE_DIR} project_name)

	project(${project_name} VERSION ${version})
endmacro()


# ---------- CSaru_Lib_Config macro ----------
#
# Use this when you're making a library and want:
#	- A <project>Config.cmake to be created for you (only when missing).
#	- A <project>ConfigVersion.cmake to be created for you each
#		"cmake .".
#
macro(CSaru_Lib_Config)
	#CSaru_Init_Paths(${PROJECT_NAME}) # Is there any reason to do this?

	# If there isn't already a <project>Config.cmake, generate a basic one for libraries.
	if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}Config.cmake)
		configure_file($ENV{CSaruDir}/cmake/StaticLibraryConfig.cmake.in
			${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}Config.cmake
			@ONLY # Only replace instances of @VAR@ from .in file, not ${VAR}.
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
endmacro()


# ---------- CSaru_Lib_InstallPrefix macro ----------
#
# Set the target directory for other modules to find this one in.
#	CMake's install() calls will root themselves to CMAKE_INSTALL_PREFIX,
#	then append any paths provided in those install() calls.
#
macro(CSaru_Lib_InstallPrefix)
	# The more Go-like way to do this would be to add a "<platform>_<arch>"
	#	subdirectory under "pkg", but CMake seems to be pretty unaware of
	#	what's being built (especially when cross compiling), so we'll just
	#	ignore that until some day when a need for it arises.  Imagine the
	#	easy way to do that is to just have separate CSaruEnvirons for each
	#	platform/architecture combination.
	string(REPLACE "/src/" "/pkg/" CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}")
endmacro()


# ---------- CSaru_Lib_AddLibrary macro ----------
#
# Wrapper for add_library() that globs its files.
#	Nice for convenience, but you'll have to manually clean and
#	regenerate ("cmake .") CMake's output when you add or remove code files.
#	When globbing, CMake's cache can't tell if files have been added or
#	removed.
#
macro(CSaru_Lib_AddLibrary)
	# Create the static library.  Tell it *every* file involved!
	# CMake docs recommend against globbing (ie. src/*cpp) so changes are
	#	detectable.
	# If you're *realy* lazy and want to glob anyway,
	#	just prepare to clean and "cmake ." a lot.
	#	(Hint: I'm feeling really lazy and want to just let this code run
	#	everywhere without changing it.)
	# TODO : CHRIS : Use RELATIVE flag (and give abs path to .).
	file(GLOB_RECURSE src_files src/*.c* src/*.h*)
	file(GLOB_RECURSE header_files include/*.h*)
	# Deliberately not specifying STATIC or SHARED so BUILD_SHARED_LIBS can be
	#	used to specify one or the other.
	add_library(${PROJECT_NAME}
		${src_files}
		${header_files}
		)

	# Add include dir when compiling code; used by this Lists file and all its
	#	Targets.
	#include_directories(include)

	# Believe the below was something I used for a while to add the 'include'
	#	directory to the include path for all 'src' files automatically.
	#	Ended up liking the manual use of "../include/" more.
	#target_include_directories(LibA PUBLIC
		#$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> # Don't need this after-all.
		#$<INSTALL_INTERFACE:pkg/${PROJECT_NAME}/include>
		#)

	# Tell Visual Studio and other IDEs how to organize the files for the user.
	#	A fancier thing to do might be to iterate over each file we're adding,
	#	and add subgroups ("main\\sub", like that) so the organization in the
	#	IDE is _really_ nice.
	source_group(src FILES ${src_files} ${src_header_files})
	source_group(include FILES ${header_files})
endmacro()


# ---------- CSaru_Lib_Install macro ----------
#
# Handle install() calls to put include/ headers and CMake Config files into
#	the proper places for a CSaruEnviron src project.
#
macro(CSaru_Lib_Install)
	file(GLOB_RECURSE exported_header_files include/*.h*)
	install(FILES ${exported_header_files} DESTINATION include)
	install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}-targets
		DESTINATION static
		INCLUDES DESTINATION include
		)

	#install(EXPORT ${PROJECT_NAME}-targets DESTINATION .)

	# We may or may not have Config.cmake files in the repo, but CSaru_Lib() will
	#	make some for us if we don't.
	install(FILES
		"${PROJECT_NAME}Config.cmake"
		"${PROJECT_NAME}ConfigVersion.cmake"
		DESTINATION .
		)
endmacro()


# ---------- CSaru_Init_Paths macro ----------
#
#
macro(CSaru_Bin_Console version)
	# Automatically use the path after 'src/' as the project name.
	#	Feel free to delete these next two lines and manually set this instead.
	#	Just note that CSaru_Depends() expects to be given packages like
	#	"github.com/akaito/csaru-core-cpp" so it can auto-git them.
	#get_filename_component(project_name ${CMAKE_CURRENT_SOURCE_DIR} NAME)
	set(project_name ${CMAKE_CURRENT_SOURCE_DIR})
	string(REPLACE " " "_" project_name ${project_name})
	string(REPLACE "/" "_" project_name ${project_name})
	CSaru_ProjectNamify_Path(${CMAKE_CURRENT_SOURCE_DIR} project_name)

	project(${project_name} VERSION ${version})


	string(REPLACE "src" "bin" CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}")


	file(GLOB_RECURSE src_files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} src/*.c* src/*.h*)
	add_executable(${PROJECT_NAME}
		${src_files}
		)
endmacro()


# ---------- CSaru_Init_Paths macro ----------
#
# !!DEPRECATED!!
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
macro(CSaru_Depends target_project)
	# Have CMake search its CMAKE_PREFIX_PATH for a
	#	<target_project>Config.cmake file.  That file should
	#	automatically include_directories() for us, and also provide a
	#	variable we can use with target_link_libraries().
	# Don't REQUIRE the file on this call, so we can try to get
	#	the package first if it's not found.
	CSaru_ProjectNamify_Path(${target_project} unique_project_name)
	find_package("${target_project}" QUIET
		CONFIG
		NAMES ${unique_project_name}
		)

	# NOTE: May be able to be rid of the unique_project_name enirely.
	#		Avoid including all CMAKE_PREFIX_PATH stuff, and directly cat target_project onto it instead.
	#		Problem: Potential for ambiguous <Proj>Config.cmake files when things try to use them
	#		without doing it in the CSaru_Depends() way.

	# Rem: "${${target_project}_DIR}" has the "-NOTFOUND"-suffixed string after the above call finds nothing.
	# Rem: And dont' forget `cmake --build . --target install`.
	#message(FATAL_ERROR "_DIR -- [${${unique_project_name}_DIR}] -- ${unique_project_name} -- ${${target_project}_DIR} -- (${target_project})")

	# Strings ending in "-NOTFOUND" evaluate to false.
	#	So ${target_project}_DIR will resolve false if find_package() couldn't find it,
	#	since its value will then be "${target_project}-NOTFOUND".
	if (NOT ${target_project}_DIR)
		message(FATAL_ERROR "TODO : HERE -- ${${target_project}_DIR}")
		# Try including as a github repo-sourced project.
		CSaru_Depends_Github(target_project)

		# Now that we should have the package, REQUIRE it.
		find_package(${target_project_name} REQUIRED CONFIG)
	endif()

	# Check to make sure our target told us about its libraries.
	target_link_libraries(${PROJECT_NAME} ${${unique_project_name}_LIBRARIES})
	if (NOT DEFINED ${unique_project_name}_LIBRARIES)
		message(FATAL_ERROR "${PROJECT_NAME} can't find \"${target_project}\"'s libraries.\n"
			"\"${target_project}\" should have provided a list of its library files in a variable called ${unique_project_name}_LIBRARIES."
			"  If it's a CSaruEnviron project, have it call CSaru_Lib() in its CMakeLists.txt file to have it generate files to take care of this for you."
			"  Don't forget to \"include(\$ENV{CSaruDir}/cmake/CSaru.cmake)\" in its CMakeLists.txt first.\n"
			)
	endif()
endmacro()


# ---------- CSaru_Depends_Github macro ----------
#
# Check if the target project was given in the form "github.com/<user>/<repo>".
#	If so, try to "git clone" it automatically for the user if it's missing.
#
macro(CSaru_Depends_Github target_project)
		# Check if we have src, and it just needs to be built to make pkg.
		if (EXISTS "$ENV{CSaruDir}/src/${target_project_name}")
			CSaru_ProjectNamify_Path("${target_project_name}" local_project_name)
			message(FATAL_ERROR "CSaru_Depends() found \"src\" for the requested \"${target_project_name}\", but couldn't find a \"${local_project_name}Config.cmake\" CMake project file in \"$ENV{CSaruDir}/pkg/\".  Please \"cmake .\", build, and install \"$ENV{CSaruDir}/src/${target_project_name}\" and ensure it outputs at least the aforementioned <ProjectName>Config.cmake file.")
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
endmacro()


# ---------- CSaru_Depends2 macro ----------
#
# !!DEPRECATED!!
#
# WIP, Not currently functional!  (May never be!)
#
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

