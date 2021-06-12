#import "Satella.h"

@implementation NSString (URLEncoding) // updated version of julioverne's urlencodeusingencoding
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
    if (fakeReceipt) return 3; // return as restored
    return 1; // return as purchased
}

- (void) _setTransactionState: (long long) arg1 {
    if (fakeReceipt) %orig(3); // set as restored
    else %orig(1); // set as purchased to work on 14
}

- (NSData*) transactionReceipt {
    if (fakeReceipt) return [self satellaMajiTenshi]; // generate a fake receipt
    return %orig;
}

- (void) _setTransactionReceipt: (id) arg1 {
    if (fakeReceipt) arg1 = [self satellaMajiTenshi];
    %orig;
}

%new
- (NSData*) satellaMajiTenshi {
    receiptData64String = @"ewoJInNpZ25hdHVyZSIgPSAiQXBkeEpkdE53UFUyckE1L2NuM2tJTzFPVGsyNWZlREthMGFhZ3l5UnZlV2xjRmxnbHY2UkY2em5raUJTM3VtOVVjN3BWb2IrUHFaUjJUOHd5VnJITnBsb2YzRFgzSXFET2xXcSs5MGE3WWwrcXJSN0E3ald3dml3NzA4UFMrNjdQeUhSbmhPL0c3YlZxZ1JwRXI2RXVGeWJpVTFGWEFpWEpjNmxzMVlBc3NReEFBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NHVVVrVTNaV0FTMU1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEE1TURZeE5USXlNRFUxTmxvWERURTBNRFl4TkRJeU1EVTFObG93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNclJqRjJjdDRJclNkaVRDaGFJMGc4cHd2L2NtSHM4cC9Sd1YvcnQvOTFYS1ZoTmw0WElCaW1LalFRTmZnSHNEczZ5anUrK0RyS0pFN3VLc3BoTWRkS1lmRkU1ckdYc0FkQkVqQndSSXhleFRldngzSExFRkdBdDFtb0t4NTA5ZGh4dGlJZERnSnYyWWFWczQ5QjB1SnZOZHk2U01xTk5MSHNETHpEUzlvWkhBZ01CQUFHamNqQndNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVOaDNvNHAyQzBnRVl0VEpyRHRkREM1RllRem93RGdZRFZSMFBBUUgvQkFRREFnZUFNQjBHQTFVZERnUVdCQlNwZzRQeUdVakZQaEpYQ0JUTXphTittVjhrOVRBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQUVhU2JQanRtTjRDL0lCM1FFcEszMlJ4YWNDRFhkVlhBZVZSZVM1RmFaeGMrdDg4cFFQOTNCaUF4dmRXLzNlVFNNR1k1RmJlQVlMM2V0cVA1Z204d3JGb2pYMGlreVZSU3RRKy9BUTBLRWp0cUIwN2tMczlRVWU4Y3pSOFVHZmRNMUV1bVYvVWd2RGQ0TndOWXhMUU1nNFdUUWZna1FRVnk4R1had1ZIZ2JFL1VDNlk3MDUzcEdYQms1MU5QTTN3b3hoZDNnU1JMdlhqK2xvSHNTdGNURXFlOXBCRHBtRzUrc2s0dHcrR0szR01lRU41LytlMVFUOW5wL0tsMW5qK2FCdzdDMHhzeTBiRm5hQWQxY1NTNnhkb3J5L0NVdk02Z3RLc21uT09kcVRlc2JwMGJzOHNuNldxczBDOWRnY3hSSHVPTVoydG04bnBMVW03YXJnT1N6UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREV5TFRBM0xURXlJREExT2pVME9qTTFJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkluQjFjbU5vWVhObExXUmhkR1V0YlhNaUlEMGdJakV6TkRJd09UYzJOelU0T0RJaU93b0pJbTl5YVdkcGJtRnNMWFJ5WVc1ellXTjBhVzl1TFdsa0lpQTlJQ0l4TnpBd01EQXdNamswTkRrME1qQWlPd29KSW1KMmNuTWlJRDBnSWpFdU5DSTdDZ2tpWVhCd0xXbDBaVzB0YVdRaUlEMGdJalExTURVME1qSXpNeUk3Q2draWRISmhibk5oWTNScGIyNHRhV1FpSUQwZ0lqRTNNREF3TURBeU9UUTBPVFF5TUNJN0Nna2ljWFZoYm5ScGRIa2lJRDBnSWpFaU93b0pJbTl5YVdkcGJtRnNMWEIxY21Ob1lYTmxMV1JoZEdVdGJYTWlJRDBnSWpFek5ESXdPVGMyTnpVNE9ESWlPd29KSW1sMFpXMHRhV1FpSUQwZ0lqVXpOREU0TlRBME1pSTdDZ2tpZG1WeWMybHZiaTFsZUhSbGNtNWhiQzFwWkdWdWRHbG1hV1Z5SWlBOUlDSTVNRFV4TWpNMklqc0tDU0p3Y205a2RXTjBMV2xrSWlBOUlDSmpiMjB1ZW1Wd2RHOXNZV0l1WTNSeVltOXVkWE11YzNWd1pYSndiM2RsY2pFaU93b0pJbkIxY21Ob1lYTmxMV1JoZEdVaUlEMGdJakl3TVRJdE1EY3RNVElnTVRJNk5UUTZNelVnUlhSakwwZE5WQ0k3Q2draWIzSnBaMmx1WVd3dGNIVnlZMmhoYzJVdFpHRjBaU0lnUFNBaU1qQXhNaTB3TnkweE1pQXhNam8xTkRvek5TQkZkR012UjAxVUlqc0tDU0ppYVdRaUlEMGdJbU52YlM1NlpYQjBiMnhoWWk1amRISmxlSEJsY21sdFpXNTBjeUk3Q2draWNIVnlZMmhoYzJVdFpHRjBaUzF3YzNRaUlEMGdJakl3TVRJdE1EY3RNVElnTURVNk5UUTZNelVnUVcxbGNtbGpZUzlNYjNOZlFXNW5aV3hsY3lJN0NuMD0iOwoJInBvZCIgPSAiMTciOwoJInNpZ25pbmctc3RhdHVzIiA9ICIwIjsKfQ"; // this base64 string translates to the long comment below
    receiptData64 = [[NSData alloc] initWithBase64EncodedString:receiptData64String options:0]; // convert the above string into data
    accgStringDataForURL = [[NSString alloc] initWithData:receiptData64 encoding:NSUTF8StringEncoding]; // encode utf8 for use in a url
    accgServerURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://satella.byethost12.com/AnComCatgirls.php?data=%@", [accgStringDataForURL urlEncodeUsingEncoding:NSUTF8StringEncoding]]]; // inspired by zond80's grim_receiper. accg works on more apps for me (ios 13) but 14 is still broken
    accgServerRequest = [NSURLRequest requestWithURL:accgServerURL]; // convert url to request
    satellaReceiptData = [NSURLConnection sendSynchronousRequest:accgServerRequest returningResponse:0 error:0]; // get data from the server request
    responseData = [NSJSONSerialization JSONObjectWithData:satellaReceiptData options:0 error:0]; // convert receipt data into a json object
    accgReceipt = [responseData objectForKey:@"receipt"]; // removes a bunch of unnecessary information
    satellaReceiptString = [accgReceipt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // remove whitespace for processing
    satellaReceipt = [[NSData alloc] initWithBase64EncodedString:satellaReceiptString options:0]; // convert the finalised receipt back into nsdata

    return satellaReceipt;
}
%end

%hook SKPaymentQueue
+ (bool) canMakePayments {
    return true; // allow restricted users to fake purchase
}
%end

%hook SKReceiptRefreshRequest // i don't think these are necessary but they might help on the 0.00001% of subscriptions that work with
- (bool) _wantsRevoked {
    return false; // make the receipt not revoked
}

- (bool) _wantsExpired {
    return false; // make the receipt not expired
}
%end

%hook NSURLRequest
- (id) initWithURL: (id) arg1 {
    if (!fakeReceipt || ![[arg1 absoluteString] isEqual:@"https://buy.itunes.apple.com/verifyReceipt"]) return %orig;
    return [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://satella.byethost12.com/AnComCatgirls.php?verifyReceipt"]]; // replace the itunes url with accg
}
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefschanged", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    refreshPrefs();
    appName = [[NSBundle mainBundle] bundleIdentifier];
    if (enabled && enabledInApp(appName)) %init;
}