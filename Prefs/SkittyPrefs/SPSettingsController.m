// SPSettingsController.m

#import "SPSettingsController.h"
#import "UIColor+Hex.h"
#import <Preferences/PSSpecifier.h>

@implementation SPSettingsController

- (void)loadView {
	[super loadView];

	// Load settings
	NSURL *url = [NSURL fileURLWithPath:[[self resourceBundle] pathForResource:@"Root" ofType:@"plist"]];
	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfURL:url];
	self.settings = [settings mutableCopy];
	[self.settings removeObjectForKey:@"items"];

	// Load tint colors
	if (self.settings[@"tintColor"]) self.settings[@"tintColor"] = [UIColor colorFromHex:self.settings[@"tintColor"]];
	if (self.settings[@"textColor"]) self.settings[@"textColor"] = [UIColor colorFromHex:self.settings[@"textColor"]];
	if (self.settings[@"subtitleTextColor"]) self.settings[@"subtitleTextColor"] = [UIColor colorFromHex:self.settings[@"subtitleTextColor"]];
	if (self.settings[@"darkTextColor"]) self.settings[@"darkTextColor"] = [UIColor colorFromHex:self.settings[@"darkTextColor"]];
	if (self.settings[@"headerColor"]) self.settings[@"headerColor"] = [UIColor colorFromHex:self.settings[@"headerColor"]];
	if (self.settings[@"darkHeaderColor"]) self.settings[@"darkHeaderColor"] = [UIColor colorFromHex:self.settings[@"darkHeaderColor"]];
	if (self.settings[@"tintColor"]) self.themeColor = self.settings[@"tintColor"];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"";

	// Icon on navbar
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
	self.iconView = [[UIImageView alloc] initWithFrame:titleView.bounds];
	self.iconView.image = [UIImage imageWithContentsOfFile:[[self resourceBundle] pathForResource:@"icon" ofType:@"png"]];
	self.iconView.alpha = 0;
	[titleView addSubview:self.iconView];

	self.navigationItem.titleView = titleView;

	// Create header view
	self.headerView = [[SPHeaderView alloc] initWithSettings:[self.settings copy]];
	self.headerView.layer.zPosition = 1000;
	[self.view addSubview:self.headerView];

	// Update offset for header
	UITableView *tableView = [self valueForKey:@"_table"];
	CGFloat contentHeight = [self.headerView contentHeightForWidth:self.view.bounds.size.width];
	[tableView setContentOffset:CGPointMake(0, -contentHeight) animated: NO];

	self.navbarThemed = YES;
	self.iconView.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navbarThemed = YES;
	self.iconView.alpha = 0;

	if ([UIStatusBar instancesRespondToSelector:@selector(setForegroundColor:)]) {
		[UIApplication sharedApplication].statusBar.foregroundColor = [UIColor whiteColor];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navbarThemed = NO;

	if ([UIStatusBar instancesRespondToSelector:@selector(setForegroundColor:)]) {
		[UIApplication sharedApplication].statusBar.foregroundColor = nil;
	}
}

// Set global tint color
- (void)setThemeColor:(UIColor *)color {
	_themeColor = color;
	
	UIWindow *keyWindow = nil;
	NSArray *windows = [[UIApplication sharedApplication] windows];
	for (UIWindow *window in windows) {
		if (window.isKeyWindow) {
			keyWindow = window;
			break;
		}
	}

	self.view.tintColor = color;
	keyWindow.tintColor = color;
	[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = color;

	self.navbarThemed = self.navbarThemed;
}

// Modify navbar colors
- (void)setNavbarThemed:(BOOL)enabled {
	_navbarThemed = enabled;

	UINavigationBar *bar = self.navigationController.navigationController.navigationBar;

	if (enabled) {
		bar.barTintColor = self.settings[@"headerColor"] ?: self.themeColor;
		bar.tintColor = self.settings[@"textColor"] ?: [UIColor whiteColor];
		if (@available(iOS 13.0, *)) {
			if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
				if (self.settings[@"darkHeaderColor"]) bar.barTintColor = self.settings[@"darkHeaderColor"];
				if (self.settings[@"darkTextColor"]) bar.tintColor = self.settings[@"darkTextColor"];
			}
		}
		bar.translucent = NO;
		bar.shadowImage = [UIImage new];
	} else {
		bar.barTintColor = [[UINavigationBar appearance] barTintColor];
		bar.tintColor = [[UINavigationBar appearance] tintColor];
		bar.translucent = YES;
		bar.shadowImage = [[UINavigationBar appearance] shadowImage];
	}

	[self layoutHeader];
}

