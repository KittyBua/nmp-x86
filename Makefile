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

N_PATCHES = $(PATCHES)/neutrino-mp.pc.diff

LH_PATCHES =

CFLAGS =  -funsigned-char -g -W -Wall -Wshadow -O2
CFLAGS += -rdynamic
CFLAGS += -DPEDANTIC_VALGRIND_SETUP
CFLAGS += -DDYNAMIC_LUAPOSIX
### enable --as-needed for catching more build problems...
CFLAGS += -Wl,--as-needed
CFLAGS += -I/usr/include/freetype2
###
CFLAGS += -pthread
CFLAGS += -I/usr/include/glib-2.0
CFLAGS += -I/usr/lib/i386-linux-gnu/glib-2.0/include
CFLAGS += -I/usr/include/libxml2
### GST
CFLAGS += -I/usr/include/gstreamer-0.10
CFLAGS += -L/usr/lib/i386-linux-gnu/gstreamer-0.10

### in case some libs are installed in $(DEST) (e.g. dvbsi++ / lua / ffmpeg)
CFLAGS += -I$(DEST)/include
CFLAGS += -L$(DEST)/lib
PKG_CONFIG_PATH = $(DEST)/lib/pkgconfig
export PKG_CONFIG_PATH
### export our custom lib dir
export LD_LIBRARY_PATH=$(DEST)/lib
### in case no frontend is available
export SIMULATE_FE=1
export HAL_NOAVDEC=1
expert HAL_DEBUG=0xff

CXXFLAGS = $(CFLAGS)

export CFLAGS CXXFLAGS

# first target is default...
default: libdvbsi ffmpeg lua neutrino
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
	for i in $(LH_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(LH_SRC) && patch -p1 -i $$i; \
	done;
	$(LH_SRC)/autogen.sh
	set -e; cd $(LH_OBJ); \
		$(LH_SRC)/configure --enable-maintainer-mode \
			--prefix=$(DEST) --enable-shared=no
# --enable-gstreamer=yes

$(N_OBJ)/config.status: | $(N_OBJ) $(N_SRC) $(LH_OBJ)/libstb-hal.a
	for i in $(N_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(N_SRC) && patch -p1 -i $$i; \
	done;
	$(N_SRC)/autogen.sh
	set -e; cd $(N_OBJ); \
		$(N_SRC)/configure --enable-maintainer-mode \
			--prefix=$(DEST) \
			--enable-silent-rules --enable-mdev \
			--enable-giflib \
			--enable-cleanup \
			--enable-lua \
			--enable-ffmpeg \
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
	mkdir $(OBJ)
$(OBJ)/neutrino-mp \
$(OBJ)/libstb-hal: | $(OBJ)
	mkdir $@

$(SOURCE):
	mkdir $@

$(LH_SRC): | $(SOURCE)
	cd $(SOURCE) && git clone -b next git@gitorious.org:neutrino-hd/max10s-libstb-hal.git libstb-hal

$(N_SRC): | $(SOURCE)
	cd $(SOURCE) && git clone -b next git@gitorious.org:neutrino-mp/max10s-neutrino-mp.git neutrino-mp

checkout: $(SOURCE)/libstb-hal $(SOURCE)/neutrino-mp

clean:
	-$(MAKE) -C $(N_OBJ) clean
	-$(MAKE) -C $(LH_OBJ) clean
	rm -rf $(N_OBJ) $(LH_OBJ)

update: 
	cd $(LH_SRC) && git pull
	cd $(N_SRC) && git pull

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

$(SOURCE)/ffmpeg-2.0.2.tar.bz2: | $(SOURCE)
	cd $(SOURCE) && wget http://www.ffmpeg.org/releases/ffmpeg-2.0.2.tar.bz2

ffmpeg: $(SOURCE)/ffmpeg-2.0.2.tar.bz2
	tar -C $(SOURCE) -xf $(SOURCE)/ffmpeg-2.0.2.tar.bz2
	set -e; cd $(SOURCE)/ffmpeg-2.0.2; \
		./configure --prefix=$(DEST) $(FFMPEG_CONFIGURE) ; \
		$(MAKE); \
		make install

# we also need lua in our custom lib dir
$(SOURCE)/lua-5.2.2.tar.gz: | $(SOURCE)
	cd $(SOURCE) && curl -R -O http://www.lua.org/ftp/lua-5.2.2.tar.gz; \
	tar zxf lua-5.2.2.tar.gz;

lua: $(SOURCE)/lua-5.2.2.tar.gz
	cd $(SOURCE)/lua-5.2.2 && $(MAKE) linux; \
	$(MAKE) install INSTALL_TOP=$(DEST); \
	rm -rf $(DEST)/man


# libdvbsi is not commonly packaged for linux distributions...
# so we install it to our custom lib dir
$(SOURCE)/libdvbsi++-0.3.6.tar.bz2: | $(SOURCE)
	cd $(SOURCE) && wget http://www.saftware.de/libdvbsi++/libdvbsi++-0.3.6.tar.bz2

libdvbsi: $(SOURCE)/libdvbsi++-0.3.6.tar.bz2
	tar -C $(SOURCE) -xf $(SOURCE)/libdvbsi++-0.3.6.tar.bz2
	set -e; cd $(SOURCE)/libdvbsi++-0.3.6; \
		./configure --prefix=$(DEST); \
		$(MAKE); \
		make install

PHONY = checkout
.PHONY: $(PHONY)

