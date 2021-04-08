#import <Cephei/HBPreferences.h>

HBPreferences *preferences;
bool enabled;

%hook SKPaymentTransaction
// iOS 13
- (long long) transactionState {
    if (enabled) return 1; // return purchased
    else return %orig;
}
// iOS 14
- (void) _setTransactionState: (long long) arg1 {
    if (enabled) %orig(1); // set transactionState as purchased
    else %orig;
}
%end

%ctor { // prefs stuff
    preferences = [[HBPreferences alloc] initWithIdentifier:@"ai.paisseon.satella"];

    [preferences registerDefaults:@{
        @"Enabled": @YES,
    }];

    [preferences registerBool:&enabled default:YES forKey:@"Enabled"];
}