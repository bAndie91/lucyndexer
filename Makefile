
LIB_TARGET_DIR = /usr/share/lucyndexer
BIN_TARGET_DIR = /usr/bin


FILES = index-mails lucyndex lucynquire mkdoc

LIB_TARGET_FILES = $(foreach filename,$(FILES),$(LIB_TARGET_DIR)/$(filename))


install-all: $(LIB_TARGET_FILES) $(LIB_TARGET_DIR)/lib/ $(BIN_TARGET_DIR)/lucynquire


$(LIB_TARGET_DIR):
	mkdir -p $(LIB_TARGET_DIR)
	@echo remove $@ >> uninstall.sh

$(LIB_TARGET_FILES): | $(LIB_TARGET_DIR)

$(LIB_TARGET_FILES): $(LIB_TARGET_DIR)/%: %
	install $(notdir $@) $(LIB_TARGET_DIR)/
	@echo remove $@ >> uninstall.sh

$(LIB_TARGET_DIR)/lib: $(LIB_TARGET_DIR)
	rsync -r -tp -i ./lib/ $@/
	@echo remove $@ >> uninstall.sh

$(BIN_TARGET_DIR)/lucynquire: lucynquire.run
	@cat lucynquire.run | sed -e 's#LIB_TARGET_DIR=.#LIB_TARGET_DIR=$(LIB_TARGET_DIR)#' > $@
	@chmod +x $@
	@echo remove $@ >> uninstall.sh
