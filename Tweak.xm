#define WIDTH_ADJUST 135

@interface IGDate : NSObject
- (double) timeIntervalSince1970;
@end

@protocol IGFeedHeaderItem <NSObject>
@property(readonly, assign) IGDate *takenAt;
@end

@interface IGFeedItemHeader : UIView
@property (retain, nonatomic) UILabel *timestamp;
@property (retain, nonatomic) CALayer *labelIconView;
@property (retain, nonatomic) id<IGFeedHeaderItem> feedItem;
- (void) showFullDate;
@end

BOOL autoExpand;

%ctor {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.instarealdatesettings.plist"];	
	autoExpand = [settings objectForKey:@"alwaysexpand"] ? [[settings objectForKey:@"alwaysexpand"] boolValue] : NO;
}

%hook IGFeedItemHeader

%new
- (void) showFullDate {
	//Expand the date label 
	NSDate *takenNSDate = [NSDate dateWithTimeIntervalSince1970:[self.feedItem.takenAt timeIntervalSince1970]];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	self.timestamp.text = [dateFormatter stringFromDate: takenNSDate];
	self.timestamp.frame = CGRectMake(self.timestamp.frame.origin.x - WIDTH_ADJUST, self.timestamp.frame.origin.y, self.timestamp.frame.size.width + WIDTH_ADJUST, self.timestamp.frame.size.height);
	self.timestamp.adjustsFontSizeToFitWidth = YES;
	
	self.labelIconView.position = CGPointMake(self.labelIconView.position.x - WIDTH_ADJUST, self.labelIconView.position.y);
}

- (void) layoutDateLabel {
	%orig;
	if (!autoExpand) {
		self.timestamp.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(showFullDate)];
		[self.timestamp addGestureRecognizer:tapRecog];
	} else {
		[self showFullDate];
	}
}
%end

// vim:ft=objc
