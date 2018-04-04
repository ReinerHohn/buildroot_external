################################################################################
#
# pigpio
#
################################################################################

LIBPIGPIO_VERSION = 1
LIBPIGPIO_SOURCE = pigpio.tar
LIBPIGPIO_SITE = abyz.me.uk/rpi/pigpio
LIBFOO_SITE_METHOD = wget
LIBPIGPIO_LICENSE = None
LIBPIGPIO_LICENSE_FILES = UNLICENCE
LIBPIGPIO_INSTALL_STAGING = YES

define LIBPIGPIO_EXTRACT_CMDS
	$(TAR) xf $(DL_DIR)/$(LIBPIGPIO_SOURCE) -C $(@D)
endef

define LIBPIGPIO_BUILD_CMDS
	$(MAKE) CROSS_PREFIX="$(TARGET_CROSS)" -C $(@D)/PIGPIO
endef

define LIBPIGPIO_INSTALL_STAGING_CMDS
        $(MAKE) -C $(@D)/PIGPIO DESTDIR=$(STAGING_DIR) install LDCONFIG=true
endef

define LIBPIGPIO_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D)/PIGPIO DESTDIR=$(TARGET_DIR) install LDCONFIG=true
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
