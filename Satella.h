#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static NSString* bundleIdentifier = @"ai.paisseon.satella";
static NSMutableDictionary* settings;
static bool enabled;
static bool fakeReceipt;

NSString* receiptData64String;
NSData* receiptData64;
NSString* grStringDataForURL;
NSURL* grServerURL;
NSURLRequest* grServerRequest;
NSData* satellaReceiptData;
NSDictionary* responseData;
NSString* grReceipt;
NSString* satellaReceiptString;
NSData* satellaReceipt;

NSString* appName;

@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end