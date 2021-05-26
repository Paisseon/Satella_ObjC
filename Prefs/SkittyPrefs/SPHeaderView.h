#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface SPHeaderView : UIView

@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;

@property (nonatomic, assign) CGFloat elasticHeight;

- (id)initWithSettings:(NSDictionary *)settings;
- (CGFloat)contentHeightForWidth:(CGFloat)width;

@end
