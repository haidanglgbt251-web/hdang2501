#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <AudioToolbox/AudioToolbox.h>

// Khai báo class cho lockscreen window
@interface SBLockScreenWindow : UIWindow
@end

// Category khai báo selector cho SpringBoard
@interface SpringBoard (HDangDynamic)
- (void)setupDynamicIslandInAllWindows;
- (void)windowDidBecomeVisible:(NSNotification *)notification;
@end

// View Dynamic Island
@interface HDangDynamicView : UIView
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) CGFloat originalWidth;
@property (nonatomic, assign) CGFloat originalHeight;
@property (nonatomic, strong) UIView *cameraDot;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@end

@implementation HDangDynamicView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = frame.size.height / 2;
        self.layer.masksToBounds = YES;
        self.originalWidth = frame.size.width;
        self.originalHeight = frame.size.height;
        self.isExpanded = NO;
        self.clipsToBounds = YES;
        
        [self setupCameraDot];
        [self setupGestures];
    }
    return self;
}

- (void)setupCameraDot {
    self.cameraDot = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 22, self.frame.size.height/2 - 6, 12, 12)];
    self.cameraDot.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    self.cameraDot.layer.cornerRadius = 6;
    self.cameraDot.tag = 100;
    [self addSubview:self.cameraDot];
}

- (void)setupGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}

- (void)handleTap {
    if (self.isExpanded) {
        [self collapse];
    } else {
        [self expand];
        AudioServicesPlaySystemSound(1519);
    }
}

- (void)handleDoubleTap {
    [self closeIsland];
    AudioServicesPlaySystemSound(1520);
}

- (void)handleLongPress {
    [self expandFull];
    AudioServicesPlaySystemSound(1519);
}

- (void)expand {
    if (self.isExpanded) return;
    self.isExpanded = YES;
    
    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.frame = CGRectMake(self.frame.origin.x - 80,
                                self.frame.origin.y - 15,
                                self.originalWidth + 160,
                                self.originalHeight + 30);
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.cameraDot.alpha = 0;
        [self showExpandedContent];
    } completion:nil];
}

- (void)expandFull {
    if (self.isExpanded) return;
    self.isExpanded = YES;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.frame = CGRectMake(20, 50, screenWidth - 40, 180);
        self.layer.cornerRadius = 30;
        self.cameraDot.alpha = 0;
        [self showExpandedContent];
    } completion:nil];
}

- (void)collapse {
    if (!self.isExpanded) return;
    self.isExpanded = NO;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat islandWidth = self.originalWidth;
    CGFloat islandHeight = self.originalHeight;
    CGFloat islandY = self.frame.origin.y;
    
    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.frame = CGRectMake(screenWidth/2 - islandWidth/2,
                                islandY,
                                islandWidth,
                                islandHeight);
        self.layer.cornerRadius = islandHeight / 2;
        self.cameraDot.alpha = 1;
        [self clearContent];
    } completion:nil];
}

- (void)closeIsland {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1;
                self.transform = CGAffineTransformIdentity;
            }];
        });
    }];
}

- (void)showExpandedContent {
    [self clearContent];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.frame.size.height/2 - 15, 30, 30)];
    self.iconView.image = [UIImage systemImageNamed:@"info.circle.fill"];
    self.iconView.tintColor = [UIColor whiteColor];
    [self addSubview:self.iconView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, self.frame.size.height/2 - 20, self.frame.size.width - 80, 20)];
    self.titleLabel.text = @"HDang Dynamic";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, self.frame.size.height/2, self.frame.size.width - 80, 15)];
    self.subtitleLabel.text = @"Tap để đóng";
    self.subtitleLabel.font = [UIFont systemFontOfSize:11];
    self.subtitleLabel.textColor = [UIColor grayColor];
    [self addSubview:self.subtitleLabel];
}

- (void)clearContent {
    [self.titleLabel removeFromSuperview];
    [self.subtitleLabel removeFromSuperview];
    [self.iconView removeFromSuperview];
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.iconView = nil;
}

@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupDynamicIslandInAllWindows];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeVisible:)
                                                 name:@"UIWindowDidBecomeVisibleNotification"
                                               object:nil];
}

%new
- (void)windowDidBecomeVisible:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupDynamicIslandInAllWindows];
    });
}

%new
- (void)setupDynamicIslandInAllWindows {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // Xác định loại thiết bị
    BOOL hasNotch = (screenHeight >= 812);
    
    CGFloat islandWidth = 120;
    CGFloat islandHeight = 35;
    CGFloat islandY = 10;
    
    if (hasNotch) {
        if (screenWidth >= 428) {
            islandWidth = 126;
            islandHeight = 36;
        } else if (screenWidth >= 390) {
            islandWidth = 120;
            islandHeight = 35;
        } else if (screenWidth >= 375) {
            islandWidth = 115;
            islandHeight = 34;
        }
        if (screenHeight >= 852) {
            islandY = 11;
        }
    } else {
        islandY = 20; // Dưới status bar cho iPhone nút Home
        if (screenWidth <= 320) {
            islandWidth = 100;
            islandHeight = 30;
        } else if (screenWidth <= 375) {
            islandWidth = 115;
            islandHeight = 32;
        } else {
            islandWidth = 125;
            islandHeight = 34;
        }
    }
    
    CGRect islandFrame = CGRectMake(screenWidth/2 - islandWidth/2, islandY, islandWidth, islandHeight);
    
    // Thêm vào key window (màn hình chính)
    UIWindow *keyWindow = nil;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            keyWindow = window;
            break;
        }
    }
    if (keyWindow) {
        if (![keyWindow viewWithTag:9999]) {
            HDangDynamicView *island = [[HDangDynamicView alloc] initWithFrame:islandFrame];
            island.tag = 9999;
            [keyWindow addSubview:island];
            [keyWindow bringSubviewToFront:island];
        }
    }
    
    // Thêm vào lockscreen window (màn hình khóa)
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:NSClassFromString(@"SBLockScreenWindow")] ||
            window.windowLevel > UIWindowLevelNormal) {
            if (![window viewWithTag:10000]) {
                HDangDynamicView *island = [[HDangDynamicView alloc] initWithFrame:islandFrame];
                island.tag = 10000;
                [window addSubview:island];
                [window bringSubviewToFront:island];
            }
        }
    }
}

%end
