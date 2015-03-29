# 
FFMPEG_VER=2.1.4
LUA_VER=5.2.3
LUAPOSIX_VER=31
LIBDVBSI_VER=0.3.7
LIBSIGC_VER=2.3.2
#
#
#
$(SOURCE):
	mkdir -p $@
#
#
# ffmpeg
$(SOURCE)/ffmpeg-$(FFMPEG_VER).tar.bz2: | $(SOURCE)
	cd $(SOURCE) && wget http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG_VER).tar.bz2

# luaposix: posix bindings for lua
$(SOURCE)/luaposix-v$(LUAPOSIX_VER).tar.gz: | $(SOURCE)
	cd $(SOURCE) && wget https://github.com/luaposix/luaposix/archive/v$(LUAPOSIX_VER).tar.gz -O $@

# lua: easily embeddable scripting language
$(SOURCE)/lua-$(LUA_VER).tar.gz: | $(SOURCE)
	cd $(SOURCE) && wget http://www.lua.org/ftp/lua-$(LUA_VER).tar.gz

# libdvbsi
$(SOURCE)/libdvbsi++-$(LIBDVBSI_VER).tar.bz2: | $(SOURCE)
	cd $(SOURCE) && wget http://www.saftware.de/libdvbsi++/libdvbsi++-$(LIBDVBSI_VER).tar.bz2

# libsigc
$(SOURCE)/libsigc++-$(LIBSIGC_VER).tar.xz: | $(SOURCE)
	cd $(SOURCE) && wget http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.3/libsigc++-$(LIBSIGC_VER).tar.xz

$(LH_SRC): | $(SOURCE)
	cd $(SOURCE) && git clone https://github.com/Duckbox-Developers/libstb-hal-cst-next.git libstb-hal
	rm -rf $(SOURCE)/libstb-hal.org
	cp -ra $(SOURCE)/libstb-hal $(SOURCE)/libstb-hal.org
	for i in $(LH_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(LH_SRC) && patch -p1 -i $$i; \
	done;


$(N_SRC): | $(SOURCE)
	cd $(SOURCE) && git clone https://github.com/TangoCash/neutrino-mp-cst-next.git neutrino-mp
	rm -rf $(SOURCE)/neutrino-mp.org
	cp -ra $(SOURCE)/neutrino-mp $(SOURCE)/neutrino-mp.org
	for i in $(N_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(N_SRC) && patch -p1 -i $$i; \
	done;

checkout: $(LH_SRC) $(N_SRC)
	rm -rf $(OBJ)

update: 
	cd $(LH_SRC).org && git pull
	rm -rf $(LH_SRC)
	cp -ra $(LH_SRC).org $(LH_SRC)
	for i in $(LH_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(LH_SRC) && patch -p1 -i $$i; \
	done;
	cd $(N_SRC).org && git pull
	rm -rf $(N_SRC)
	cp -ra $(N_SRC).org $(N_SRC)
	for i in $(N_PATCHES); do \
		echo "==> Applying Patch: $(subst $(PATCHES)/,'',$$i)"; \
		cd $(N_SRC) && patch -p1 -i $$i; \
	done;
	rm -rf $(OBJ)


