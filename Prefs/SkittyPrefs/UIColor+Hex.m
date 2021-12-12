// UIColor

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (id)colorFromHex:(NSString *)hexString {
	unsigned int rgbValue = 0;

	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner setScanLocation:[hexString hasPrefix:@"#"] ? 1 : 0];
	[scanner scanHexInt:&rgbValue];

	NSString *newString = [hexString substringFromIndex:[hexString hasPrefix:@"#"] ? 1 : 0];

	CGFloat r, g, b, a;
	switch (newString.length) {
		case 3:
			r = ((rgbValue & 0xF00) >> 8) / 255.0;
			g = ((rgbValue & 0xF0) >> 4) / 255.0;
			b = (rgbValue & 0xF) / 255.0;
			a = 1.0;
			break;
		case 4:
			r = ((rgbValue & 0xF000) >> 16) / 255.0;
			g = ((rgbValue & 0xF00) >> 8) / 255.0;
			b = ((rgbValue & 0xF0) >> 4) / 255.0;
			a = (rgbValue & 0xF) / 255.0;
			break;
		case 6:
			r = ((rgbValue & 0xFF0000) >> 16) / 255.0;
			g = ((rgbValue & 0xFF00) >> 8) / 255.0;
			b = (rgbValue & 0xFF) / 255.0;
			a = 1.0;
			break;
		case 8:
			r = ((rgbValue & 0xFF000000) >> 24) / 255.0;
			g = ((rgbValue & 0xFF0000) >> 16) / 255.0;
			b = ((rgbValue & 0xFF00) >> 8) / 255.0;
			a = (rgbValue & 0xFF) / 255.0;
			break;
		default:
			r = 0;
			g = 0;
			b = 0;
			a = 0;
			break;
	}

	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
