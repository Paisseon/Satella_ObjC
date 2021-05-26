ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
SYSROOT = $(THEOS)/sdks/iPhoneOS13.3.sdk/

INSTALL_TARGET_PROCESSES = SpringBoard
TWEAK_NAME = Satella
Satella_FILES = Satella.x
Satella_CFLAGS = -fobjc-arc
Satella_EXTRA_FRAMEWORKS = AltList

SUBPROJECTS += Prefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk
