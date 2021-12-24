#import <StoreKit/StoreKit.h>
#import <time.h>

static NSString* bundleIdentifier = @"ai.paisseon.satella";
static NSMutableDictionary* settings;
static bool enabled;
static bool enableReceipts;
static bool enableObserver;
static bool enableBypass;
static bool enableAll;

@interface SKPaymentTransaction (Satella)
- (void) _setTransactionState: (char) arg0;
- (void) _setError: (NSError*) arg0;
@end

@interface SatellaObserver : NSObject<SKPaymentTransactionObserver> {
	id observer;
	NSMutableArray* purchases;
}
+ (instancetype) sharedInstance;
- (id) initWithObserver: (id) arg0;
@end