TARGET = iphone:clang:14.5:14.0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HDangDynamic

HDangDynamic_FILES = Tweak.xm
HDangDynamic_CFLAGS = -fobjc-arc
HDangDynamic_FRAMEWORKS = UIKit AudioToolbox MediaPlayer AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
