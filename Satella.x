#import "Satella.h"

@implementation NSString (URLEncoding) // url percent encoding by julioverne
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
			   (CFStringRef)self,
			   NULL,
			   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
			   CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end

static void refreshPrefs() { // prefs by skittyblock
	CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else settings = nil;
	if (!settings) settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleIdentifier]];

	enabled = [([settings objectForKey:@"enabled"] ?: @(true)) boolValue];
	fakeReceipt = [([settings objectForKey:@"fakeReceipt"] ?: @(false)) boolValue];
	enableAll = [([settings objectForKey:@"enableAll"] ?: @(false)) boolValue];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}

static bool enabledInApp (NSString* appName) { // this uses altlist to see what apps the user wants to hack and doesn't inject in any other processes
	NSDictionary* altlistPrefs = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/ai.paisseon.satella.plist"]; // get all enabled apps
	return [altlistPrefs[@"apps"] containsObject:appName]; // returns true if app is whitelisted
}

%hook SKPaymentTransaction
- (long long) transactionState {
	return 1; // return as purchased
}

- (void) _setTransactionState: (long long) arg1 {
	%orig(1); // set as purchased to work on 14
}

- (NSData*) transactionReceipt {
	return [self satellaMajiTenshi]; // generate a fake receipt
}

- (void) _setTransactionReceipt: (id) arg1 {
	arg1 = [self satellaMajiTenshi];
	%orig;
}

%new
- (NSData*) satellaMajiTenshi {
	NSData* fallbackReceipt = [[NSData alloc] initWithBase64EncodedString:fallbackReceiptString options:0]; // convert the above string into data
	if (!self.payment.requestParameters) return fallbackReceipt; // if there are no payment parameters (would cause an error with accg) use the fallback
	NSDictionary* paymentParameters = self.payment.requestParameters; // get the request paramters for the payment
	NSData *paymentParametersData = [NSKeyedArchiver archivedDataWithRootObject:paymentParameters]; // convert the dictionary to data
	NSData* paymentData = [NSJSONSerialization JSONObjectWithData:paymentParametersData options:0 error:0]; // get the parameters as json data
	if (!paymentData) return fallbackReceipt; // yet another safety check
	NSString* accgStringDataForURL = [[NSString alloc] initWithData:paymentData encoding:NSUTF8StringEncoding]; // encode utf8 for use in a url
	NSURL* accgServerURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://stla.000webhostapp.com/AnComCatGirls.php?verifyReceipt&data=%@", [accgStringDataForURL urlEncodeUsingEncoding:NSUTF8StringEncoding]]]; // get the url for ancomcatgirls. source code: https://pastecode.io/s/k42osmsh
	NSURLRequest* accgServerRequest = [NSURLRequest requestWithURL:accgServerURL]; // convert url to request
	NSData* satellaReceiptData = [NSURLConnection sendSynchronousRequest:accgServerRequest returningResponse:0 error:0]; // get data from the server request
	if (!satellaReceiptData) return fallbackReceipt; // if accg is down or the server returns a blank (invalid) response, use the fallback
	NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:satellaReceiptData options:0 error:0]; // convert receipt data into a json object
	NSString* accgReceipt = [responseData objectForKey:@"receipt"]; // only keep the receipt itself, ignore the status. that's for itunes to handle
	if (!accgReceipt) return fallbackReceipt; // the final fallback
	NSString* satellaReceiptString = [accgReceipt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // remove whitespace for processing
	NSData* satellaReceipt = [[NSData alloc] initWithBase64EncodedString:satellaReceiptString options:0]; // convert the finalised receipt back into nsdata

	if (fakeReceipt && satellaReceipt) return satellaReceipt;
	return fallbackReceipt; // i lied. this one is the final fallback
}
%end

%hook SKPaymentQueue
+ (bool) canMakePayments {
	return true; // allow restricted users to fake purchase
}
%end

%hook SKReceiptRefreshRequest
- (bool) _wantsRevoked {
	return false; // make the receipt not revoked
}

- (bool) _wantsExpired {
	return false; // make the receipt not expired
}
%end

%hook NSURLRequest
- (id) initWithURL: (id) arg1 {
	if (!fakeReceipt || ![[arg1 absoluteString] isEqualToString:@"https://buy.itunes.apple.com/verifyReceipt"]) return %orig;
	return [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://stla.000webhostapp.com/AnComCatGirls.php?verifyReceipt"]]; // this is so we get a status 0 return. it uses fallback receipt as well.
}
%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefschanged", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
	NSString* appName = [[NSBundle mainBundle] bundleIdentifier];
	if ((enabled && enabledInApp(appName)) || enableAll) %init;
}