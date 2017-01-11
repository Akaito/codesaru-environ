# TODO
# 
# Read "A Super-Simple Makefile for Medium-Sized C/C++ Projects"
# https://spin.atomicobject.com/2016/08/26/makefile-c-projects/
#
# Maybe also reference this:
# https://www.cs.swarthmore.edu/~newhall/unixhelp/howto_makefiles.html
#

# Much of this Makefile was informed by:
# "A Super-Simple Makefile for Medium-Sized C/C++ Projects"
# https://spin.atomicobject.com/2016/08/26/makefile-c-projects/

WARNING_FLAGS := -Wall -Wextra -Wpedantic
CFLAGS := $(WARNING_FLAGS) -Wansi
CXXFLAGS := -std=c++11 $(WARNING_FLAGS)
CC := clang
CXX := clang++

# =  -- Lazy set; recursively expanded when used, not when declared.
# := -- Immediate set; expand when declared.
# ?= -- Set variable only if absent.

# notdir gives the last not-directory part (which happens to be a directory
# here).
PROJNAME = $(notdir $(shell pwd))
TARGET ?= lib$(PROJNAME).a

SRC_DIRS ?= ./src

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c)
OBJS := $(addsuffix .o,$(basename $(SRCS)))
DEPS := $(OBJS:.o=.d)

# All directories in ./src, etc.
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# -MMD: -MD, without mentioning system header files.
# -MD: Write out Make-style dependencies for each file.
# -MP: Also write a phony rule for each header, so if a header is removed
#  without updating the file Make is using, it won't error.
CXXFLAGS := $(INC_FLAGS) -MMD -MP $(CXXFLAGS)


.PHONY: clean test

$(TARGET): $(OBJS)
	@# Use the following for making an executable.
	@# $(CXX) $(LDFLAGS) $(OBJS) -o $@ $(LOADLIBS) $(LDLIBS)
	@# Or this for a static lib.
	@# r: Insert members with replacement.
	@# c: Don't warn if the archive didn't already exist.
	@# s: Add or update archive's index.
	$(AR) rcs $@ $^

test:
	@echo $(CXXFLAGS)
	@echo $(SRCS)
	@echo $(OBJS)
	@echo $(DEPS)

clean:
	$(RM) $(TARGET) $(OBJS) $(DEPS)

-include $(DEPS)

