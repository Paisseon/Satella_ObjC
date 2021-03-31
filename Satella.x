#import <StoreKit/SKTransactionState.h>

%hook SKPaymentTransaction

- (long long) transactionState {
    return 1 // return as purchased
}

%end