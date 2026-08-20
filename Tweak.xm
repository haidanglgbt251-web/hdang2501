#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <AudioToolbox/AudioToolbox.h>

@interface HDangDynamicView : UIView
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) CGFloat originalWidth;
@property (nonatomic, assign) CGFloat originalHeight;
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
        
        // Camera dot
        UIView *cameraDot = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 22, frame.size.height/2 - 6, 12, 12)];
        cameraDot.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        cameraDot.layer.cornerRadius = 6;
        [self addSubview:cameraDot];
        
        // Gestures
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
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x - 60,
                                self.frame.origin.y - 10,
                                self.originalWidth + 120,
                                self.originalHeight + 20);
        self.layer.cornerRadius = self.frame.size.height / 2;
    }];
}

- (void)collapse {
    if (!self.isExpanded) return;
    self.isExpanded = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - self.originalWidth/2,
                                10,
                                self.originalWidth,
                                self.originalHeight);
        self.layer.cornerRadius = self.originalHeight / 2;
    }];
}

@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        HDangDynamicView *island = [[HDangDynamicView alloc] initWithFrame:CGRectMake(screenWidth/2 - 60, 10, 120, 35)];
        island.tag = 9999;
        
        UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
        if (keyWindow) {
            [keyWindow addSubview:island];
            [keyWindow bringSubviewToFront:island];
        }
    });
}

%end
