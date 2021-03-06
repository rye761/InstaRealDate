#define pixelsPerLetter 5

@interface IGFeedItemHeaderViewModel : NSObject
@property (retain, nonatomic) NSDate *takenAt;
@end

@interface IGFeedItemHeader : UIView
@property (retain, nonatomic) UILabel *timestampLabel;
@property (readonly, nonatomic) IGFeedItemHeaderViewModel *viewModel;
- (void) showFullDate;
@end

BOOL autoExpand;
BOOL showDateString;
BOOL showTimeString;
BOOL enabled;
int dateLength;
unsigned int dateLengths[3] = {NSDateFormatterShortStyle, NSDateFormatterMediumStyle, NSDateFormatterLongStyle};
float widthAdjust;
unsigned int defaultLabelPosition;

%ctor {
	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.instarealdatesettings.plist"];
	autoExpand = [settings objectForKey:@"alwaysexpand"] ? [[settings objectForKey:@"alwaysexpand"] boolValue] : YES;
	showDateString = [settings objectForKey:@"showdatestring"] ? [[settings objectForKey:@"showdatestring"] boolValue] : YES;
	showTimeString = [settings objectForKey:@"showtimestring"] ? [[settings objectForKey:@"showtimestring"] boolValue] : YES;
    dateLength = [settings objectForKey:@"datelength"] ? [[settings objectForKey:@"datelength"] intValue] : 0;
	enabled = [settings objectForKey:@"instarealdateenable"] ? [[settings objectForKey:@"instarealdateenable"] boolValue] : YES;
    [settings release];
}

%hook IGFeedItemHeader

%new
- (void) showFullDate {
	//Expand the date label
	if (self.timestampLabel.frame.origin.x == defaultLabelPosition) {
		NSDate *takenNSDate = self.viewModel.takenAt;
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
        [self.timestampLabel setText:expandedString];
		widthAdjust = pixelsPerLetter * expandedString.length;
		self.timestampLabel.frame = CGRectMake(self.timestampLabel.frame.origin.x - widthAdjust, self.timestampLabel.frame.origin.y, self.timestampLabel.frame.size.width + widthAdjust, self.timestampLabel.frame.size.height);
        self.timestampLabel.adjustsFontSizeToFitWidth = YES;
        [dateFormatter release];
	}
}

- (void) layoutSubviews {
	%orig;
    if (!enabled) { return; }

	defaultLabelPosition = self.timestampLabel.frame.origin.x;
	if (!autoExpand) {
		self.timestampLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(showFullDate)];
		[self.timestampLabel addGestureRecognizer:tapRecog];
        [tapRecog release];
	} else {
		[self showFullDate];
	}
}
%end

// vim:ft=objc
