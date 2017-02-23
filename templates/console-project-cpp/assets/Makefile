# Expected location for this project is in <CSaruEnv>/src/<this-project>
# CSaruEnv is expected to have a makefiles directory for handy selection of what
# this directory will turn into.
#
# For CSaruEnv, see https://github.com/Akaito/codesaru-environ

# Special variable used to build ld (linker) -l and -L args.
# Space-separated list of CSaruEnv modules.
# Note! ld is sensitive to the order these appear in.  Base-most goes last.
CSARU_DEPENDS = csaru-core-cpp

# CSaruEnv Makefiles append to variables like LDLIBS, so we can freely set them
# up here.
#CXXFLAGS += -I../../pkg/vendor/CML

#LIBS_NEEDED := SDL2 SDL2_image SDL2_ttf physfs
LIBS_NEEDED := SDL2
LDLIBS += $(addprefix -l,$(LIBS_NEEDED))

include ../../makefiles/Makefile-executable

