#import <Cephei/HBPreferences.h>

HBPreferences *preferences;
bool enabled;
bool experimental;

%group Satella

%hook SKPaymentTransaction
- (long long) transactionState {
    return 1; // iOS 13 return purchased
}

- (void) _setTransactionState: (long long) arg1 {
    %orig(1); // iOS 14 set as purchased
}
%end

%hook SKPaymentQueue
+ (BOOL) canMakePayments {
    return 1; // allow restricted users to fake purchase
}
%end
%end

%group HereBeDragons

%hook SKPaymentQueueClient
- (BOOL) ignoresInAppPurchaseRestriction {
    return 1; // canmakepayments but for subscriptions
}

- (BOOL) requiresAuthenticationForPayment {
    return 0; // attempt to bypass apple's server
}

- (void) setIgnoresInAppPurchaseRestriction: (BOOL) arg1 {
    %orig(1); // iOS 14
}

- (void) setRequiresAuthenticationForPayment: (BOOL) arg1 {
    %orig(0); // iOS 14
}
%end

%hook SKPayment
- (BOOL) simulatesAskToBuyInSandbox {
    return 1; // attempt to trick the app into thinking it is in xcode
}
%end

%hook SSAuthenticateResponse
- (long long) authenticateResponseType {
    return 0; // don't authenticate response
}
%end

%hook SSPurchaseReceipt
- (BOOL) isValid {
    return 1; // receipt is valid
}

- (BOOL) isVPPLicensed {
    return 1; // volume purchase program
}

- (BOOL) isRevoked {
    return 0; // not revoked
}

- (BOOL) receiptExpired {
    return 0; // receipt not expired
}
%end
%end

%ctor { // prefs stuff
    preferences = [[HBPreferences alloc] initWithIdentifier:@"ai.paisseon.satella"];

    [preferences registerDefaults:@{
        @"Enabled": @YES,
        @"Experimental": @NO,
    }];

    [preferences registerBool:&enabled default:YES forKey:@"Enabled"];
    [preferences registerBool:&experimental default:NO forKey:@"Experimental"];

    if (enabled) %init(Satella); // regular IAP hacking whilst minimising the if statements
    if (enabled && experimental) %init(HereBeDragons); // experimental hacks that may or may not work
}