SHELL=/bin/bash -e -E

.PHONY: all pblib gtest cramtests check clean cleanall

# blasr make paths and commands
OS := $(shell uname)

GIT_BLASR_LIBPATH = libcpp
PB_BLASR_LIBPATH = ../../lib/cpp

# Determine where is PBINCROOT, either from github or PacBio SMRTAnalysis package.
PBINCROOT ?= $(shell cd $(GIT_BLASR_LIBPATH) 2>/dev/null && pwd || echo -n notfound)
ifeq ($(PBINCROOT), notfound)
	PBINCROOT := $(shell cd $(PB_BLASR_LIBPATH) 2>/dev/null && pwd || echo -n notfound)
	ifeq ($(PBINCROOT), notfound)
		$(error please check your blasr lib exists.)
	endif
endif

# common.mk contains the configuration for this build setup
GIT_COMMON_MK = blasr_git_common.mk
ifneq ($(shell ls $(GIT_COMMON_MK) 2>/dev/null || echo -n notfound), notfound)
include $(GIT_COMMON_MK)
endif

PREBUILT ?= ../../../prebuilt.out
THIRD_PARTY_PREFIX := ..

include $(PBINCROOT)/common.mk

INCDIRS = -I$(PBINCROOT)/alignment \
		  -I$(PBINCROOT)/hdf \
		  -I$(PBINCROOT)/pbdata \
		  -I$(HDF5_ROOT)/include

LIBDIRS = -L$(PBINCROOT)/alignment \
		  -L$(PBINCROOT)/hdf \
		  -L$(PBINCROOT)/pbdata \
		  -L$(HDF5_ROOT)/lib

ifneq ($(ZLIB_ROOT), notfound)
	INCDIRS += -I$(ZLIB_ROOT)/include
	LIBDIRS += -L$(ZLIB_ROOT)/lib
endif

CXXOPTS := -std=c++0x -pedantic \
	        -Wall -Wuninitialized -Wno-div-by-zero \
            -MMD -MP -w -fpermissive

SRCS := $(wildcard *.cpp)
OBJS := $(SRCS:.cpp=.o)
DEPS := $(SRCS:.cpp=.d)
LIBS := -lblasr -lpbihdf -lpbdata -lhdf5_cpp -lhdf5 -lz -lpthread -ldl
ifneq ($(OS), Darwin)
	LIBS += -lrt
	STATIC := -static
else
	STATIC :=
endif

# -lhdf5, -lhdf5_cpp, -lz required for HDF5
# -lpthread for multi-threading
# -lrt for clock_gettime
# -ldl for dlopen dlclose 


all : CXXFLAGS ?= -O3

debug : CXXFLAGS ?= -g -ggdb -fno-inline

profile : CXXFLAGS ?= -Os -pg 

g: CXXFLAGS += -fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free -fno-omit-frame-pointer 
g: LIBS += -Wl --eh-frame-hdr -fno-builtin-malloc -L$(HOME)/lib -ltcmalloc -lunwind -lprofiler $(LIBS)

all: MODE = 
debug: MODE=debug
profile: MODE = profile 
g: MODE = g

all debug profile g: blasr

all debug profile g: 
	make -C $(PBINCROOT) $(MODE)
	make -C tools $(MODE)

blasr: Blasr.cpp pblib
	$(CXX_pp) $(CXXOPTS) $(CXXFLAGS) $(INCDIRS) -MF"$(@:%=%.d)" $(STATIC) -o $@ $(SRCS) $(LIBDIRS) $(LIBS)

pblib: $(PBINCROOT)/Makefile
	make -C $(PBINCROOT)

cramtests: blasr
	cram -v --shell=/bin/bash ctest/*.t

cramtests_tools:
	make -C tools cramtests

clean_blasr:
	make -C $(PBINCROOT) clean
	@rm -f blasr
	@rm -f $(OBJS) $(DEPS)

clean: clean_blasr
	make -C tools clean

.INTERMEDIATE: $(OBJS) $(DEPS)

-include $(DEPS)

