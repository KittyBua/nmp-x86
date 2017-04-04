neutrino: bootstrap $(D)/libdvbsipp $(D)/ffmpeg $(D)/lua $(D)/libsigcpp $(N_OBJ)/config.status
	$(START_BUILD)
	-rm $(N_OBJ)/src/neutrino # force relinking on changed libstb-hal
	$(MAKE) -C $(N_OBJ) CC="ccache gcc" CXX="ccache g++" install
	find $(DEST)/../own_build/ -mindepth 1 -maxdepth 1 -exec cp -at$(DEST)/ -- {} +
	$(FINISH_BUILD)

$(LH_OBJ)/libstb-hal.a: libstb-hal
libstb-hal: $(LH_OBJ)/config.status
	$(START_BUILD)
	$(MAKE) -C $(LH_OBJ) CC="ccache gcc" CXX="ccache g++" install
	$(FINISH_BUILD)

$(LH_OBJ)/config.status: | $(LH_OBJ) $(LH_SRC)
	$(START_BUILD)
	$(LH_SRC)/autogen.sh
	set -e; cd $(LH_OBJ); \
		$(LH_SRC)/configure --enable-maintainer-mode \
			--prefix=$(DEST) --enable-shared=no \
			$(GST-PLAYBACK)
	$(FINISH_BUILD)

$(N_OBJ)/config.status: | $(N_OBJ) $(N_SRC) $(LH_OBJ)/libstb-hal.a
	$(START_BUILD)
	$(N_SRC)/autogen.sh
	set -e; cd $(N_OBJ); \
		$(N_SRC)/configure --enable-maintainer-mode \
			--prefix=$(DEST) \
			--enable-silent-rules --enable-mdev \
			--enable-giflib \
			--enable-cleanup \
			--enable-lua \
			--enable-ffmpegdec \
			--enable-testing \
			--enable-fribidi \
			--with-vardir=$(DEST)/var \
			--with-datadir=$(DEST)/share/tuxbox \
			--with-fontdir=$(DEST)/share/fonts \
			--with-gamesdir=$(DEST)/var/tuxbox/games \
			--with-plugindir=$(DEST)/var/tuxbox/plugins \
			--with-configdir=$(DEST)/var/tuxbox/config \
			--with-iconsdir=$(DEST)/share/tuxbox/neutrino/icons \
			--with-localedir=$(DEST)/share/tuxbox/neutrino/locale \
			--with-private_httpddir=$(DEST)/share/tuxbox/neutrino/httpd \
			--with-themesdir=$(DEST)/share/tuxbox/neutrino/themes \
			--with-isocodesdir=$(DEST)/share/iso-codes \
			--with-target=native --with-boxtype=$(BOXTYPE) \
			--with-stb-hal-includes=$(LH_SRC)/include \
			--with-stb-hal-build=$(DEST)/lib \
			; \
		test -e svn_version.h || echo '#define BUILT_DATE "error - not set"' > svn_version.h; \
		test -e git_version.h || echo '#define BUILT_DATE "error - not set"' > git_version.h; \
		test -e version.h || touch version.h
	$(FINISH_BUILD)

