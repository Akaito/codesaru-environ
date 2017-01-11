codesaru-environ
================

Go-esque environment for C++ and whatever other projects.

Easy-to-use consistent structure for working on projects.  Templates and some scripts make it easy to create new projects (libs, console projects, etc.).  Making new templates is also easy.

Super-minimal/-simple "module" downloaders inspired by Go's easy module import/download.  These list available codesaru-environ-compatible modules and allow the user to git-clone them right from the script and quickly fill out a new environ sandbox.

Still have work to do on dependency management between projects...


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


CSaruEnv TODO General
=====================

1. Fix fixlinks.sh
    With links chip8 -> chip8.0 -> chip8.0.1 and directories chip8.0.1 and chip8.0.3,
	chip8.0 isn't getting updated to point at chip8.0.3; instead being left at chip8.0.1
2. Better error messages for when CSaruEnv environment variable isn't set.
    Currently just errors on "/cmake/CSaru.cmake" not being found by the include().


Target Structure
================

    CSaruDir
        bin
            csaru-core-cpp-test   ==> csaru-core-cpp-test.3
            csaru-core-cpp-test.2 ==> csaru-core-cpp-test.2.1
            csaru-core-cpp-test.2.0
            csaru-core-cpp-test.2.1
            csaru-core-cpp-test.3 ==> csaru-core-cpp-test.3.0
            csaru-core-cpp-test.3.0
        pkg
            csaru-core-cpp   ==> csaru-core-cpp.2
            csaru-core-cpp.2 ==> csaru-core-cpp.2.1
            csaru-core-cpp.2.1
                cmake
                    csaru-core-cppConfig.cmake
                    csaru-core-cppConfigVersion.cmake
                dynamic
                static
                    libcsaru-core-cpp.a
                *.h
        src
            github.com
                akaito
                    csaru-core-cpp
                    csaru-core-cpp-test
