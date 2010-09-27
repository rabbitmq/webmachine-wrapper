DEPS:=mochiweb

ifdef PACKAGE_DIR
UPSTREAM_HG:=http://bitbucket.org/justin/webmachine
REVISION:=0c4b60ac68b4

EBIN_DIR:=$(PACKAGE_DIR)/ebin
CHECKOUT_DIR:=$(PACKAGE_DIR)/webmachine-hg
SOURCE_DIR:=$(CHECKOUT_DIR)/src
INCLUDE_DIR:=$(CHECKOUT_DIR)/include

ERLC_OPTS:=-I $(CHECKOUT_DIR)

$(CHECKOUT_DIR)_UPSTREAM_HG:=$(UPSTREAM_HG)
$(CHECKOUT_DIR)_REVISION:=$(REVISION)
$(CHECKOUT_DIR):
	hg clone -r $($@_REVISION) $($@_UPSTREAM_HG) $@

$(CHECKOUT_DIR)/stamp: | $(CHECKOUT_DIR)
	rm -f $@
	cd $(@D) && echo COMMIT_SHORT_HASH:=$$(hg id -i | cut -c -7) >> $@

.PHONY: $(EBIN_DIR)/webmachine.app
$(EBIN_DIR)/webmachine.app: $(CHECKOUT_DIR)/ebin/webmachine.app | $(EBIN_DIR)
	sed -e 's/{vsn, *\"[^\"]\+\"/{vsn,\"$($@_VERSION)\"/' < $< > $@

$(PACKAGE_DIR)/clean_RM:=$(CHECKOUT_DIR) $(CHECKOUT_DIR)/stamp $(EBIN_DIR)/webmachine.app
$(PACKAGE_DIR)/clean::
	rm -rf $($@_RM)

ifneq "$(strip $(patsubst clean%,,$(patsubst %clean,,$(TESTABLEGOALS))))" ""
include $(CHECKOUT_DIR)/stamp

VERSION:=rmq$(GLOBAL_VERSION)-hg$(COMMIT_SHORT_HASH)
$(EBIN_DIR)/webmachine.app_VERSION:=$(VERSION)
endif
endif

include ../include.mk
