$(D)/lua: $(ARCHIVE)/lua-$(LUA_VER).tar.gz $(ARCHIVE)/luaposix-v$(LUAPOSIX_VER).tar.gz $(PATCHES)/liblua-$(LUA_VER)-luaposix-31.patch
	rm -rf $(BUILD_SRC)/lua-$(LUA_VER); \
	$(UNTAR)/lua-$(LUA_VER).tar.gz
	set -e; cd $(BUILD_SRC)/lua-$(LUA_VER); \
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
	rm -rf $(BUILD_SRC)/libdvbsi-git-$(LIBDVBSI_VER); \
	$(UNTAR)/libdvbsi-git-$(LIBDVBSI_VER).tar.bz2
	set -e; cd $(BUILD_SRC)/libdvbsi-git-$(LIBDVBSI_VER); \
		$(PATCH)/libdvbsi-git-$(LIBDVBSI_VER).patch; \
		./autogen.sh; \
		./configure --prefix=$(DEST); \
		$(MAKE); \
		make install
	touch $@

