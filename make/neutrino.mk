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

