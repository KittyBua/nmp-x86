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

ARCHIVE    = $(HOME)/Archive
BASE_DIR   = $(PWD)
BUILD_TMP  = $(BASE_DIR)/build_tmp
OBJ        = $(BASE_DIR)/obj

BOXTYPE    = generic
DEST       = $(BASE_DIR)/$(BOXTYPE)
D          = $(BASE_DIR)/deps

LH_SRC     = $(BUILD_TMP)/libstb-hal
LH_OBJ     = $(OBJ)/libstb-hal
N_SRC      = $(BUILD_TMP)/neutrino-mp
N_OBJ      = $(OBJ)/neutrino-mp

PATCHES    = $(BASE_DIR)/patches

#supported flavours: classic,franken,tangos (default)
FLAVOUR	  ?= tangos

N_PATCHES  = $(PATCHES)/neutrino-mp.pc.diff
### gcc > 5 needs extra patch
GCCVERSION_GT5 := $(shell expr `gcc -dumpversion | cut -f1 -d.` \>= 5)
ifeq ($(GCCVERSION_GT5), 1)
    N_PATCHES  += $(PATCHES)/fix_DVB_API_VERSION_check_for_gcc5.patch
endif

LH_PATCHES = $(PATCHES)/libstb-hal.pc.diff

CFLAGS     = -funsigned-char -g -W -Wall -Wshadow -O2
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
CFLAGS    += $(shell pkg-config --cflags --libs gstreamer-0.10)

### in case some libs are installed in $(DEST) (e.g. dvbsi++ / lua / ffmpeg)
CFLAGS    += -I$(DEST)/include
CFLAGS    += -I$(DEST)/include/sigc++-2.0
CFLAGS    += -L$(DEST)/lib
PKG_CONFIG_PATH = $(DEST)/lib/pkgconfig
export PKG_CONFIG_PATH

CXXFLAGS = $(CFLAGS)
export CFLAGS CXXFLAGS

### export our custom lib dir
export LD_LIBRARY_PATH=$(DEST)/lib

### in case no frontend is available uncomment next 3 lines
#export SIMULATE_FE=1
#export HAL_NOAVDEC=1
#export HAL_DEBUG=0xff
export NO_SLOW_ADDEVENT=1

# wget tarballs into archive directory
WGET = wget --no-check-certificate -t6 -T20 -c -P $(ARCHIVE)

# unpack tarballs
UNTAR = tar -C $(BUILD_TMP) -xf $(ARCHIVE)

BOOTSTRAP = $(ARCHIVE) $(BUILD_TMP) $(D)

# first target is default...
default: bootstrap $(D)/libdvbsipp $(D)/ffmpeg $(D)/lua $(D)/libsigcpp neutrino
	make run

$(ARCHIVE):
	mkdir -p $(ARCHIVE)

$(BUILD_TMP):
	mkdir -p $(BUILD_TMP)

$(D):
	mkdir -p $(D)

bootstrap: $(BOOTSTRAP)

run:
	gdb -ex run $(DEST)/bin/neutrino

run-nogdb:
	$(DEST)/bin/neutrino

run-valgrind:
	valgrind --leak-check=full --log-file="valgrind_`date +'%y.%m.%d %H:%M:%S'`.log" -v $(DEST)/bin/neutrino

$(OBJ):
	mkdir -p $(OBJ)
$(OBJ)/neutrino-mp \
$(OBJ)/libstb-hal: | $(OBJ)
	mkdir -p $@

clean:
	-$(MAKE) -C $(N_OBJ) clean
	-$(MAKE) -C $(LH_OBJ) clean
	rm -rf $(N_OBJ) $(LH_OBJ)

distclean:
	rm -rf $(BUILD_TMP)
	rm -rf $(D)
	rm -rf $(DEST)
	rm -rf $(OBJ)

update:
	rm -rf $(LH_SRC)
	rm -rf $(LH_SRC).org
	rm -rf $(N_SRC)
	rm -rf $(N_SRC).org
	rm -rf $(OBJ)
	make default

update-s:
	rm -rf $(LH_SRC)
	rm -rf $(LH_SRC).org
	rm -rf $(N_SRC)
	rm -rf $(N_SRC).org
	rm -rf $(OBJ)
	make neutrino

copy:
	rm -rf $(LH_SRC).org
	cp -r $(LH_SRC) $(LH_SRC).org
	rm -rf $(N_SRC).org
	cp -r $(N_SRC) $(N_SRC).org

diff:
	make diff-n
	make diff-lh

diff-n:
	mkdir -p $(PWD)/own_patch
	cd $(BUILD_TMP) && \
	diff -NEbur --exclude-from=$(PWD)/diff-exclude neutrino-mp.org neutrino-mp > $(PWD)/own_patch/neutrino-mp.pc.diff ; [ $$? -eq 1 ]

diff-lh:
	mkdir -p $(PWD)/own_patch
	cd $(BUILD_TMP) && \
	diff -NEbur --exclude-from=$(PWD)/diff-exclude libstb-hal.org libstb-hal > $(PWD)/own_patch/libstb-hal.pc.diff ; [ $$? -eq 1 ]

include make/buildenv.mk
include make/archives.mk
include make/system-libs.mk
include make/neutrino.mk
include Makefile.local

PHONY = update
.PHONY: $(PHONY)

