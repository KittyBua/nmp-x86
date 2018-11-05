# 
FFMPEG_VER=4.0.2
LUA_VER=5.2.4
LUAPOSIX_VER=31
LIBDVBSI_VER=ff57e58

GITBRANCHNMP=master
GITBRANCHSTBHAL=master

ifeq ($(FLAVOUR), classic)
GIT_URL=https://github.com
GITNAMENMP=Duckbox-Developers
GITREPONMP=neutrino-mp-ddt
GITNAMESTBHAL=Duckbox-Developers
GITREPOSTBHAL=libstb-hal-ddt
N_PATCHES += $(MP_PATCHES)
else
ifeq ($(FLAVOUR), max)
GIT_URL=https://bitbucket.org
GITNAMENMP=max_10
GITREPONMP=neutrino-mp-max
GITNAMESTBHAL=max_10
GITREPOSTBHAL=libstb-hal-max
N_PATCHES += $(MAX_PATCHES)
else
ifeq  ($(FLAVOUR), ni)
GIT_URL=https://bitbucket.org
GITNAMENMP=neutrino-images
GITREPONMP=ni-neutrino-hd
GITBRANCHNMP=ni/mp/tuxbox
GITNAMESTBHAL=neutrino-images
GITREPOSTBHAL=ni-libstb-hal-next
else
ifeq ($(FLAVOUR), franken)
GIT_URL=https://github.com
GITNAMENMP=fs-basis
GITREPONMP=neutrino-mp-fs
GITNAMESTBHAL=fs-basis
GITREPOSTBHAL=libstb-hal-fs
N_PATCHES += $(FS_PATCHES)
else
ifeq ($(FLAVOUR), tuxbox)
GIT_URL=https://github.com
GITNAMENMP=tuxbox-neutrino
GITREPONMP=gui-neutrino
GITNAMESTBHAL=tuxbox-neutrino
GITREPOSTBHAL=library-stb-hal
GITBRANCHSTBHAL=mpx
#GITBRANCHNMP=pu/mp
#N_PATCHES += $(PATCHES)/neutrino-mp.tuxbox.diff
N_PATCHES += $(TB_PATCHES)
LH_PATCHES += $(PATCHES)/libstb-hal.demux.diff
else
ifeq ($(FLAVOUR), vanilla)
GIT_URL=https://github.com
GITNAMENMP=neutrino-mp
GITREPONMP=neutrino-mp
GITNAMESTBHAL=neutrino-mp
GITREPOSTBHAL=libstb-hal
N_PATCHES += $(PATCHES)/neutrino-mp.unicable2-jess.diff
N_PATCHES += $(VA_PATCHES)
LH_PATCHES += $(PATCHES)/libstb-hal.demux.diff
LH_PATCHES += $(PATCHES)/libstb-hal.ffmpeg.diff
else
ifeq ($(FLAVOUR), skinned)
GIT_URL=https://github.com
GITNAMENMP=TangoCash
GITREPONMP=neutrino-mp-tangos
GITBRANCHNMP=skinned
GITNAMESTBHAL=TangoCash
GITREPOSTBHAL=libstb-hal-tangos
N_PATCHES += $(TG_PATCHES)
else
GIT_URL=https://github.com
GITNAMENMP=TangoCash
GITREPONMP=neutrino-mp-tangos
GITNAMESTBHAL=TangoCash
GITREPOSTBHAL=libstb-hal-tangos
N_PATCHES += $(TG_PATCHES)
endif
endif
endif
endif
endif
endif
endif

GITCLONE_NMP=git clone -b $(GITBRANCHNMP) $(GIT_URL)
GITCLONE_STBHAL=git clone -b $(GITBRANCHSTBHAL) $(GIT_URL)

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
$(ARCHIVE)/libdvbsi-git-$(LIBDVBSI_VER).tar.bz2:
	$(SCRIPTS)/get-git-archive.sh git://git.opendreambox.org/git/obi/libdvbsi++.git $(LIBDVBSI_VER) $(notdir $@) $(ARCHIVE)

# stb-hal
$(LH_SRC):
	$(START_BUILD)
	[ -d "$(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git" ] && \
	(cd $(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git; git pull; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git" ] || \
	$(GITCLONE_STBHAL)/$(GITNAMESTBHAL)/$(GITREPOSTBHAL).git $(ARCHIVE)/$(GITNAMESTBHAL)-$(GITREPOSTBHAL).git; \
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
	$(GITCLONE_NMP)/$(GITNAMENMP)/$(GITREPONMP).git $(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git; \
	cp -ra $(ARCHIVE)/$(GITNAMENMP)-$(GITREPONMP).git $(BUILD_TMP)/neutrino-mp; \
	(cd $(BUILD_TMP)/neutrino-mp; git checkout $(GITBRANCHNMP);); \
	$(call post_patch,$(N_SRC),$(N_PATCHES))
	cp -ra $(BUILD_TMP)/neutrino-mp $(BUILD_TMP)/neutrino-mp.org
	$(FINISH_BUILD)

