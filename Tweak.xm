#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface HDangDynamicView : UIView
@property (nonatomic, strong) UIView *expandedView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIImageView *albumArtView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) UIView *cameraDot;
@property (nonatomic, strong) UIView *sensorDot;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL isShowingMusic;
@property (nonatomic, assign) BOOL isShowingCall;
@property (nonatomic, assign) BOOL isShowingBattery;
@property (nonatomic, assign) BOOL isShowingTimer;
@property (nonatomic, assign) CGFloat originalWidth;
@property (nonatomic, assign) CGFloat originalHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@end

@implementation HDangDynamicView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.layer.masksToBounds = YES;
    self.originalWidth = self.frame.size.width;
    self.originalHeight = self.frame.size.height;
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.isExpanded = NO;
    
    [self createCameraDot];
    [self createSensorDot];
    [self addGestures];
    [self startUpdateTimer];
    [self registerForNotifications];
}

- (void)createCameraDot {
    self.cameraDot = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 22, self.frame.size.height/2 - 6, 12, 12)];
    self.cameraDot.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    self.cameraDot.layer.cornerRadius = 6;
    [self addSubview:self.cameraDot];
}

- (void)createSensorDot {
    self.sensorDot = [[UIView alloc] initWithFrame:CGRectMake(10, self.frame.size.height/2 - 4, 8, 8)];
    self.sensorDot.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    self.sensorDot.layer.cornerRadius = 4;
    self.sensorDot.alpha = 0.5;
    [self addSubview:self.sensorDot];
}

- (void)addGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:tap];
    
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

- (void)handleLongPress {
    [self expand];
    AudioServicesPlaySystemSound(1519);
}

- (void)expand {
    if (self.isExpanded) return;
    self.isExpanded = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.frame = CGRectMake(self.frame.origin.x - 60,
                                self.frame.origin.y - 10,
                                self.originalWidth + 120,
                                self.originalHeight + 20);
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.cameraDot.alpha = 0;
        self.sensorDot.alpha = 0;
    } completion:nil];
}

- (void)collapse {
    if (!self.isExpanded) return;
    self.isExpanded = NO;
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.frame = CGRectMake(self.screenWidth/2 - self.originalWidth/2,
                                10,
                                self.originalWidth,
                                self.originalHeight);
        self.layer.cornerRadius = self.originalHeight / 2;
        self.cameraDot.alpha = 1;
        self.sensorDot.alpha = 0.5;
        
        [self.titleLabel removeFromSuperview];
        [self.subtitleLabel removeFromSuperview];
        [self.iconView removeFromSuperview];
        [self.albumArtView removeFromSuperview];
        [self.progressView removeFromSuperview];
        self.titleLabel = nil;
        self.subtitleLabel = nil;
        self.iconView = nil;
        self.albumArtView = nil;
        self.progressView = nil;
    } completion:nil];
}

- (void)startUpdateTimer {
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(updateBattery)
                                                      userInfo:nil
                                                       repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
}

- (void)updateBattery {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    
    if (batteryLevel <= 0.2) {
        [self showBattery:batteryLevel];
    }
}

- (void)showBattery:(CGFloat)level {
    if (self.isShowingBattery) return;
    self.isShowingBattery = YES;
    
    if (!self.isExpanded) {
        [self expand];
    }
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.frame.size.height/2 - 12, 24, 24)];
    self.iconView.image = [UIImage systemImageNamed:@"battery.25"];
    self.iconView.tintColor = [UIColor redColor];
    [self addSubview:self.iconView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 60, 20)];
    self.titleLabel.text = [NSString stringWithFormat:@"%.0f%%", level * 100];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 22, 80, 12)];
    self.subtitleLabel.text = @"Low Battery";
    self.subtitleLabel.font = [UIFont systemFontOfSize:10];
    self.subtitleLabel.textColor = [UIColor redColor];
    [self addSubview:self.subtitleLabel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self collapse];
        self.isShowingBattery = NO;
    });
}

