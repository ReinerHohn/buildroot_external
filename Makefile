export BR2_EXTERNAL:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
export BR2_DL_DIR:=$(BR2_EXTERNAL)/dl
export BR2_CCACHE_DIR:=$(BR2_EXTERNAL)/ccache
export BR2_OUTPUT_DIR:=$(abspath $(BR2_EXTERNAL)/../output/)

all: rpi rpi_init
	echo "all"

output/.br_stamp_patched: buildroot/support/scripts/apply-patches.sh output
	git checkout buildroot
	git clean -d -f	
	# '$<' First prequsity: apply-patches.sh
	$< buildroot br_patches
	touch $@

output:
	mkdir $@	

output/%/.config: output/.br_stamp_patched
	$(MAKE) O=../$(dir $@).. -C buildroot  $*_defconfig

output/%_toolchain/images/toolchain.tar.gz: output/%_toolchain/.config
	$(MAKE) -C $(subst images,,$(dir $@))
	tar -C $(dir $<)host -f $@ -lcpz usr

output/%/images/sysroot.tar.gz: output/%/.config
	$(MAKE) -C $(subst images,, $(dir $<))
	tar -C $(dir $<)staging -f $@  -lcpz lib usr/lib usr/include

# $* stem, with which implicit rule matches
define PASS_TEMPLATE
$(1)-%: output/$(1)/.config
	echo "Pass template"
	$(MAKE) -C output/$(1)/ $$*
endef


define SAVE_TEMPLATE
$(1)-savedefconfig: output/$(1)/.config
	$(MAKE) -C output/$(1)/ savedefconfig BR2_DEFCONFIG=$(BR2_EXTERNAL)/configs/$(1)_defconfig
endef

define COMPILE_TEMPLATE
$(addsuffix /images/sysroot.tar.gz,$(addprefix output/, $(2))): output/$(3)/images/toolchain.tar.gz output/.br_stamp_patched
$(1): $(addsuffix /images/sysroot.tar.gz,$(addprefix output/, $(2)))
$(foreach tgt, $(2), $(eval $(call PASS_TEMPLATE,$(tgt))))
$(foreach tgt, $(3), $(eval $(call PASS_TEMPLATE,$(tgt))))
$(foreach tgt, $(2), $(eval $(call SAVE_TEMPLATE,$(tgt))))
$(foreach tgt, $(3), $(eval $(call SAVE_TEMPLATE,$(tgt))))
endef

$(eval $(call COMPILE_TEMPLATE,rpi,rpi,arm_a53_toolchain))


rpi: 
	mkdir  -p $(BR2_OUTPUT_DIR)/rpi

%-clean:	
	rm -r $(BR2_OUTPUT_DIR)/$*

rpi_init: $(BR2_OUTPUT_DIR)/rpi_init

$(BR2_OUTPUT_DIR)/%:
	mkdir $@

de:
	touch main.c
