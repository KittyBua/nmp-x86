# ffmpeg parameters taken from max-git - used to build ffmpeg to our custom lib dir
FFMPEG_CONFIGURE  = --disable-static --enable-shared --enable-small --disable-runtime-cpudetect
FFMPEG_CONFIGURE += --disable-ffprobe
FFMPEG_CONFIGURE += --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages
FFMPEG_CONFIGURE += --disable-asm --disable-altivec --disable-amd3dnow --disable-amd3dnowext --disable-mmx --disable-mmxext
FFMPEG_CONFIGURE += --disable-sse --disable-sse2 --disable-sse3 --disable-ssse3 --disable-sse4 --disable-sse42 --disable-avx --disable-fma4
FFMPEG_CONFIGURE += --disable-armv5te --disable-armv6 --disable-armv6t2 --disable-vfp --disable-neon --disable-inline-asm
FFMPEG_CONFIGURE += --disable-yasm --disable-mips32r2 --disable-mipsdspr2 --disable-mipsfpu --disable-fast-unaligned
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
# extra parameters for PC playback
FFMPEG_CONFIGURE += --enable-decoder=mp2 --enable-decoder=ac3 --enable-decoder=hevc

$(D)/ffmpeg: $(ARCHIVE)/ffmpeg-$(FFMPEG_VER).tar.bz2
	rm -rf cd $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER); \
	$(UNTAR)/ffmpeg-$(FFMPEG_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER); \
		./configure --prefix=$(DEST) $(FFMPEG_CONFIGURE) ; \
		$(MAKE); \
		make install
	touch $@

$(D)/lua: $(ARCHIVE)/lua-$(LUA_VER).tar.gz $(ARCHIVE)/luaposix-v$(LUAPOSIX_VER).tar.gz $(PATCHES)/liblua-5.2.3-luaposix-31.patch
	rm -rf $(BUILD_TMP)/lua-$(LUA_VER); \
	$(UNTAR)/lua-$(LUA_VER).tar.gz
	set -e; cd $(BUILD_TMP)/lua-$(LUA_VER); \
		$(PATCH)/liblua-$(LUA_VER)-luaposix-$(LUAPOSIX_VER).patch; \
		tar xf $(ARCHIVE)/luaposix-v$(LUAPOSIX_VER).tar.gz; \
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
	touch $@

$(D)/libdvbsipp: $(ARCHIVE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2
	rm -rf $(BUILD_TMP)/libdvbsi++-$(LIBDVBSI_VER); \
	$(UNTAR)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/libdvbsi++-$(LIBDVBSI_VER); \
		$(PATCH)/libdvbsi++-$(LIBDVBSI_VER).patch; \
		./autogen.sh; \
		./configure --prefix=$(DEST); \
		$(MAKE); \
		make install
	touch $@

$(D)/libsigcpp: $(ARCHIVE)/libsigc++-$(LIBSIGC_VER).tar.xz
	rm -rf $(BUILD_TMP)/libsigc++-$(LIBSIGC_VER); \
	$(UNTAR)/libsigc++-$(LIBSIGC_VER).tar.xz
	set -e; cd $(BUILD_TMP)/libsigc++-$(LIBSIGC_VER); \
		./configure \
			--prefix=$(DEST) \
			--enable-shared \
			--disable-documentation; \
		$(MAKE); \
		make install
		mv $(DEST)/lib/sigc++-2.0/include/sigc++config.h $(DEST)/include
	touch $@

