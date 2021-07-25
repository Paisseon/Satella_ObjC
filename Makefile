SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk/
ARCHS = arm64 arm64e
TARGET = iphone:clang:14.4:13.0

FINALPACKAGE = 1
DEBUG = 0

INSTALL_TARGET_PROCESSES = SpringBoard
TWEAK_NAME = Satella
$(TWEAK_NAME)_FILES = $(TWEAK_NAME).x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-error=deprecated-declarations
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = AltList UIKit

SUBPROJECTS += Prefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk
