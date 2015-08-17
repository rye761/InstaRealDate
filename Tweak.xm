#define pixelsPerLetter 5

@interface IGDate : NSObject
- (double) timeIntervalSince1970;
@end

@protocol IGFeedHeaderItem <NSObject>
@property(readonly, assign) IGDate *takenAt;
@end

@interface IGFeedItemHeader : UIView
@property (retain, nonatomic) UIButton *timestampButton;
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
	if (self.timestampButton.frame.origin.x == defaultLabelPosition) {
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
        [self.timestampButton setTitle:expandedString forState:UIControlStateNormal];
		widthAdjust = pixelsPerLetter * expandedString.length;
		self.timestampButton.frame = CGRectMake(self.timestampButton.frame.origin.x - widthAdjust, self.timestampButton.frame.origin.y, self.timestampButton.frame.size.width + widthAdjust, self.timestampButton.frame.size.height);
		self.timestampButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	}
}

- (void) layoutSubviews {
	%orig;
	defaultLabelPosition = self.timestampButton.frame.origin.x;
	if (!autoExpand) {
		self.timestampButton.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(showFullDate)];
		[self.timestampButton addGestureRecognizer:tapRecog];
	} else {
		[self showFullDate];
	}
}
%end

// vim:ft=objc
