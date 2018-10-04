# 
FFMPEG_VER=4.0.2
LUA_VER=5.2.4
LUAPOSIX_VER=31
LIBDVBSI_VER=0.3.8
LIBSIGC_VER_MAJ=2.3
LIBSIGC_VER_MIN=2
LIBSIGC_VER=$(LIBSIGC_VER_MAJ).$(LIBSIGC_VER_MIN)

ifeq ($(FLAVOUR), classic)
GITNAMENMP=Duckbox-Developers
GITREPONMP=neutrino-mp-ddt
GITBRANCHNMP=master
GITNAMESTBHAL=Duckbox-Developers
GITREPOSTBHAL=libstb-hal-ddt
N_PATCHES += $(MP_PATCHES)
else
ifeq ($(FLAVOUR), franken)
GITNAMENMP=fs-basis
GITREPONMP=neutrino-mp-fs
GITBRANCHNMP=master
GITNAMESTBHAL=fs-basis
GITREPOSTBHAL=libstb-hal-fs
N_PATCHES += $(FS_PATCHES)
else
ifeq ($(FLAVOUR), tuxbox)
GITNAMENMP=tuxbox-neutrino
GITREPONMP=gui-neutrino
GITBRANCHNMP=pu/mp
GITNAMESTBHAL=tuxbox-neutrino
GITREPOSTBHAL=library-stb-hal
N_PATCHES += $(TB_PATCHES)
LH_PATCHES += $(PATCHES)/libstb-hal.demux.diff
LH_PATCHES += $(PATCHES)/libstb-hal.ffmpeg.diff

else
ifeq ($(FLAVOUR), vanilla)
GITNAMENMP=neutrino-mp
GITREPONMP=neutrino-mp
GITBRANCHNMP=master
GITNAMESTBHAL=neutrino-mp
GITREPOSTBHAL=libstb-hal
N_PATCHES += $(PATCHES)/neutrino-mp.unicable2-jess.diff
N_PATCHES += $(VA_PATCHES)
LH_PATCHES += $(PATCHES)/libstb-hal.demux.diff
LH_PATCHES += $(PATCHES)/libstb-hal.ffmpeg.diff
else
GITNAMENMP=TangoCash
GITREPONMP=neutrino-mp-tangos
GITBRANCHNMP=master
GITNAMESTBHAL=TangoCash
GITREPOSTBHAL=libstb-hal-tangos
N_PATCHES += $(TG_PATCHES)
endif
endif
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
	$(START_BUILD)
	[ -d "$(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git" ] && \
	(cd $(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git" ] || \
	$(GITCLONE)/$(GITNAMESTBHAL)/$(GITREPOSTBHAL).git $(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git; \
	cp -ra $(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git $(BUILD_TMP)/libstb-hal;\
	cp -ra $(BUILD_TMP)/libstb-hal $(BUILD_TMP)/libstb-hal.org
	$(call post_patch,$(LH_SRC),$(LH_PATCHES))
	$(FINISH_BUILD)

# neutrino mp
$(N_SRC):
	$(START_BUILD)
	[ -d "$(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git" ] && \
	(cd $(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git; git pull; cd "$(BASE_DIR)";); \
	[ -d "$(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git" ] || \
	$(GITCLONE)/$(GITNAMENMP)/$(GITREPONMP).git $(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git; \
	cp -ra $(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git $(BUILD_TMP)/neutrino-mp; \
	(cd $(BUILD_TMP)/neutrino-mp; git checkout $(GITBRANCHNMP);); \
	$(call post_patch,$(N_SRC),$(N_PATCHES))
	cp -ra $(BUILD_TMP)/neutrino-mp $(BUILD_TMP)/neutrino-mp.org
	$(FINISH_BUILD)

