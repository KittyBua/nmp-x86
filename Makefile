####################################################
# Makefile for building native neutrino / libstb-hal
# (C) 2012,2013 Stefan Seyfried
#
# taken from seife's build system, modified from
# (C) 2014 TangoCash, 2015 Max,TangoCash
# (C) 2016 TangoCash
#
# prerequisite packages need to be installed,
# no checking is done for that
####################################################

ARCHIVE    = $(BASE_DIR)/Archive
BASE_DIR   = $(PWD)
BUILD_TMP  = $(BASE_DIR)/build_tmp
SOURCE_DIR = $(BASE_DIR)/build_source
SCRIPTS    = $(BASE_DIR)/scripts

BOXTYPE    = generic
DEST       = $(BASE_DIR)/build_sysroot
D          = $(BASE_DIR)/deps

N_OBJDIR   = $(BUILD_TMP)/$(NEUTRINO)
LH_OBJDIR  = $(BUILD_TMP)/$(LIBSTB_HAL)

PATCHES    = $(BASE_DIR)/patches

PARALLEL_JOBS := $(shell echo $$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))
override MAKE = make $(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS)) $(SILENT_OPT)

#supported flavours: DDT,MAX,NI,TUXBOX,TANGOSEVO,TANGOSSKINNED,TANGOS (default)
FLAVOUR	  ?= TANGOS

N_PATCHES  = $(PATCHES)/neutrino-mp.pc.diff
LH_PATCHES = $(PATCHES)/libstb-hal.pc.diff

CFLAGS     = -funsigned-char -g -W -Wall -Wshadow -O2
CFLAGS    += -Wno-unused-result
CFLAGS    += -rdynamic
CFLAGS    += -DPEDANTIC_VALGRIND_SETUP
CFLAGS    += -DDYNAMIC_LUAPOSIX
CFLAGS    += -ggdb
CFLAGS    += -D__user=
CFLAGS    += -D__STDC_CONSTANT_MACROS
### enable --as-needed for catching more build problems...
CFLAGS    += -Wl,--as-needed
CFLAGS    += $(shell pkg-config --cflags --libs freetype2)
###
CFLAGS    += -pthread
CFLAGS    += $(shell pkg-config --cflags --libs glib-2.0)
CFLAGS    += $(shell pkg-config --cflags --libs libxml-2.0)
### GST
ifeq ($(shell pkg-config --exists gstreamer-1.0 && echo 1),1)
	CFLAGS    += $(shell pkg-config --cflags --libs gstreamer-1.0)
	CFLAGS    += $(shell pkg-config --cflags --libs gstreamer-audio-1.0)
	CFLAGS    += $(shell pkg-config --cflags --libs gstreamer-video-1.0)
	GST-PLAYBACK = --enable-gstreamer=yes
endif

### workaround for debian's non-std sigc++ locations
CFLAGS += -I/usr/include/sigc++-2.0
CFLAGS += -I/usr/lib/x86_64-linux-gnu/sigc++-2.0/include

### in case some libs are installed in $(DEST) (e.g. dvbsi++ / lua / ffmpeg)
CFLAGS    += -I$(DEST)/include
CFLAGS    += -L$(DEST)/lib
CFLAGS    += -L$(DEST)/lib64

PKG_CONFIG_PATH = $(DEST)/lib/pkgconfig
export PKG_CONFIG_PATH

CXXFLAGS = $(CFLAGS)
export CFLAGS CXXFLAGS

# Prepend ccache into the PATH
PATH := $(PATH):/usr/lib/ccache/
CC    = ccache gcc
CXX   = ccache g++
export CC CXX PATH

### export our custom lib dir
#export LD_LIBRARY_PATH=$(DEST)/lib
export LUA_PATH=$(DEST)/share/lua/5.2/?.lua;;

### in case no frontend is available uncomment next 3 lines
export SIMULATE_FE=1
#export HAL_NOAVDEC=1
#export HAL_DEBUG=0xff
#export NO_SLOW_ADDEVENT=1

# wget tarballs into archive directory
WGET = wget --no-check-certificate -t6 -T20 -c -P $(ARCHIVE)

# unpack tarballs
UNTAR = tar -C $(SOURCE_DIR) -xf $(ARCHIVE)

BOOTSTRAP = $(ARCHIVE) $(SOURCE_DIR) $(D)

# first target is default...
default: bootstrap $(D)/libdvbsipp $(D)/lua neutrino
	make run

$(ARCHIVE):
	mkdir -p $(ARCHIVE)

$(SOURCE_DIR):
	mkdir -p $(SOURCE_DIR)

$(D):
	mkdir -p $(D)

bootstrap: $(BOOTSTRAP)

run:
	gdb -ex run $(DEST)/bin/neutrino

run-nogdb:
	$(DEST)/bin/neutrino

run-valgrind:
	valgrind --leak-check=full --log-file="valgrind_`date +'%y.%m.%d %H:%M:%S'`.log" -v $(DEST)/bin/neutrino

$(BUILD_TMP):
	mkdir -p $(BUILD_TMP)
$(BUILD_TMP)/neutrino \
$(BUILD_TMP)/libstb-hal: | $(BUILD_TMP)
	mkdir -p $@

clean:
	-$(MAKE) -C $(N_OBJDIR) clean
	-$(MAKE) -C $(LH_OBJDIR) clean
	rm -rf $(N_OBJDIR) $(LH_OBJDIR)

distclean:
	rm -rf $(SOURCE_DIR)
	rm -rf $(D)
	rm -rf $(DEST)
	rm -rf $(BUILD_TMP)

update:
	make libstb-hal-distclean
	make neutrino-distclean
	rm -rf $(BUILD_TMP)
	make default

update-s:
	make libstb-hal-distclean
	make neutrino-distclean
	rm -rf $(BUILD_TMP)
	make neutrino

#
# patch helper
#
neutrino%-patch \
libstb-hal%-patch:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,-`date +%d.%m.%Y_%H:%M`.patch,$@) ; [ $$? -eq 1 ] )

neutrino%-diff \
libstb-hal%-diff:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS)/diff-exclude $(subst -diff,,$@).dev $(subst -diff,,$@) > $(BASE_DIR)/$(subst -diff,-`date +%d.%m.%Y_%H:%M`.patch,$@) ; [ $$? -eq 1 ] )

include make/buildenv.mk
include make/archives.mk
include make/system-libs.mk
include make/neutrino.mk
include Makefile.local

PHONY = update
.PHONY: $(PHONY)

