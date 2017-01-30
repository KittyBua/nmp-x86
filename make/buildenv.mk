START_BUILD           = @echo "=============================================================="; echo; echo -e " $(TERM_BOLD) Start build of $(subst $(BASE_DIR)/.deps/,,$@). $(TERM_RESET)"
FINISH_BUILD          = @echo "=============================================================="; echo; echo -e " $(TERM_BOLD) Finish build of $(subst $(BASE_DIR)/.deps/,,$@). $(TERM_RESET)"
TERM_BOLD            := $(shell tput smso 2>/dev/null)
TERM_RESET           := $(shell tput rmso 2>/dev/null)
PATCH                 = patch -p1 -i $(PATCHES)
APATCH                = patch -p1 -i

define post_patch
	set -e; cd $(1); \
	for i in $(2); do \
		if [ -d $$i ] ; then \
			for p in $$i/*; do \
				if [ $${p:0:1} == "/" ]; then \
					echo -e "==> \033[31mApplying Patch:\033[0m $$p"; $(APATCH) $$p; \
				else \
					echo -e "==> \033[31mApplying Patch:\033[0m $$p"; $(PATCH)/$$p; \
				fi; \
			done; \
		else \
			if [ $${i:0:1} == "/" ]; then \
				echo -e "==> \033[31mApplying Patch:\033[0m $$i"; $(APATCH) $$i; \
			else \
				echo -e "==> \033[31mApplying Patch:\033[0m $$i"; $(PATCH)/$$i; \
			fi; \
		fi; \
	done; \
	echo -e "Patch of \033[01;32m$(subst $(BASE_DIR)/.deps/,,$@)\033[0m completed."; \
	echo
endef
