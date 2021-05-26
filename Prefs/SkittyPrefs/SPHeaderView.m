#import "SPHeaderView.h"
#import <CoreText/CoreText.h>

@implementation SPHeaderView

- (id)initWithSettings:(NSDictionary *)settings {
	self = [super init];

	if (self) {
		self.settings = settings;

		NSString *fontName = nil;
		if (settings[@"headerFontPath"]) {
			CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([settings[@"headerFontPath"] UTF8String]);
			CGFontRef font = CGFontCreateWithDataProvider(dataProvider);
			CGDataProviderRelease(dataProvider);
			CTFontManagerRegisterGraphicsFont(font, nil);
			fontName = (NSString *)CFBridgingRelease(CGFontCopyPostScriptName(font));
			CGFontRelease(font);
		}

		self.backgroundColor = settings[@"headerColor"] ?: settings[@"tintColor"];

		self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, self.bounds.size.width, 118)];
		[self addSubview:self.contentView];

		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.bounds.size.width, 50)];
		self.titleLabel.text = settings[@"name"];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		if (fontName) {
			self.titleLabel.font = [UIFont fontWithName:fontName size:[settings[@"titleFontSize"] floatValue] ?: 42];
		} else {
			self.titleLabel.font = [UIFont boldSystemFontOfSize:[settings[@"titleFontSize"] floatValue] ?: 42];
		}
		self.titleLabel.textColor = settings[@"textColor"] ?: [UIColor whiteColor];
		[self.contentView addSubview:self.titleLabel];

		self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 71, self.bounds.size.width, 32)];
		self.subtitleLabel.text = settings[@"subtitle"];
		self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
		if (fontName) {
			self.subtitleLabel.font = [UIFont fontWithName:fontName size:[settings[@"subtitleFontSize"] floatValue] ?: 28];
		} else {
			self.subtitleLabel.font = [UIFont systemFontOfSize:[settings[@"subtitleFontSize"] floatValue] ?: 28];
		}
		self.subtitleLabel.textColor = self.settings[@"subtitleTextColor"] ?: (self.settings[@"textColor"] ?: [UIColor whiteColor]);
		[self.contentView addSubview:self.subtitleLabel];

		self.backgroundColor = [UIColor blackColor];
		self.titleLabel.textColor = [UIColor whiteColor];
		self.subtitleLabel.textColor = [UIColor whiteColor];
	}

	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	CGFloat statusBarHeight = 20;
	statusBarHeight = self.window.windowScene.statusBarManager.statusBarFrame.size.height;

	CGFloat offset = statusBarHeight + [self _viewControllerForAncestor].navigationController.navigationController.navigationBar.frame.size.height;

	self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, (frame.size.height - offset)/2 - self.contentView.frame.size.height/2 + offset - 20, frame.size.width, self.contentView.frame.size.height);

	self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, frame.size.width, self.titleLabel.frame.size.height);

	self.subtitleLabel.frame = CGRectMake(self.subtitleLabel.frame.origin.x, self.subtitleLabel.frame.origin.y, frame.size.width, self.subtitleLabel.frame.size.height);
}

- (CGFloat)contentHeightForWidth:(CGFloat)width {
	return 192;
}

@end
