N_CONFIG_OPTS += \
	--with-libdir=$(DEST)/lib \
	--with-datadir=$(DEST)/share/tuxbox \
	--with-fontdir=$(DEST)/share/fonts \
	--with-fontdir_var=$(DEST)/var/tuxbox/fonts \
	--with-configdir=$(DEST)/var/tuxbox/config \
	--with-gamesdir=$(DEST)/var/tuxbox/games \
	--with-iconsdir=$(DEST)/share/tuxbox/neutrino/icons \
	--with-iconsdir_var=$(DEST)/var/tuxbox/icons \
	--with-localedir=$(DEST)/share/tuxbox/neutrino/locale \
	--with-localedir_var=$(DEST)/var/tuxbox/locale \
	--with-plugindir=$(DEST)/share/tuxbox/neutrino/plugins \
	--with-plugindir_var=$(DEST)/var/tuxbox/plugins \
	--with-lcd4liconsdir_var=$(DEST)/var/tuxbox/lcd/icons \
	--with-luaplugindir=$(DEST)/var/tuxbox/plugins \
	--with-public_httpddir=$(DEST)/var/tuxbox/httpd \
	--with-private_httpddir=$(DEST)/share/tuxbox/neutrino/httpd \
	--with-themesdir=$(DEST)/share/tuxbox/neutrino/themes \
	--with-themesdir_var=$(DEST)/var/tuxbox/themes \
	--with-webtvdir=$(DEST)/share/tuxbox/neutrino/webtv \
	--with-webtvdir_var=$(DEST)/var/tuxbox/webtv \
	--with-webradiodir=$(DEST)/share/tuxbox/neutrino/webradio \
	--with-webradiodir_var=$(DEST)/var/tuxbox/webradio \
	--with-controldir=$(DEST)/share/tuxbox/neutrino/control \
	--with-controldir_var=$(DEST)/var/tuxbox/control


ifeq ($(FLAVOUR), MAX)
GIT_URL     ?= $(GITHUB)/MaxWiesel
NEUTRINO     = neutrino-max
LIBSTB_HAL   = libstb-hal-max
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_MAX_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_MAX_PATCHES)
else ifeq  ($(FLAVOUR), NI)
GIT_URL     ?= $(GITHUB)/neutrino-images
NEUTRINO     = ni-neutrino
LIBSTB_HAL   = ni-libstb-hal
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = neutrino-ni-exit-codes.patch
NMP_PATCHES += $(NEUTRINO_NI_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_NI_PATCHES)
else ifeq  ($(FLAVOUR), TANGOS)
GIT_URL     ?= $(GITHUB)/TangoCash
NEUTRINO     = neutrino-tangos
LIBSTB_HAL   = libstb-hal-tangos
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_TANGOS_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_TANGOS_PATCHES)
else ifeq  ($(FLAVOUR), TANGOSSKINNED)
GIT_URL     ?= $(GITHUB)/TangoCash
NEUTRINO     = neutrino-tangos
LIBSTB_HAL   = libstb-hal-tangos
NMP_BRANCH  ?= skinned
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_TANGOS_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_TANGOS_PATCHES)
else ifeq  ($(FLAVOUR), TANGOSEVO)
GIT_URL     ?= $(GITHUB)/TangoCash
NEUTRINO     = neutrino-tangos
NMP_BRANCH  ?= evo
NMP_PATCHES  = neutrino-tangos-ffmpeg.patch
NMP_PATCHES += $(NEUTRINO_TANGOS_PATCHES)
else ifeq  ($(FLAVOUR), DDT)
GIT_URL     ?= $(GITHUB)/Duckbox-Developers
NEUTRINO     = neutrino-ddt
LIBSTB_HAL   = libstb-hal-ddt
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = neutrino-ddt-plugindir-fix.patch
NMP_PATCHES  = $(NEUTRINO_DDT_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_DDT_PATCHES)
else ifeq  ($(FLAVOUR), TUXBOX)
GIT_URL     ?= $(GITHUB)/tuxbox-neutrino
NEUTRINO     = gui-neutrino
LIBSTB_HAL   = library-stb-hal
NMP_BRANCH  ?= master
HAL_BRANCH  ?= mpx
NMP_PATCHES  = $(NEUTRINO_TUX_PATCHES)
HAL_PATCHES  = $(LIBSTB_HAL_TUX_PATCHES)
HAL_PATCHES += $(PATCHES)/libstb-hal.demux.diff
endif

