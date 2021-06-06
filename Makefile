ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
SYSROOT = $(THEOS)/sdks/iPhoneOS13.3.sdk/

FINAL_RELEASE = 1
DEBUG = 0

INSTALL_TARGET_PROCESSES = SpringBoard
TWEAK_NAME = Satella
Satella_FILES = Satella.x
Satella_CFLAGS = -fobjc-arc -Wno-error=deprecated-declarations
Satella_EXTRA_FRAMEWORKS = AltList UIKit

SUBPROJECTS += Prefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk
