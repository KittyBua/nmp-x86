# 
FFMPEG_VER=2.5
LUA_VER=5.2.3
LUAPOSIX_VER=31
LIBDVBSI_VER=0.3.7
LIBSIGC_VER_MAJ=2.3
LIBSIGC_VER_MIN=2
LIBSIGC_VER=$(LIBSIGC_VER_MAJ).$(LIBSIGC_VER_MIN)

ifeq ($(FLAVOUR), classic)
GITNAMENMP=Duckbox-Developers
GITREPONMP=neutrino-mp-cst-next
GITBRANCHNMP=master
GITNAMESTBHAL=Duckbox-Developers
GITREPOSTBHAL=libstb-hal-cst-next
N_PATCHES += $(MP_PATCHES)
else
ifeq ($(FLAVOUR), franken)
GITNAMENMP=fs-basis
GITREPONMP=neutrino-mp-cst-next
GITBRANCHNMP=test
GITNAMESTBHAL=Duckbox-Developers
GITREPOSTBHAL=libstb-hal-cst-next
N_PATCHES += $(FS_PATCHES)
else
GITNAMENMP=TangoCash
GITREPONMP=neutrino-mp-cst-next
GITBRANCHNMP=master
GITNAMESTBHAL=Duckbox-Developers
GITREPOSTBHAL=libstb-hal-cst-next
N_PATCHES += $(TG_PATCHES)
endif
endif

GITCLONE=git clone -b $(GITBRANCHNMP) git://github.com

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
	[ -d "$(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git" ] && \
	(cd $(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git; git pull; cd "$(BASE_DIR)";); \
	[ -d "$(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git" ] || \
	$(GITCLONE)/$(GITNAMENMP)/$(GITREPONMP).git $(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git; \
	cp -ra $(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git $(BUILD_TMP)/neutrino-mp; \
	for i in $(N_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(N_SRC) && patch -p1 -i $$i; \
	done; \
	cp -ra $(BUILD_TMP)/neutrino-mp $(BUILD_TMP)/neutrino-mp.org

