include theos/makefiles/common.mk

export ARCHS = armv7 arm64
TWEAK_NAME = InstaRealDate
InstaRealDate_FILES = Tweak.xm
InstaRealDate_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Instagram"
SUBPROJECTS += instarealdatesettings
include $(THEOS_MAKE_PATH)/aggregate.mk
