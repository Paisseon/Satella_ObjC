#import "Satella.h"

static void refreshPrefs() { // prefs by skittyblock
	CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else settings = nil;
	if (!settings) settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleIdentifier]];

	enabled        = [([settings objectForKey:@"enabled"] ?: @(true)) boolValue];
	enableReceipts = [([settings objectForKey:@"enableReceipts"] ?: @(false)) boolValue];
	enableObserver = [([settings objectForKey:@"enableObserver"] ?: @(false)) boolValue];
	enableBypass   = [([settings objectForKey:@"enableBypass"] ?: @(false)) boolValue];
	enableAll      = [([settings objectForKey:@"enableAll"] ?: @(false)) boolValue];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}

static bool enabledInApp(NSString* appName) { // use altlist to only inject in processes chosen by user. this allows for valid purchases when desired
	NSDictionary* prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ai.paisseon.satella.plist"]; // get all enabled apps
	return [prefs[@"apps"] containsObject:appName]; // returns true if app is whitelisted
	// thanks to randy420!
}

static NSData* satellaReceipt() {
	long long now = time(NULL) * 1000; // get time since epoch in ms
	NSString* bvrs = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]; // get the app version
	uint32_t receiptId = arc4random_uniform(23092029); // make a random transaction id
	NSString* vendorId = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // get uuid for app
	NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier]; // get the app bundle id

	NSString* purchaseInfo = [NSString stringWithFormat:@"{\n\t\"original-purchase-date-pst\" = \"2021-07-15 04:29:00 America/Los_Angeles\";\n\t\"purchase-date-ms\" = \"%lli\";\n\t\"unique-identifier\" = \"V2hlcmUgYXJlIHRoZSBrbml2ZXMuIC0gQ2hhcmEu\";\n\t\"original-transaction-id\" = \"440000267115041\";\n\t\"bvrs\" = \"%@\";\n\t\"app-item-id\" = \"1106936921\";\n\t\"transaction-id\" = \"%u\";\n\t\"quantity\" = \"1\";\n\t\"original-purchase-date-ms\" = \"%lli\";\n\t\"unique-vendor-identifier\" = \"%@\";\n\t\"item-id\" = \"1114015840\";\n\t\"version-external-identifier\" = \"07151129\";\n\t\"product-id\" = \"%@.satella\";\n\t\"purchase-date\" = \"2021-07-15 11:29:00 Etc/GMT\";\n\t\"original-purchase-date\" = \"2021-07-15 11:29:00 Etc/GMT\";\n\t\"bid\" = \"%@\";\n\t\"purchase-date-pst\" = \"2021-07-15 04:29:00 America/Los_Angeles\";\n}", now, bvrs, receiptId, now, vendorId, bundleId, bundleId]; // fill out the purchase-info section of receipt with information
	
	NSData* purchaseData = [purchaseInfo dataUsingEncoding:NSUTF8StringEncoding]; // convert to data
	NSString* purchaseB64 = [[NSString alloc] initWithData:purchaseData encoding:NSUTF8StringEncoding]; // and back into a string as base64 encoded
	
	NSString* fullReceipt = [NSString stringWithFormat:@"{\n\t\"signature\" = \"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\";\n\t\"purchase-info\" = \"%@\";\n\t\"pod\" = \"44\";\n\t\"signing-status\" = \"0\";\n}", purchaseB64]; // the full receipt with our hacked purchase info and a valid signature
	
	return [fullReceipt dataUsingEncoding:NSUTF8StringEncoding]; // convert base64 into data for the final receipt
}

