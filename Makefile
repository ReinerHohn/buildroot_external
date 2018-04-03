export BR2_EXTERNAL:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
export BR2_DL_DIR:=$(BR2_EXTERNAL)/dl
export BR2_CCACHE_DIR:=$(BR2_EXTERNAL)/ccache
export BR2_OUTPUT_DIR:=$(abspath $(BR2_EXTERNAL)/../output/)

all: main
	echo "all"

main: main.o
	echo "main"

main.c : de	

output/.br_stamp_patched: buildroot/support/scripts/apply-patches.sh output
	git checkout buildroot
	git clean -d -f -x	
	# First prequsity: apply-patches.sh
	$< buildroot br_patches
	touch $@
	

output/%/.config: output/.br_stamp_patched
	$(MAKE) O=$(BR2_OUTPUT_DIR)/$* -C buildroot  $*_defconfig




rpi: 
	mkdir  -p $(BR2_OUTPUT_DIR)/rpi

%-clean:	
	rm -r $(BR2_OUTPUT_DIR)/$*

rpi_init: $(BR2_OUTPUT_DIR)/rpi_init

$(BR2_OUTPUT_DIR)/%:
	mkdir $@

de:
	touch main.c
