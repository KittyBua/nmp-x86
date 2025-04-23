# 
LUA_VER=5.2.4
LUAPOSIX_VER=31
LIBDVBSI_VER=ff57e58

# luaposix: posix bindings for lua
$(ARCHIVE)/luaposix-v$(LUAPOSIX_VER).tar.gz:
	$(WGET) https://github.com/luaposix/luaposix/archive/v$(LUAPOSIX_VER).tar.gz -O $@

# lua: easily embeddable scripting language
$(ARCHIVE)/lua-$(LUA_VER).tar.gz:
	$(WGET) http://www.lua.org/ftp/lua-$(LUA_VER).tar.gz

# libdvbsi
$(ARCHIVE)/libdvbsi-git-$(LIBDVBSI_VER).tar.bz2:
	$(SCRIPTS)/get-git-archive.sh https://git.opendreambox.org/git/obi/libdvbsi++.git $(LIBDVBSI_VER) $(notdir $@) $(ARCHIVE)