ifneq  ($(FLAVOUR), TANGOSEVO)
LIBDEP = $(D)/libstb-hal
endif

# -----------------------------------------------------------------------------
.version: $(DEST)/.version
$(DEST)/.version:
	echo "distro=$(FLAVOUR)" > $@
	echo "imagename=`sed -n 's/\#define PACKAGE_NAME "//p' $(N_OBJDIR)/config.h | sed 's/"//'`" >> $@
#	echo "imageversion=`sed -n 's/\#define PACKAGE_VERSION "//p' $(N_OBJDIR)/config.h | sed 's/"//'`" >> $@
	echo "imageversion=rev$(shell expr $(BUILDSYSTEM_REV) + $(LIBSTB_HAL_REV) + $(NEUTRINO_REV))" >> $@
	echo "homepage=$(GIT_URL)" >> $@
	echo "creator=$(MAINTAINER)" >> $@
	echo "docs=$(GIT_URL)" >> $@
	echo "forum=$(GIT_URL)/$(NEUTRINO)" >> $@
	echo "version=0200`date +%Y%m%d%H%M`" >> $@
	echo "builddate="`date` >> $@
	echo "git=BS-rev$(BUILDSYSTEM_REV)_HAL-rev$(LIBSTB_HAL_REV)_$(FLAVOUR)-rev$(NEUTRINO_REV)" >> $@
	echo "imagedir=$(BOXTYPE)" >> $@

version.h: $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
$(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h:
	@rm -f $@
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(SOURCE_DIR)/$(LIBSTB_HAL); then \
		echo '#define VCS "BS-rev$(BUILDSYSTEM_REV)_HAL-rev$(LIBSTB_HAL_REV)_$(FLAVOUR)-rev$(NEUTRINO_REV)"' >> $@; \
	fi
	if [ "$(FLAVOUR)" = "HD2" ]; then \
		echo '#define GIT "$(BUILDSYSTEM_REV)"' >> $@; \
	fi

# -----------------------------------------------------------------------------

$(D)/libstb-hal.do_prepare: | $(LIBSTB_HAL_DEPS)
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL)
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).org
	rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).dev
	rm -rf $(LH_OBJDIR)
	test -d $(SOURCE_DIR) || mkdir -p $(SOURCE_DIR)
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] && \
	(cd $(ARCHIVE)/$(LIBSTB_HAL).git; git pull;); \
	[ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ] || \
	git clone $(GIT_URL)/$(LIBSTB_HAL).git $(ARCHIVE)/$(LIBSTB_HAL).git; \
	cp -ra $(ARCHIVE)/$(LIBSTB_HAL).git $(SOURCE_DIR)/$(LIBSTB_HAL);\
	(cd $(SOURCE_DIR)/$(LIBSTB_HAL); git checkout $(HAL_BRANCH);); \
	cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).org
	set -e; cd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		$(call apply_patches, $(HAL_PATCHES))
	cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).dev
	@touch $@

$(D)/libstb-hal.config.status:
	rm -rf $(LH_OBJDIR)
	test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	cd $(LH_OBJDIR); \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/configure $(SILENT_OPT) \
			--prefix=$(DEST) \
			--enable-maintainer-mode \
			--enable-shared=no \
			\
			$(LH_CONFIG_OPTS)
#	@touch $@

