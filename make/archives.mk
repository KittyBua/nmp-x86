# 
FFMPEG_VER=2.5
LUA_VER=5.2.3
LUAPOSIX_VER=31
LIBDVBSI_VER=0.3.7
LIBSIGC_VER_MAJ=2.3
LIBSIGC_VER_MIN=2
LIBSIGC_VER=$(LIBSIGC_VER_MAJ).$(LIBSIGC_VER_MIN)

GITCLONE=git clone git://github.com
GITNAMENMP=TangoCash
GITREPONMP=neutrino-mp-cst-next
GITNAMESTBHAL=Duckbox-Developers
GITREPOSTBHAL=libstb-hal-cst-next

# ffmpeg
$(ARCHIVE)/ffmpeg-$(FFMPEG_VER).tar.bz2:
	$(WGET) http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG_VER).tar.bz2

# luaposix: posix bindings for lua
$(ARCHIVE)/luaposix-v$(LUAPOSIX_VER).tar.gz:
	$(WGET) https://github.com/luaposix/luaposix/archive/v$(LUAPOSIX_VER).tar.gz -O $@

# lua: easily embeddable scripting language
$(ARCHIVE)/lua-$(LUA_VER).tar.gz:
	$(WGET) http://www.lua.org/ftp/lua-$(LUA_VER).tar.gz

# libdvbsi
$(ARCHIVE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2:
	$(WGET) http://www.saftware.de/libdvbsi++/libdvbsi++-$(LIBDVBSI_VER).tar.bz2

# libsigc
$(ARCHIVE)/libsigc++-$(LIBSIGC_VER).tar.xz:
	$(WGET) http://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGC_VER_MAJ)/libsigc++-$(LIBSIGC_VER).tar.xz

# stb-hal
$(LH_SRC):
	[ -d "$(archivedir)/$(GITREPOSTBHAL).git" ] && \
	(cd $(ARCHIVE)/$(GITREPOSTBHAL).git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/$(GITREPOSTBHAL).git" ] || \
	$(GITCLONE)/$(GITNAMESTBHAL)/$(GITREPOSTBHAL).git $(ARCHIVE)/$(GITREPOSTBHAL).git; \
	cp -ra $(ARCHIVE)/$(GITREPOSTBHAL).git $(BUILD_TMP)/libstb-hal;\
	cp -ra $(BUILD_TMP)/libstb-hal $(BUILD_TMP)/libstb-hal.org
	for i in $(LH_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(LH_SRC) && patch -p1 -i $$i; \
	done;

# neutrino mp
$(N_SRC):
	[ -d "$(ARCHIVE)/$(GITREPONMP).git" ] && \
	(cd $(ARCHIVE)/$(GITREPONMP).git; git pull; cd "$(BASE_DIR)";); \
	[ -d "$(ARCHIVE)/$(GITREPONMP).git" ] || \
	$(GITCLONE)/$(GITNAMENMP)/$(GITREPONMP).git $(ARCHIVE)/$(GITREPONMP).git; \
	cp -ra $(ARCHIVE)/$(GITREPONMP).git $(BUILD_TMP)/neutrino-mp; \
	cp -ra $(BUILD_TMP)/neutrino-mp $(BUILD_TMP)/neutrino-mp.org
	for i in $(N_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(N_SRC) && patch -p1 -i $$i; \
	done;
