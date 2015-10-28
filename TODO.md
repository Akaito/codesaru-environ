Goals
=====

* Project file generation ("cmake .").
* Go-like easy use of dependencies.
  * "go get" automatically downloads any missing, imported modules.
    Header files are scanned to find what's needed.
  * Don't have to scan C++ headers for dependencies.  Would even be
    a bad idea.  Don't want to have to change a ton of code to change from one
	fork of a git repo to another.
  * Doesn't have to be perfectly Go-like.  Just good enough to make life easier
	and not so fancy and time-consuming to get stuck writing it instead of using it.
* Building a project puts its output in the Environ's pkg or bin.
* Minimal requirements on structure of src.  It should be easy to migrate
  existing code to fit in the CSaruEnv style.
  * No src is allowed to use another.
* Using a pkg doesn't require fork-/version-differentiating information to be in
  the source code.
* Header files not required to have globally unique names amongst pkg modules.


Stretch Goals
=============

* Support multiple architectures in one Environ (32-/64-bit libs).
* Support multiple versions/branches/tags of one pkg in one Environ.
  Look to \*nix libs for approach (linking to latest version).


CSaruEnv General
================

1. Better error messages for when CSaruEnv environment variable isn't set.
   Currently just errors on "/cmake/CSaru.cmake" not being found by the include().


Target Structure
================

Env
	bin
	pkg
		csaru-core-cpp   ==> csaru-core-cpp.2.1
		csaru-core-cpp.2 ==> csaru-core-cpp.2.1
		csaru-core-cpp.2.1
			cmake
				csaru-core-cppConfig.cmake
				csaru-core-cppConfigVersion.cmake
			dynamic
			static
				csaru-core-cpp.lib
			*.h
	src