// Header colors dark mode support
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	if (@available(iOS 13, *)) {
		UINavigationBar *bar = self.navigationController.navigationController.navigationBar;
		if (@available(iOS 13.0, *)) {
			if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
				if (self.settings[@"darkHeaderColor"]) bar.barTintColor = self.settings[@"darkHeaderColor"];
				if (self.settings[@"darkTextColor"]) bar.tintColor = self.settings[@"darkTextColor"];
			} else {
				bar.barTintColor = self.settings[@"headerColor"] ?: self.themeColor;
				bar.tintColor = self.settings[@"textColor"] ?: [UIColor whiteColor];
			}
		} else {
			bar.barTintColor = self.settings[@"headerColor"] ?: self.themeColor;
			bar.tintColor = self.settings[@"textColor"] ?: [UIColor whiteColor];
		}
	}
}

// Status bar color (requires UINavigationController+StatusBar hack)
- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

// Header positioning
- (void)layoutHeader {
	UITableView *tableView = [self valueForKey:@"_table"];

	CGFloat contentHeight = [self.headerView contentHeightForWidth:self.view.bounds.size.width];

	CGFloat yPos = fmin(0, -tableView.contentOffset.y - 20) + 20;
	CGFloat elasticHeight = -tableView.contentOffset.y - contentHeight - 20;

	if (elasticHeight < 0) {
		yPos += elasticHeight;
		elasticHeight = 0;
	}

	self.headerView.frame = CGRectMake(0, yPos, self.view.bounds.size.width, contentHeight + elasticHeight);
	self.headerView.elasticHeight = elasticHeight;
	tableView.contentInset = UIEdgeInsetsMake(contentHeight, 0, 0, 0);

	if (@available(iOS 13.0, *)) {
		tableView.automaticallyAdjustsScrollIndicatorInsets = NO;
	}
	tableView.scrollIndicatorInsets = UIEdgeInsetsMake(contentHeight + elasticHeight + 20, 0, 0, 0);

	// Show header icon
	CGFloat start = -60;
	CGFloat length = 50;
	if (tableView.contentOffset.y < start) {
		self.iconView.alpha = 0;
	} else if (tableView.contentOffset.y > start && tableView.contentOffset.y < length + start) {
		self.iconView.alpha = (tableView.contentOffset.y - start) / length;
	} else if (tableView.contentOffset.y >= length + start) {
		self.iconView.alpha = 1;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self layoutHeader];
}

// Bundle for fetching resources
// This should probably be overridden in subclasses.
- (NSBundle *)resourceBundle {
	return [NSBundle bundleForClass:self.class];
}

// Update toggles that show other cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
	if ([specifier propertyForKey:@"requires"]) {
		if (![[self.requiredToggles objectForKey:[specifier propertyForKey:@"requires"]] boolValue]) {
			return 0.001; // It removes the cell if you set it to zero
		}
	}
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.clipsToBounds = YES; // hides content when resizing
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];
	if ([specifier propertyForKey:@"key"]) {
		if ([self.requiredToggles objectForKey:[specifier propertyForKey:@"key"]]) {
			[self.requiredToggles setObject:value forKey:[specifier propertyForKey:@"key"]];
			[self updateVisibility];
		}
	}
}

- (void)updateVisibility {
	[[self valueForKey:@"_table"] beginUpdates];
	[[self valueForKey:@"_table"] endUpdates];
}

- (NSMutableArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

		// Load toggles that show other cells
		self.requiredToggles = (!self.requiredToggles) ? [[NSMutableDictionary alloc] init] : self.requiredToggles;
		for (PSSpecifier *specifier in _specifiers) {
			if ([specifier propertyForKey:@"requires"]) {
				[self.requiredToggles setObject:@0 forKey:[specifier propertyForKey:@"requires"]];
			}
		}
		for (PSSpecifier *specifier in _specifiers) {
			if ([self.requiredToggles objectForKey:[specifier propertyForKey:@"key"]]) {
				[self.requiredToggles setObject:[self readPreferenceValue:specifier] forKey:[specifier propertyForKey:@"key"]];
			}
		}
	}

	return _specifiers;
}

@end
