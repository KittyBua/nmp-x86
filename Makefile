####################################################
# Makefile for building native neutrino / libstb-hal
# (C) 2012,2013 Stefan Seyfried
#
# taken from seife's build system, modified from
# (C) 2014 TangoCash
#
# prerequisite packages need to be installed,
# no checking is done for that
####################################################

SOURCE = $(PWD)/source
OBJ = $(PWD)/obj

BOXTYPE = generic
DEST = $(PWD)/$(BOXTYPE)

LH_SRC = $(SOURCE)/libstb-hal
LH_OBJ = $(OBJ)/libstb-hal
N_SRC  = $(SOURCE)/neutrino-mp
N_OBJ  = $(OBJ)/neutrino-mp

PATCHES = $(PWD)/patches
PATCH = patch -p1 -i $(PATCHES)

N_PATCHES = $(PATCHES)/neutrino-mp.pc.diff

LH_PATCHES = $(PATCHES)/libstb-hal.pc.diff

CFLAGS =  -funsigned-char -g -W -Wall -Wshadow -O2
CFLAGS += -rdynamic
CFLAGS += -DPEDANTIC_VALGRIND_SETUP
CFLAGS += -DDYNAMIC_LUAPOSIX
CFLAGS += -ggdb
CFLAGS += -D__user=
### enable --as-needed for catching more build problems...
CFLAGS += -Wl,--as-needed
CFLAGS += $(shell pkg-config --cflags --libs freetype2)
###
CFLAGS += -pthread
CFLAGS += $(shell pkg-config --cflags --libs glib-2.0)
CFLAGS += $(shell pkg-config --cflags --libs libxml-2.0)
### GST
CFLAGS += $(shell pkg-config --cflags --libs gstreamer-0.10)

### in case some libs are installed in $(DEST) (e.g. dvbsi++ / lua / ffmpeg)
CFLAGS += -I$(DEST)/include
CFLAGS += -I$(DEST)/include/sigc++-2.0
CFLAGS += -L$(DEST)/lib
PKG_CONFIG_PATH = $(DEST)/lib/pkgconfig
export PKG_CONFIG_PATH
### export our custom lib dir
export LD_LIBRARY_PATH=$(DEST)/lib
### in case no frontend is available uncomment next 3 lines
#export SIMULATE_FE=1
#export HAL_NOAVDEC=1
#export HAL_DEBUG=0xff
export NO_SLOW_ADDEVENT=1

CXXFLAGS = $(CFLAGS)

export CFLAGS CXXFLAGS

# first target is default...
default: libdvbsi ffmpeg lua libsigc++ neutrino
	make run

run:
	gdb -ex run $(DEST)/bin/neutrino

neutrino: $(N_OBJ)/config.status
	-rm $(N_OBJ)/src/neutrino # force relinking on changed libstb-hal
	$(MAKE) -C $(N_OBJ) CC="ccache gcc" CXX="ccache g++" install
	find $(DEST)/../own_build/ -mindepth 1 -maxdepth 1 -exec cp -at$(DEST)/ -- {} +

$(LH_OBJ)/libstb-hal.a: libstb-hal
libstb-hal: $(LH_OBJ)/config.status
	$(MAKE) -C $(LH_OBJ) CC="ccache gcc" CXX="ccache g++" install

$(LH_OBJ)/config.status: | $(LH_OBJ) $(LH_SRC)
	$(LH_SRC)/autogen.sh
	set -e; cd $(LH_OBJ); \
		$(LH_SRC)/configure --enable-maintainer-mode \
			--prefix=$(DEST) --enable-shared=no \
			--enable-gstreamer=yes

$(N_OBJ)/config.status: | $(N_OBJ) $(N_SRC) $(LH_OBJ)/libstb-hal.a
	$(N_SRC)/autogen.sh
	set -e; cd $(N_OBJ); \
		$(N_SRC)/configure --enable-maintainer-mode \
			--prefix=$(DEST) \
			--enable-silent-rules --enable-mdev \
			--enable-giflib \
			--enable-cleanup \
			--enable-lua \
			--enable-ffmpegdec \
			--disable-upnp \
			--disable-webif \
			--with-datadir=$(DEST)/share/tuxbox \
			--with-fontdir=$(DEST)/share/fonts \
			--with-gamesdir=$(DEST)/var/tuxbox/games \
			--with-plugindir=$(DEST)/var/tuxbox/plugins \
			--with-configdir=$(DEST)/var/tuxbox/config \
			--with-isocodesdir=$(DEST)/share/iso-codes \
			--with-target=native --with-boxtype=$(BOXTYPE) \
			--with-stb-hal-includes=$(LH_SRC)/include \
			--with-stb-hal-build=$(DEST)/lib \
			; \
		test -e svn_version.h || echo '#define BUILT_DATE "error - not set"' > svn_version.h; \
		test -e git_version.h || echo '#define BUILT_DATE "error - not set"' > git_version.h; \
		test -e version.h || touch version.h

