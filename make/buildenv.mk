START_BUILD           = @echo "=============================================================="; echo; echo -e " $(TERM_BOLD) Start build of $(subst $(BASE_DIR)/.deps/,,$@). $(TERM_RESET)"
FINISH_BUILD          = @echo "=============================================================="; echo; echo -e " $(TERM_BOLD) Finish build of $(subst $(BASE_DIR)/.deps/,,$@). $(TERM_RESET)"
TERM_BOLD            := $(shell tput smso 2>/dev/null)
TERM_RESET           := $(shell tput rmso 2>/dev/null)

GITHUB                = https://github.com

# Buildsystem Revision
BUILDSYSTEM_REV=$(shell cd $(BASE_DIR); git log | grep "^commit" | wc -l)
# Neutrino Revision
NEUTRINO_REV=$(shell cd $(SOURCE_DIR)/$(NEUTRINO); git log | grep "^commit" | wc -l)
# libstb-hal Revision
LIBSTB_HAL_REV=$(shell cd $(SOURCE_DIR)/$(LIBSTB_HAL); git log | grep "^commit" | wc -l)

# apply patch sets
PATCH  = patch -Np1 $(SILENT_PATCH) -i $(PATCHES)

define apply_patches
    l=`echo $(2)`; test -z $$l && l=1; \
    for i in $(1); do \
        if [ -d $$i ]; then \
            for p in $$i/*; do \
                if [ $${p:0:1} == "/" ]; then \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $${p##*/}"; patch -p$$l $(SILENT_PATCH) -i $$p; \
                else \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $${p##*/}"; patch -p$$l $(SILENT_PATCH) -i $(PATCHES)/$$p; \
                fi; \
            done; \
        else \
            if [ $${i:0:1} == "/" ]; then \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $${i##*/}"; patch -p$$l $(SILENT_PATCH) -i $$i; \
            else \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $${i##*/}"; patch -p$$l $(SILENT_PATCH) -i $(PATCHES)/$$i; \
            fi; \
        fi; \
    done; \
    if [ $(PKG_VER_HELPER) == "AA" ]; then \
        echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed"; \
    else \
        echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed"; \
    fi; \
    echo
endef

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino Max
NEUTRINO_MAX_PATCHES =
LIBSTB_HAL_MAX_PATCHES =

# Neutrino DDT
NEUTRINO_DDT_PATCHES =
LIBSTB_HAL_DDT_PATCHES =

# Neutrino NI
NEUTRINO_NI_PATCHES =
LIBSTB_HAL_NI_PATCHES =

# Neutrino Tango
NEUTRINO_TANGOS_PATCHES =
LIBSTB_HAL_TANGOS_PATCHES =

# Neutrino Tuxbox
NEUTRINO_TUX_PATCHES =
LIBSTB_HAL_TUX_PATCHES =
