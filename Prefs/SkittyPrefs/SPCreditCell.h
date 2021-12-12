#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/CoreAnimation.h>

#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

@interface SPCreditCell : PSTableCell

@property (nonatomic, retain) UIImageView *creditImageView;
@property (nonatomic, assign) UIImage *creditImage;
@property (nonatomic, assign) NSString *jestress;

@end