$(D)/libstb-hal.do_compile: $(D)/libstb-hal.config.status
	$(MAKE) -C $(LH_OBJDIR)
	@touch $@

$(D)/libstb-hal: $(D)/libstb-hal.do_prepare $(D)/libstb-hal.do_compile
	$(MAKE) -C $(LH_OBJDIR) install
	$(TOUCH)

libstb-hal-clean:
	rm -f $(D)/libstb-hal
	rm -f $(D)/libstb-hal.config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-distclean:
	rm -rf $(LH_OBJDIR)
	rm -f $(D)/libstb-hal
	rm -f $(D)/libstb-hal.do_*
	rm -f $(D)/libstb-hal.config.status

# -----------------------------------------------------------------------------

$(D)/neutrino.do_prepare: | bootstrap $(D)/libdvbsipp $(D)/lua $(D)/graphlcd $(D)/ffmpeg $(LIBDEP)
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO)
	rm -rf $(SOURCE_DIR)/$(NEUTRINO).org
	rm -rf $(SOURCE_DIR)/$(NEUTRINO).dev
	rm -rf $(N_OBJDIR)
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] && \
	(cd $(ARCHIVE)/$(NEUTRINO).git; git pull;); \
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] || \
	git clone $(GIT_URL)/$(NEUTRINO).git $(ARCHIVE)/$(NEUTRINO).git; \
	cp -ra $(ARCHIVE)/$(NEUTRINO).git $(SOURCE_DIR)/$(NEUTRINO); \
	(cd $(SOURCE_DIR)/$(NEUTRINO); git checkout $(NMP_BRANCH);); \
	cp -ra $(SOURCE_DIR)/$(NEUTRINO) $(SOURCE_DIR)/$(NEUTRINO).org
	set -e; cd $(SOURCE_DIR)/$(NEUTRINO); \
		$(call apply_patches, $(NMP_PATCHES))
	cp -ra $(SOURCE_DIR)/$(NEUTRINO) $(SOURCE_DIR)/$(NEUTRINO).dev
	@touch $@

$(D)/neutrino.config.status:
	rm -rf $(N_OBJDIR)
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/$(NEUTRINO)/autogen.sh; \
		CC="ccache gcc" CXX="ccache g++" \
		$(SOURCE_DIR)/$(NEUTRINO)/configure \
			--prefix=$(DEST) \
			--enable-silent-rules --enable-mdev \
			--enable-giflib \
			--enable-cleanup \
			--enable-lua \
			--enable-ffmpegdec \
			--enable-testing \
			--enable-fribidi \
			--enable-lcd4linux \
			--enable-graphlcd \
			--disable-upnp \
			--enable-reschange \
			--enable-python \
			$(N_CONFIG_OPTS) \
			--with-default-theme=TangoCash \
			--with-target=native --with-boxtype=$(BOXTYPE) \
			--with-stb-hal-includes=$(SOURCE_DIR)/$(LIBSTB_HAL)/include \
			--with-stb-hal-build=$(LH_OBJDIR)
		+make $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
#	@touch $@

$(D)/neutrino.do_compile: $(D)/neutrino.config.status
	$(MAKE) -C $(N_OBJDIR) all
	@touch $@

neutrino \
$(D)/neutrino: $(D)/neutrino.do_prepare $(D)/neutrino.do_compile
	$(MAKE) -C $(N_OBJDIR) install
	make .version
	find $(DEST)/../own_build/ -mindepth 1 -maxdepth 1 -exec cp -at$(DEST)/ -- {} +
	$(FINISH_BUILD)

neutrino-clean:
	rm -f $(D)/neutrino
	rm -f $(D)/neutrino.config.status
	rm -f $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-distclean:
	rm -rf $(N_OBJDIR)
	rm -f $(D)/neutrino
	rm -f $(D)/neutrino.do_*
	rm -f $(D)/neutrino.config.status
