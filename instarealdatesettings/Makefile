include theos/makefiles/common.mk

BUNDLE_NAME = instarealdatesettings
instarealdatesettings_FILES = instarealdatesettings.mm
instarealdatesettings_INSTALL_PATH = /Library/PreferenceBundles
instarealdatesettings_FRAMEWORKS = UIKit
instarealdatesettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/instarealdatesettings.plist$(ECHO_END)