- (void)showMusic:(MPMediaItem *)song {
    if (self.isShowingMusic) return;
    self.isShowingMusic = YES;
    
    [self expand];
    
    self.albumArtView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    self.albumArtView.layer.cornerRadius = 20;
    self.albumArtView.layer.masksToBounds = YES;
    self.albumArtView.backgroundColor = [UIColor grayColor];
    [self addSubview:self.albumArtView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, self.frame.size.width - 70, 20)];
    self.titleLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, self.frame.size.width - 70, 15)];
    self.subtitleLabel.text = [song valueForProperty:MPMediaItemPropertyArtist];
    self.subtitleLabel.font = [UIFont systemFontOfSize:11];
    self.subtitleLabel.textColor = [UIColor grayColor];
    [self addSubview:self.subtitleLabel];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(60, 50, self.frame.size.width - 70, 2)];
    self.progressView.progressTintColor = [UIColor whiteColor];
    self.progressView.trackTintColor = [UIColor grayColor];
    [self addSubview:self.progressView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self collapse];
        self.isShowingMusic = NO;
    });
}

- (void)showCall:(NSString *)callerName {
    if (self.isShowingCall) return;
    self.isShowingCall = YES;
    
    [self expand];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.frame.size.height/2 - 12, 24, 24)];
    self.iconView.image = [UIImage systemImageNamed:@"phone.fill"];
    self.iconView.tintColor = [UIColor greenColor];
    [self addSubview:self.iconView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, self.frame.size.width - 60, 20)];
    self.titleLabel.text = callerName;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 22, self.frame.size.width - 60, 12)];
    self.subtitleLabel.text = @"Incoming Call";
    self.subtitleLabel.font = [UIFont systemFontOfSize:10];
    self.subtitleLabel.textColor = [UIColor grayColor];
    [self addSubview:self.subtitleLabel];
}

- (void)showTimer:(NSTimeInterval)remainingTime {
    if (self.isShowingTimer) return;
    self.isShowingTimer = YES;
    
    [self expand];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.frame.size.height/2 - 12, 24, 24)];
    self.iconView.image = [UIImage systemImageNamed:@"timer"];
    self.iconView.tintColor = [UIColor orangeColor];
    [self addSubview:self.iconView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, self.frame.size.width - 60, 20)];
    self.titleLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)remainingTime / 60, (int)remainingTime % 60];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 22, self.frame.size.width - 60, 12)];
    self.subtitleLabel.text = @"Timer";
    self.subtitleLabel.font = [UIFont systemFontOfSize:10];
    self.subtitleLabel.textColor = [UIColor grayColor];
    [self addSubview:self.subtitleLabel];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMusicNotification:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBatteryNotification:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                               object:nil];
}

- (void)handleMusicNotification:(NSNotification *)notification {
    MPMusicPlayerController *player = [MPMusicPlayerController systemMusicPlayer];
    MPMediaItem *nowPlaying = player.nowPlayingItem;
    
    if (nowPlaying) {
        [self showMusic:nowPlaying];
    }
}

- (void)handleBatteryNotification:(NSNotification *)notification {
    [self updateBattery];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupHDangDynamic];
    });
}

%new
- (void)setupHDangDynamic {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat islandWidth = 120;
    CGFloat islandHeight = 35;
    
    HDangDynamicView *island = [[HDangDynamicView alloc] initWithFrame:CGRectMake(
        screenWidth/2 - islandWidth/2,
        10,
        islandWidth,
        islandHeight
    )];
    island.tag = 9999;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        [keyWindow addSubview:island];
        [keyWindow bringSubviewToFront:island];
    }
}

%end

%hook SBLockScreenViewController

- (void)viewDidLoad {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addDynamicIslandToLockScreen];
    });
}

%new
- (void)addDynamicIslandToLockScreen {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    HDangDynamicView *island = [[HDangDynamicView alloc] initWithFrame:CGRectMake(
        screenWidth/2 - 60,
        10,
        120,
        35
    )];
    island.tag = 9999;
    [self.view addSubview:island];
    [self.view bringSubviewToFront:island];
}

%end