$(OBJ):
	mkdir -p $(OBJ)
$(OBJ)/neutrino-mp \
$(OBJ)/libstb-hal: | $(OBJ)
	mkdir -p $@

$(SOURCE):
	mkdir -p $@

$(LH_SRC): | $(SOURCE)
	cd $(SOURCE) && git clone https://github.com/MaxWiesel/libstb-hal.git libstb-hal
	rm -rf $(SOURCE)/libstb-hal.org
	cp -ra $(SOURCE)/libstb-hal $(SOURCE)/libstb-hal.org
	for i in $(LH_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(LH_SRC) && patch -p1 -i $$i; \
	done;


$(N_SRC): | $(SOURCE)
	cd $(SOURCE) && git clone https://github.com/TangoCash/neutrino-mp-cst-next.git neutrino-mp
	rm -rf $(SOURCE)/neutrino-mp.org
	cp -ra $(SOURCE)/neutrino-mp $(SOURCE)/neutrino-mp.org
	for i in $(N_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(N_SRC) && patch -p1 -i $$i; \
	done;


checkout: $(SOURCE)/libstb-hal $(SOURCE)/neutrino-mp

clean:
	-$(MAKE) -C $(N_OBJ) clean
	-$(MAKE) -C $(LH_OBJ) clean
	rm -rf $(N_OBJ) $(LH_OBJ)

update: 
	cd $(LH_SRC) && git pull
	cd $(N_SRC) && git pull

diff:
	mkdir -p $(PWD)/own_patch
	cd $(SOURCE) && \
	diff -NEbur --exclude-from=$(PWD)/diff-exclude neutrino-mp.org neutrino-mp > $(PWD)/own_patch/neutrino-mp.diff ; [ $$? -eq 1 ]
	cd $(SOURCE) && \
	diff -NEbur --exclude-from=$(PWD)/diff-exclude libstb-hal.org libstb-hal > $(PWD)/own_patch/libstb-hal.diff ; [ $$? -eq 1 ]


# ffmpeg parameters taken from max-git - used to build ffmpeg to our custom lib dir
FFMPEG_CONFIGURE  = --disable-static --enable-shared --enable-small --disable-runtime-cpudetect
FFMPEG_CONFIGURE += --disable-ffserver --disable-ffplay --disable-ffprobe
FFMPEG_CONFIGURE += --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages
FFMPEG_CONFIGURE += --disable-asm --disable-altivec --disable-amd3dnow --disable-amd3dnowext --disable-mmx --disable-mmxext
FFMPEG_CONFIGURE += --disable-sse --disable-sse2 --disable-sse3 --disable-ssse3 --disable-sse4 --disable-sse42 --disable-avx --disable-fma4
FFMPEG_CONFIGURE += --disable-armv5te --disable-armv6 --disable-armv6t2 --disable-vfp --disable-neon --disable-vis --disable-inline-asm
FFMPEG_CONFIGURE += --disable-yasm --disable-mips32r2 --disable-mipsdspr1 --disable-mipsdspr2 --disable-mipsfpu --disable-fast-unaligned
FFMPEG_CONFIGURE += --disable-muxers
FFMPEG_CONFIGURE += --enable-muxer=flac --enable-muxer=mp3 --enable-muxer=h261 --enable-muxer=h263 --enable-muxer=h264
FFMPEG_CONFIGURE += --enable-muxer=image2 --enable-muxer=mpeg1video --enable-muxer=mpeg2video --enable-muxer=ogg
FFMPEG_CONFIGURE += --disable-encoders
FFMPEG_CONFIGURE += --enable-encoder=aac --enable-encoder=h261 --enable-encoder=h263 --enable-encoder=h263p --enable-encoder=ljpeg
FFMPEG_CONFIGURE += --enable-encoder=mjpeg --enable-encoder=mpeg1video --enable-encoder=mpeg2video --enable-encoder=png
FFMPEG_CONFIGURE += --disable-decoders
FFMPEG_CONFIGURE += --enable-decoder=aac --enable-decoder=dvbsub --enable-decoder=flac --enable-decoder=h261 --enable-decoder=h263
FFMPEG_CONFIGURE += --enable-decoder=h263i --enable-decoder=h264 --enable-decoder=iff_byterun1 --enable-decoder=mjpeg
FFMPEG_CONFIGURE += --enable-decoder=mp3 --enable-decoder=mpeg1video --enable-decoder=mpeg2video --enable-decoder=png
FFMPEG_CONFIGURE += --enable-decoder=theora --enable-decoder=vorbis --enable-decoder=wmv3 --enable-decoder=pcm_s16le
FFMPEG_CONFIGURE += --enable-demuxer=mjpeg --enable-demuxer=wav --enable-demuxer=rtsp
FFMPEG_CONFIGURE += --enable-parser=mjpeg
FFMPEG_CONFIGURE += --disable-indevs --disable-outdevs --disable-bsfs --disable-debug
FFMPEG_CONFIGURE += --enable-pthreads --enable-bzlib --enable-zlib --enable-stripping

#
FFMPEG_VER=2.1.4
#
$(SOURCE)/ffmpeg-$(FFMPEG_VER).tar.bz2: | $(SOURCE)
	cd $(SOURCE) && wget http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG_VER).tar.bz2

ffmpeg: $(SOURCE)/ffmpeg-$(FFMPEG_VER).tar.bz2
	tar -C $(SOURCE) -xf $(SOURCE)/ffmpeg-$(FFMPEG_VER).tar.bz2
	set -e; cd $(SOURCE)/ffmpeg-$(FFMPEG_VER); \
		./configure --prefix=$(DEST) $(FFMPEG_CONFIGURE) ; \
		$(MAKE); \
		make install

# luaposix: posix bindings for lua
#
LUAPOSIX_VER=31
#
$(SOURCE)/luaposix-v$(LUAPOSIX_VER).tar.gz: | $(SOURCE)
	cd $(SOURCE) && wget https://github.com/luaposix/luaposix/archive/v$(LUAPOSIX_VER).tar.gz -O $@

# lua: easily embeddable scripting language
#
LUA_VER=5.2.3
#
$(SOURCE)/lua-$(LUA_VER).tar.gz: | $(SOURCE)
	cd $(SOURCE) && wget http://www.lua.org/ftp/lua-$(LUA_VER).tar.gz

lua: $(SOURCE)/lua-$(LUA_VER).tar.gz $(SOURCE)/luaposix-v$(LUAPOSIX_VER).tar.gz $(PATCHES)/liblua-5.2.3-luaposix-31.patch
	tar -C $(SOURCE) -xf $(SOURCE)/lua-$(LUA_VER).tar.gz
	set -e; cd $(SOURCE)/lua-$(LUA_VER); \
		$(PATCH)/liblua-$(LUA_VER)-luaposix-$(LUAPOSIX_VER).patch; \
		tar xf $(SOURCE)/luaposix-v$(LUAPOSIX_VER).tar.gz; \
		cd luaposix-$(LUAPOSIX_VER)/ext; cp posix/posix.c include/lua52compat.h ../../src/; cd ../..; \
		sed -i 's/<config.h>/"config.h"/' src/posix.c; \
		sed -i '/^#define/d' src/lua52compat.h; \
		sed -i 's@^#define LUA_ROOT.*@#define LUA_ROOT "/"@' src/luaconf.h; \
		sed -i '/^#define LUA_USE_READLINE/d' src/luaconf.h; \
		sed -i 's/ -lreadline//' src/Makefile; \
		sed -i 's|man/man1|.remove|' Makefile; \
		$(MAKE) linux; \
		$(MAKE) install INSTALL_TOP=$(DEST); \
		rm -rf $(DEST)/man

# libdvbsi is not commonly packaged for linux distributions...
# so we install it to our custom lib dir
LIBDVBSI_VER=0.3.7
#
$(SOURCE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2: | $(SOURCE)
	cd $(SOURCE) && wget http://www.saftware.de/libdvbsi++/libdvbsi++-$(LIBDVBSI_VER).tar.bz2

libdvbsi: $(SOURCE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2
	tar -C $(SOURCE) -xf $(SOURCE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2
	set -e; cd $(SOURCE)/libdvbsi++-$(LIBDVBSI_VER); \
		./configure --prefix=$(DEST); \
		$(MAKE); \
		make install
#
#
LIBSIGC_VER=2.3.2
#
$(SOURCE)/libsigc++-$(LIBSIGC_VER).tar.xz: | $(SOURCE)
	cd $(SOURCE) && wget http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.3/libsigc++-$(LIBSIGC_VER).tar.xz

libsigc++: $(SOURCE)/libsigc++-$(LIBSIGC_VER).tar.xz
	tar -C $(SOURCE) -xf $(SOURCE)/libsigc++-$(LIBSIGC_VER).tar.xz
	set -e; cd $(SOURCE)/libsigc++-$(LIBSIGC_VER); \
		./configure \
			--prefix=$(DEST) \
			--enable-shared \
			--disable-documentation; \
		$(MAKE); \
		make install
		mv $(DEST)/lib/sigc++-2.0/include/sigc++config.h $(DEST)/include

PHONY = checkout
.PHONY: $(PHONY)

