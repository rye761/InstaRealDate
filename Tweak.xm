#define pixelsPerLetter 5

@interface IGDate : NSObject
- (double) timeIntervalSince1970;
@end

@protocol IGFeedHeaderItem <NSObject>
@property(readonly, assign) IGDate *takenAt;
@end

@interface IGFeedItemHeader : UIView
@property (retain, nonatomic) UILabel *timestampLabel;
@property (retain, nonatomic) id<IGFeedHeaderItem> feedItem;
- (void) showFullDate;
@end

BOOL autoExpand;
BOOL showDateString;
BOOL showTimeString;
int dateLength;
unsigned int dateLengths[3] = {NSDateFormatterShortStyle, NSDateFormatterMediumStyle, NSDateFormatterLongStyle};
float widthAdjust;
unsigned int defaultLabelPosition;

%ctor {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.instarealdatesettings.plist"];	
	autoExpand = [settings objectForKey:@"alwaysexpand"] ? [[settings objectForKey:@"alwaysexpand"] boolValue] : YES;
	showDateString = [settings objectForKey:@"showdatestring"] ? [[settings objectForKey:@"showdatestring"] boolValue] : YES;
	showTimeString = [settings objectForKey:@"showtimestring"] ? [[settings objectForKey:@"showtimestring"] boolValue] : YES;
    dateLength = [settings objectForKey:@"datelength"] ? [[settings objectForKey:@"datelength"] intValue] : 0;
}

%hook IGFeedItemHeader

%new
- (void) showFullDate {
	//Expand the date label 
	if (self.timestampLabel.frame.origin.x == defaultLabelPosition) {
		NSDate *takenNSDate = [NSDate dateWithTimeIntervalSince1970:[self.feedItem.takenAt timeIntervalSince1970]];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		if (!showDateString) {
			[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		} else {
			[dateFormatter setDateStyle:(unsigned int)dateLengths[dateLength]];
		}
		if (!showTimeString) {
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		} else {
			[dateFormatter setTimeStyle:(unsigned int)dateLengths[dateLength]];
		}
		NSString *expandedString = [dateFormatter stringFromDate: takenNSDate];
		self.timestampLabel.text = expandedString;
		widthAdjust = pixelsPerLetter * expandedString.length; 
		self.timestampLabel.frame = CGRectMake(self.timestampLabel.frame.origin.x - widthAdjust, self.timestampLabel.frame.origin.y, self.timestampLabel.frame.size.width + widthAdjust, self.timestampLabel.frame.size.height);
		self.timestampLabel.adjustsFontSizeToFitWidth = YES;
	}
}

- (void) layoutSubviews {
	%orig;
	defaultLabelPosition = self.timestampLabel.frame.origin.x;
	if (!autoExpand) {
		self.timestampLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(showFullDate)];
		[self.timestampLabel addGestureRecognizer:tapRecog];
	} else {
		[self showFullDate];
	}
}
%end

// vim:ft=objc
