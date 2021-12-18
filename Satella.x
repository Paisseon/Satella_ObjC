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

static void setSatellaReceipt() {
	satellaReceipt = [[NSData alloc] initWithBase64EncodedString:@"ewoJInNpZ25hdHVyZSIgPSAiQTBMN0Z4UE9lUDBJUGFnd0UrQ3V4bTFNcFZmOE1qVHRvKzdGRGJUTkE5SHhPU1ZVK1h6UVFrcHVxd1RJQzlzZEpMQ2F2S3d6UGpmWUkvOGZXRWJSZldiVFBHUHpIZFZNdHU1clhaOE9JSnNRKy9ySGtMR1lPT3czdmpjdmo3Vk1uRlZOQ2VhRmpjKy9VeWRQVzJxbUlxOHJnUm8rNS9IZGZZTFhTWi8yd1NlcXhlRlR4WVJqRDh0ckdrMjlqajlEcGppNzBjNlFxQlFHaE9nRXB3RzlhSmJJdWFHdnA5OXE1RDlWQjlUSVpVM2FIU3BNa2kwNUdqNkZBellOMG8xQmRkV3VQR3l3d1crdHJBamhyWlhlQVJKc1NwN0xTTzFLRWVjbzNBYk5Od012dE5KL2pLd3AvMlN1UllIL21tdE95ZDF1bzRxUUJQVVhoSXdVUnBtZ0dDUUFBQVdBTUlJRmZEQ0NCR1NnQXdJQkFnSUlEdXRYaCtlZUNZMHdEUVlKS29aSWh2Y05BUUVGQlFBd2daWXhDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1Td3dLZ1lEVlFRTERDTkJjSEJzWlNCWGIzSnNaSGRwWkdVZ1JHVjJaV3h2Y0dWeUlGSmxiR0YwYVc5dWN6RkVNRUlHQTFVRUF3dzdRWEJ3YkdVZ1YyOXliR1IzYVdSbElFUmxkbVZzYjNCbGNpQlNaV3hoZEdsdmJuTWdRMlZ5ZEdsbWFXTmhkR2x2YmlCQmRYUm9iM0pwZEhrd0hoY05NVFV4TVRFek1ESXhOVEE1V2hjTk1qTXdNakEzTWpFME9EUTNXakNCaVRFM01EVUdBMVVFQXd3dVRXRmpJRUZ3Y0NCVGRHOXlaU0JoYm1RZ2FWUjFibVZ6SUZOMGIzSmxJRkpsWTJWcGNIUWdVMmxuYm1sdVp6RXNNQ29HQTFVRUN3d2pRWEJ3YkdVZ1YyOXliR1IzYVdSbElFUmxkbVZzYjNCbGNpQlNaV3hoZEdsdmJuTXhFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4Q3pBSkJnTlZCQVlUQWxWVE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBcGMrQi9TV2lnVnZXaCswajJqTWNqdUlqd0tYRUpzczl4cC9zU2cxVmh2K2tBdGVYeWpsVWJYMS9zbFFZbmNRc1VuR09aSHVDem9tNlNkWUk1YlNJY2M4L1cwWXV4c1FkdUFPcFdLSUVQaUY0MWR1MzBJNFNqWU5NV3lwb041UEM4cjBleE5LaERFcFlVcXNTNCszZEg1Z1ZrRFV0d3N3U3lvMUlnZmRZZUZScjZJd3hOaDlLQmd4SFZQTTNrTGl5a29sOVg2U0ZTdUhBbk9DNnBMdUNsMlAwSzVQQi9UNXZ5c0gxUEttUFVockFKUXAyRHQ3K21mNy93bXYxVzE2c2MxRkpDRmFKekVPUXpJNkJBdENnbDdaY3NhRnBhWWVRRUdnbUpqbTRIUkJ6c0FwZHhYUFEzM1k3MkMzWmlCN2o3QWZQNG83UTAvb21WWUh2NGdOSkl3SURBUUFCbzRJQjF6Q0NBZE13UHdZSUt3WUJCUVVIQVFFRU16QXhNQzhHQ0NzR0FRVUZCekFCaGlOb2RIUndPaTh2YjJOemNDNWhjSEJzWlM1amIyMHZiMk56Y0RBekxYZDNaSEl3TkRBZEJnTlZIUTRFRmdRVWthU2MvTVIydDUrZ2l2Uk45WTgyWGUwckJJVXdEQVlEVlIwVEFRSC9CQUl3QURBZkJnTlZIU01FR0RBV2dCU0lKeGNKcWJZWVlJdnM2N3IyUjFuRlVsU2p0ekNDQVI0R0ExVWRJQVNDQVJVd2dnRVJNSUlCRFFZS0tvWklodmRqWkFVR0FUQ0IvakNCd3dZSUt3WUJCUVVIQWdJd2diWU1nYk5TWld4cFlXNWpaU0J2YmlCMGFHbHpJR05sY25ScFptbGpZWFJsSUdKNUlHRnVlU0J3WVhKMGVTQmhjM04xYldWeklHRmpZMlZ3ZEdGdVkyVWdiMllnZEdobElIUm9aVzRnWVhCd2JHbGpZV0pzWlNCemRHRnVaR0Z5WkNCMFpYSnRjeUJoYm1RZ1kyOXVaR2wwYVc5dWN5QnZaaUIxYzJVc0lHTmxjblJwWm1sallYUmxJSEJ2YkdsamVTQmhibVFnWTJWeWRHbG1hV05oZEdsdmJpQndjbUZqZEdsalpTQnpkR0YwWlcxbGJuUnpMakEyQmdnckJnRUZCUWNDQVJZcWFIUjBjRG92TDNkM2R5NWhjSEJzWlM1amIyMHZZMlZ5ZEdsbWFXTmhkR1ZoZFhSb2IzSnBkSGt2TUE0R0ExVWREd0VCL3dRRUF3SUhnREFRQmdvcWhraUc5Mk5rQmdzQkJBSUZBREFOQmdrcWhraUc5dzBCQVFVRkFBT0NBUUVBRGFZYjB5NDk0MXNyQjI1Q2xtelQ2SXhETUlKZjRGelJqYjY5RDcwYS9DV1MyNHlGdzRCWjMrUGkxeTRGRkt3TjI3YTQvdncxTG56THJSZHJqbjhmNUhlNXNXZVZ0Qk5lcGhtR2R2aGFJSlhuWTR3UGMvem83Y1lmcnBuNFpVaGNvT0FvT3NBUU55MjVvQVE1SDNPNXlBWDk4dDUvR2lvcWJpc0IvS0FnWE5ucmZTZW1NL2oxbU9DK1JOdXhUR2Y4YmdwUHllSUdxTktYODZlT2ExR2lXb1IxWmRFV0JHTGp3Vi8xQ0tuUGFObVNBTW5CakxQNGpRQmt1bGhnd0h5dmozWEthYmxiS3RZZGFHNllRdlZNcHpjWm04dzdISG9aUS9PamJiOUlZQVlNTnBJcjdONFl0UkhhTFNQUWp2eWdhWndYRzU2QWV6bEhSVEJoTDhjVHFBPT0iOwoJInB1cmNoYXNlLWluZm8iID0gImV3b0pJbTl5YVdkcGJtRnNMWEIxY21Ob1lYTmxMV1JoZEdVdGNITjBJaUE5SUNJeU1ESXhMVEEzTFRFMUlEQTBPakk1T2pBd0lFRnRaWEpwWTJFdlRHOXpYMEZ1WjJWc1pYTWlPd29KSW5CMWNtTm9ZWE5sTFdSaGRHVXRiWE1pSUQwZ0lqRTBPREF4TkRVNU16UXlNalFpT3dvSkluVnVhWEYxWlMxcFpHVnVkR2xtYVdWeUlpQTlJQ0pXTW1oc1kyMVZaMWxZU214SlNGSnZXbE5DY21KdGJESmFXRTExU1VNd1oxRXlhR2hqYlVWMUlqc0tDU0p2Y21sbmFXNWhiQzEwY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTkRRd01EQXdNalkzTVRFMU1EUXhJanNLQ1NKaWRuSnpJaUE5SUNJeUxqVXVNQ0k3Q2draVlYQndMV2wwWlcwdGFXUWlJRDBnSWpFeE1EWTVNelk1TWpFaU93b0pJblJ5WVc1ellXTjBhVzl1TFdsa0lpQTlJQ0kwTkRBd01EQXlOamN4TVRVd05ERWlPd29KSW5GMVlXNTBhWFI1SWlBOUlDSXhJanNLQ1NKdmNtbG5hVzVoYkMxd2RYSmphR0Z6WlMxa1lYUmxMVzF6SWlBOUlDSXhORGd3TVRRMU9UTTBNakkwSWpzS0NTSjFibWx4ZFdVdGRtVnVaRzl5TFdsa1pXNTBhV1pwWlhJaUlEMGdJa1pGUWtReVEwRTFMVUV3TWpJdE5FRkJOQzFDT1VOQ0xUSTBRekJFT1VNeU1FUTNOeUk3Q2draWFYUmxiUzFwWkNJZ1BTQWlNVEV4TkRBeE5UZzBNQ0k3Q2draWRtVnljMmx2YmkxbGVIUmxjbTVoYkMxcFpHVnVkR2xtYVdWeUlpQTlJQ0l3TnpFMU1URXlPU0k3Q2draWNISnZaSFZqZEMxcFpDSWdQU0FpWVdrdWNHRnBjM05sYjI0dWMyRjBaV3hzWVM1amVYQjNiaUk3Q2draWNIVnlZMmhoYzJVdFpHRjBaU0lnUFNBaU1qQXlNUzB3TnkweE5TQXhNVG95T1Rvd01DQkZkR012UjAxVUlqc0tDU0p2Y21sbmFXNWhiQzF3ZFhKamFHRnpaUzFrWVhSbElpQTlJQ0l5TURJeExUQTNMVEUxSURFeE9qSTVPakF3SUVWMFl5OUhUVlFpT3dvSkltSnBaQ0lnUFNBaVlXa3VjR0ZwYzNObGIyNHVjMkYwWld4c1lTSTdDZ2tpY0hWeVkyaGhjMlV0WkdGMFpTMXdjM1FpSUQwZ0lqSXdNakV0TURjdE1UVWdNRFE2TWprNk1EQWdRVzFsY21sallTOU1iM05mUVc1blpXeGxjeUk3Q24wPSI7CgkicG9kIiA9ICI0NCI7Cgkic2lnbmluZy1zdGF0dXMiID0gIjAiOwp9" options:0]; // convert base64 receipt string to data
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
	return satellaReceipt; // this creates a fake receipt data (iOS 13 only!)
}

- (void) _setTransactionReceipt: (NSData*) arg0 {
	%orig(satellaReceipt); // same thing but hooks the setter
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
			setSatellaReceipt();
			%init(Receipts);
		}
	}
}