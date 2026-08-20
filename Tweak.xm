#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <AudioToolbox/AudioToolbox.h>

// View Dynamic Island
@interface HDangDynamicView : UIView
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) CGFloat originalWidth;
@property (nonatomic, assign) CGFloat originalHeight;
@property (nonatomic, strong) UIView *cameraDot;
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
        
        // Camera dot (chấm nhỏ trang trí)
        self.cameraDot = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 22, frame.size.height/2 - 6, 12, 12)];
        self.cameraDot.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        self.cameraDot.layer.cornerRadius = 6;
        [self addSubview:self.cameraDot];
        
        // Thêm gestures
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress)];
        longPress.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)handleTap {
    if (self.isExpanded) {
        [self collapse];
    } else {
        [self expand];
        AudioServicesPlaySystemSound(1519);
    }
}

- (void)handleLongPress {
    [self expand];
    AudioServicesPlaySystemSound(1519);
}

- (void)expand {
    if (self.isExpanded) return;
    self.isExpanded = YES;
    
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = CGRectMake(self.frame.origin.x - 60,
                                self.frame.origin.y - 10,
                                self.originalWidth + 120,
                                self.originalHeight + 20);
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.cameraDot.alpha = 0;
    }];
}

- (void)collapse {
    if (!self.isExpanded) return;
    self.isExpanded = NO;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [UIView animateWithDuration:0.35 animations:^{
        self.frame = CGRectMake(screenWidth/2 - self.originalWidth/2,
                                self.frame.origin.y + 10,
                                self.originalWidth,
                                self.originalHeight);
        self.layer.cornerRadius = self.originalHeight / 2;
        self.cameraDot.alpha = 1;
    }];
}

@end

// Khai báo category cho SpringBoard
@interface SpringBoard (HDangDynamic)
- (void)setupHDangDynamicWindow;
@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupHDangDynamicWindow];
    });
}

%new
- (void)setupHDangDynamicWindow {
    static UIWindow *dynamicWindow = nil;
    if (dynamicWindow) return; // tránh tạo trùng

    // Kích thước cho iPhone 6s Plus (414x736)
    CGFloat screenWidth = 414;
    CGFloat screenHeight = 736;
    CGFloat islandWidth = 125;
    CGFloat islandHeight = 34;
    CGFloat islandY = 20; // dưới status bar

    CGRect frame = CGRectMake(screenWidth/2 - islandWidth/2, islandY, islandWidth, islandHeight);

    // Tạo UIWindow riêng nổi trên tất cả
    dynamicWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    dynamicWindow.windowLevel = UIWindowLevelAlert + 1; // nổi trên màn hình khóa
    dynamicWindow.backgroundColor = [UIColor clearColor];
    dynamicWindow.rootViewController = [UIViewController new];
    dynamicWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
    dynamicWindow.userInteractionEnabled = YES;
    dynamicWindow.hidden = NO;

    HDangDynamicView *island = [[HDangDynamicView alloc] initWithFrame:frame];
    island.tag = 9999;
    [dynamicWindow.rootViewController.view addSubview:island];

    [dynamicWindow makeKeyAndVisible];
}

%end
