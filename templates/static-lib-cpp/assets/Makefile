# Expected location for this project is in <CSaruEnv>/src/<this-project>
# CSaruEnv is expected to have a makefiles directory for handy selection of what
# this directory will turn into.
#
# For CSaruEnv, see https://github.com/Akaito/codesaru-environ

# Special variable used to build ld (linker) -l and -L args.
# Space-separated list of CSaruEnv modules.
CSARU_DEPENDS = csaru-datamap-cpp csaru-uuid-cpp csaru-core-cpp vendor/CML
PROJ_VERSION = 0.1

# CSaruEnv Makefiles append to variables like LDLIBS, so we can freely set them
# up here.
LDLIBS = -l SDL2
CXXFLAGS += -I../../pkg/vendor/CML

include ../../makefiles/Makefile-staticlib

