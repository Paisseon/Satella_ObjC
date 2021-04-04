%hook SKPaymentTransaction
- (long long) transactionState {
    return 1; // return as purchased
}

- (void) _setTransactionState: (long long) arg1 {
    %orig(1); // iOS 14 fix
}
%end
