# Satella
A fast and modern IAP hacker for iOS 12-14, also the only open source IAP hack ever!

Features:

- The only open source IAP hacker for iOS
- Compatible with iOS 12-14 and all devices newer than iPhone 6
- Fast and lightweight, injects only into the apps you choose
- Option to fake receipts, which means you can hack more apps

Known issues:

- Some apps that work on iOS 13 don't on 14. This is because AnComCatgirls, like LocalIAPStore's Grim_Receiper, doesn't support iOS 14. I looked into it but the new receipt verification is wayyyy harder to hack than 13's.
- Apps might crash with the error 'data parameter is nil'. I fixed that in a previous update but removed it because ACCG should fix it in a cleaner way. If this does happen let me know and I can add it back in.
- On iOS 12, prefs might not load. Idk how to fix because I don't have consistent access to iOS 12 device.
- Some purchases may be inconsistent! Transaction ID is randomised so there may be duplicates. If this is the case, the purchase will probably fail. Trying again might work.
- Things that should work will inevitably have bugs. I'm kinda in over my head here, this was originally a Flex 3 patch, the past > 1 year is the entirety of my Obj-C experience. That said, I will do my absolute best to make Satella the best it can be, but please don't expect much.
