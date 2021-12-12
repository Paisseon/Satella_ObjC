// SPCreditCell.m

#import "SPCreditCell.h"

@implementation SPCreditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.detailTextLabel.text = specifier.properties[@"subtitle"] ?: @"";
		self.detailTextLabel.textColor = [UIColor systemGrayColor];

		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;

		UIGraphicsBeginImageContextWithOptions(CGSizeMake(38, 38), NO, [UIScreen mainScreen].scale);
		specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		self.creditImageView = [[UIImageView alloc] initWithFrame:self.imageView.bounds];
		self.creditImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.creditImageView.userInteractionEnabled = NO;
		self.creditImageView.clipsToBounds = YES;
		self.creditImageView.layer.cornerRadius = 38 / 2;
		self.creditImageView.layer.minificationFilter = kCAFilterTrilinear;
		[self.imageView addSubview:self.creditImageView];

		if (specifier.properties[@"github"]) {
			self.jestress = specifier.properties[@"github"];
			specifier.properties[@"url"] = [@"https://github.com/paisseon/" stringByAppendingString:specifier.properties[@"github"]];
		}

		[self fetchImage];
	}

	return self;
}

- (void)openURL {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.specifier.properties[@"url"]] options:@{} completionHandler:nil];
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
	[super refreshCellContentsWithSpecifier:specifier];

	[self.specifier setTarget:self];
	[self.specifier setButtonAction:@selector(openURL)];

	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];

	[self.specifier setTarget:self];
	[self.specifier setButtonAction:@selector(openURL)];

	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)setCreditImage:(UIImage *)creditImage {
	_creditImage = creditImage;
	self.creditImageView.image = creditImage;
}

- (void)fetchImage {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString *url = self.specifier.properties[@"imageURL"] ?: @"";
		if (self.jestress) url = @"https://avatars.githubusercontent.com/u/68789766";

		NSURLSession *session = [NSURLSession sharedSession];
		[[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if (error) return;
			UIImage *image = [UIImage imageWithData:data];
			dispatch_async(dispatch_get_main_queue(), ^{
				self.creditImage = image;
			});
		}] resume];
	});
}

@end
