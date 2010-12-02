DEPS:=mochiweb-wrapper
APP_NAME:=webmachine

UPSTREAM_HG:=http://bitbucket.org/justin/webmachine
REVISION:=0c4b60ac68b4

CHECKOUT_DIR:=$(PACKAGE_DIR)/$(APP_NAME)-hg
SOURCE_DIR:=$(CHECKOUT_DIR)/src
INCLUDE_DIR:=$(CHECKOUT_DIR)/include

ERLC_OPTS:=-I $(CHECKOUT_DIR)

$(eval $(call safe_include,$(PACKAGE_DIR)/version.mk))

VERSION:=rmq$(GLOBAL_VERSION)-hg$(COMMIT_SHORT_HASH)

define package_targets

$(CHECKOUT_DIR)/.done:
	rm -rf $(CHECKOUT_DIR)
	hg clone -r $(REVISION) $(UPSTREAM_HG) $(CHECKOUT_DIR)
	patch -d $(CHECKOUT_DIR) -p1 <$(PACKAGE_DIR)/uneunit.patch
	touch $$@

$(PACKAGE_DIR)/version.mk: $(CHECKOUT_DIR)/.done
	echo COMMIT_SHORT_HASH:=`hg id -R $(CHECKOUT_DIR) -i | cut -c -7` >$$@

$(EBIN_DIR)/$(APP_NAME).app: $(CHECKOUT_DIR)/ebin/$(APP_NAME).app $(PACKAGE_DIR)/version.mk
	@mkdir -p $$(@D)
	sed -e 's|{vsn, *\"[^\"]*\"|{vsn,\"$(VERSION)\"|' <$$< >$$@

$(PACKAGE_DIR)+clean::
	rm -rf $(CHECKOUT_DIR) $(EBIN_DIR)/$(APP_NAME).app $(PACKAGE_DIR)/version.mk

endef
