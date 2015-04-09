#import <Preferences/Preferences.h>

@interface instarealdatesettingsListController: PSListController {
}
@end

@implementation instarealdatesettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"instarealdatesettings" target:self] retain];
	}
	return _specifiers;
}
#define tweakPreferencePath @"/User/Library/Preferences/org.thebigboss.instarealdatesettings.plist"
//taken from http://iphonedevwiki.net/index.php/PreferenceBundles
-(id) readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath];
	if (!tweakSettings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return tweakSettings[specifier.properties[@"key"]];
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:tweakPreferencePath atomically:YES];
	//NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath];
	CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
	if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

-(void)showMyTwitter:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/rye761"]];
}
@end

// vim:ft=objc