@implementation SatellaObserver
+ (instancetype) sharedInstance { // create a shared instance to use as transaction observer
	static dispatch_once_t once;
	static id sharedInstance;
	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (id) initWithObserver: (id) arg0 {
	self = [super init]; // regular initialisation
	if (self) self->observer = arg0; // this is the original observer
	self->purchases = [[NSMutableArray alloc] init]; // create a mutable array in which to store purchases. currently used for debugging
	return self;
}

- (void) paymentQueue: (SKPaymentQueue*) queue updatedTransactions:(NSArray<SKPaymentTransaction*>*) transactions {
	for (SKPaymentTransaction* transaction in transactions) { // loop through all the transactions and do stuff
	
		for (SKPaymentTransaction* purchase in self->purchases) { // loop through already established transactions
			if (purchase.payment == transaction.payment) { // double purchases have identical payment values, so check if it already exists
				return; // prevent the purchase from being registered, which fixes the double purchase bug found by u/oopsuwu
			}
		}
		
		if (transaction) {
			switch (transaction.transactionState) {
				case 0: // purchasing. this should never occur but we will handle it anyway
					[transaction _setTransactionState:1]; // set as purchased anyway
					[transaction _setError:nil]; // and remove any errors
					[self->purchases addObject:transaction]; // add to the purchases ivar
					break;
				case 1: // purchased. the default case
					[self->purchases addObject:transaction]; // just add to purchases
					[queue finishTransaction:transaction]; // finish the transaction, this *should* fix double purchase issue
					break;
				case 2: // failed :(
					[transaction _setTransactionState:1]; // not failed :)
					[transaction _setError:nil];
					if (transaction.payment) [self->purchases addObject:transaction];
					break;
				case 3: // restored
					[self->purchases addObject:transaction.originalTransaction]; // originalTransaction is the real transaction used by the restorer
					[queue finishTransaction:transaction.originalTransaction]; // finish the real transaction
					break;
				case 4: // deferred
					[transaction _setTransactionState:1]; // do the needful
					[transaction _setError:nil];
					[self->purchases addObject:transaction];
			}
		}
	}
	
	if (self->purchases) [self->observer paymentQueue:queue updatedTransactions:self->purchases]; // go through the same process but in the real observer to get real results
}
@end

%group Main
%hook SKPaymentTransaction
- (char) transactionState {
	if (%orig == 3) return 3;
	return 1; // this sets transactionState to SKPaymentTransactionStatePurchased
}

- (void) _setTransactionState: (char) arg0 {
	if (arg0 == 3) %orig;
	else %orig(1); // iOS 14 compatibility
}

- (void) _setError: (NSError*) arg0 {
	%orig(nil); // ignore pesky errors, we don't care about analytics
}

// start crash fixing section

- (NSString*) matchingIdentifier {
	return [NSString stringWithFormat:@"satella-mId-%u", arc4random_uniform(23092029)]; // uses arc4random so that apps don't think it's all the same transaction
}

- (NSString*) transactionIdentifier {
	return [NSString stringWithFormat:@"satella-tId-%u", arc4random_uniform(23092029)];
}

- (NSString*) _transactionIdentifier {
	return [NSString stringWithFormat:@"satella-_tId-%u", arc4random_uniform(23092029)];
}

- (void) _setTransactionIdentifier: (NSString*) arg0 {
	%orig([NSString stringWithFormat:@"satella-_tId-%u", arc4random_uniform(23092029)]);
}

// end crash fixing section
%end

%hook SKPaymentQueue
+ (bool) canMakePayments {
	return true; // allow restricted users to fake purchase
}
%end
%end

%group Receipts
%hook SKPaymentTransaction
- (NSData*) transactionReceipt {
	// TODO: make a real local receipt generator by abusing [NSString stringWithFormat] and NSString <-> NSData conversions
	return satellaReceipt(); // this creates a fake receipt data (iOS 13 only!)
}

- (void) _setTransactionReceipt: (NSData*) arg0 {
	%orig(satellaReceipt()); // same thing but hooks the setter
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
%end

%group Bypass
%hook NSFileManager
- (bool) fileExistsAtPath: (NSString*) arg0 {
	if ([arg0 containsString:@"Satella"] || [arg0 containsString:@"LocalIAPStore"]) return false; // very simple bypass. if it doesn't work, use a real jailbreak detection bypass like shadow or flyjb x because this is a low priority feature 🤷‍♀️
	return %orig;
}
%end
%end

%group Observer
%hook SKPaymentQueue
- (void) addTransactionObserver: (id) arg0 {
	SatellaObserver* tellaObs = [[SatellaObserver sharedInstance] initWithObserver:arg0]; // create an instance of SatellaObserver to hack the queue
	%orig(tellaObs);
}
%end
%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefschanged", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
	NSString* appName = [[NSBundle mainBundle] bundleIdentifier];
	if ((enabled && enabledInApp(appName)) || (enableAll && ![appName hasPrefix:@"com.apple."])) {
		%init(Main);
		if (enableObserver) %init(Observer);
		if (enableBypass) %init(Bypass);
		if (enableReceipts) {
			%init(Receipts);
		}
	}
}