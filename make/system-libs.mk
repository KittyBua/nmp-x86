$(D)/lua: $(ARCHIVE)/lua-$(LUA_VER).tar.gz $(ARCHIVE)/luaposix-v$(LUAPOSIX_VER).tar.gz $(PATCHES)/liblua-$(LUA_VER)-luaposix-31.patch
	rm -rf $(SOURCE_DIR)/lua-$(LUA_VER); \
	$(UNTAR)/lua-$(LUA_VER).tar.gz
	set -e; cd $(SOURCE_DIR)/lua-$(LUA_VER); \
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

$(D)/libdvbsipp: $(ARCHIVE)/libdvbsi-git-$(LIBDVBSI_VER).tar.bz2
	rm -rf $(SOURCE_DIR)/libdvbsi-git-$(LIBDVBSI_VER); \
	$(UNTAR)/libdvbsi-git-$(LIBDVBSI_VER).tar.bz2
	set -e; cd $(SOURCE_DIR)/libdvbsi-git-$(LIBDVBSI_VER); \
		$(PATCH)/libdvbsi-git-$(LIBDVBSI_VER).patch; \
		./autogen.sh; \
		./configure --prefix=$(DEST); \
		$(MAKE); \
		make install
	touch $@

#
# graphlcd
#
#GRAPHLCD_VER = 55d4bd8
GRAPHLCD_VER = aafdbdf
GRAPHLCD_SOURCE = graphlcd-git-$(GRAPHLCD_VER).tar.bz2
GRAPHLCD_URL = https://vdr-projects.e-tobi.net/git/graphlcd-base
GRAPHLCD_PATCH1  = graphlcd-git-$(GRAPHLCD_VER).patch
GRAPHLCD_PATCH2  = graphlcd-vuplus4k.patch

$(ARCHIVE)/$(GRAPHLCD_SOURCE):
	$(SCRIPTS)/get-git-archive.sh $(GRAPHLCD_URL) $(GRAPHLCD_VER) $(notdir $@) $(ARCHIVE)

$(D)/graphlcd: $(ARCHIVE)/$(GRAPHLCD_SOURCE)
	rm -rf $(SOURCE_DIR)/graphlcd-git-$(GRAPHLCD_VER)
	$(UNTAR)/$(GRAPHLCD_SOURCE)
	set -e; cd $(SOURCE_DIR)/graphlcd-git-$(GRAPHLCD_VER); \
		$(PATCH)/$(GRAPHLCD_PATCH1); \
		$(PATCH)/$(GRAPHLCD_PATCH2); \
		$(MAKE) -C glcdgraphics all DESTDIR=$(DEST); \
		$(MAKE) -C glcddrivers all DESTDIR=$(DEST); \
		$(MAKE) -C glcdgraphics install DESTDIR=$(DEST); \
		$(MAKE) -C glcddrivers install DESTDIR=$(DEST); \
		cp -a graphlcd.conf $(DEST)/etc
	touch $@
