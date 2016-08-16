#=====================================
# OpenWrt Makefile
#=====================================

include $(TOPDIR)/rules.mk

PKG_NAME:=enlogic
PKG_VERSION:=1
PKG_RELEASE:=12
PKG_BUILD_DIR:= $(BUILD_DIR)/$(PKG_NAME)
PKG_MAINTAINER:=www.smart-grid.ru
PKGPP:=/usr/share
PKGPE:=$(PKGPP)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

#TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
#TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib -L/home/openwrt/openwrt/trunk/staging_dir/toolchain-arm_arm926ej-s_gcc-4.8-linaro_musl-1.1.11_eabi/lib

define Package/enlogic
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=enlogic
	DEPENDS:=+zlib +libpthread +libc
endef

define Package/enlogic/description
	enlogic - platform for microprocessor controllers programming 
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
	#mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./usr/* $(PKG_BUILD_DIR)/
#	$(CP) ./init.d/* $(PKG_BUILD_DIR)/
endef


define Build/Compile
endef

define Package/enlogic/install
	$(INSTALL_DIR) $(1)/$(PKGPE)
#	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libz.so $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libc.so $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/enlogic $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/start $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cfgxml $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/config.bin $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uspd.cfg $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/enlogic-drv $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/enlogic.cfg $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cfgxml $(1)/$(PKGPE)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/config.bin $(1)/$(PKGPE)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/enlogic.sh.init $(1)/etc/init.d/enlogic.sh
endef

$(eval $(call BuildPackage,enlogic))
