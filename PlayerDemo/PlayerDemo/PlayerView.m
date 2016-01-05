//
//  PlayerView.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/24.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"
#import "PlayerControlProtocol.h"

#import "PlayerControlBarBase.h"

static CGFloat const kPlayerControlBarShowTime = 5.0;

typedef NS_ENUM(NSInteger, PlayerState)
{
    PlayerIsStop = 0,  //视频已经停止
    PlayerIsBuffering, //视频缓冲中
    PlayerIsStart,     //视频已经开始
    PlayerIsFail,      //视频播放失败
};

@interface PlayerView ()<PlayerControlProtocol, UIGestureRecognizerDelegate>
{
    CGRect _selfFrame;
    CGRect _initFrame;
    BOOL _stopUpdateUI; //停止刷新UI
    
    NSTimer *_moniorTimer; //定时器
    CGFloat _controlBarShowTime;
    
    CGFloat _currentTime; //当前播放时间(单位 s)
    CGFloat _bufferTime; //缓冲时间(单位 s)
    CGFloat _durationTime; //总时长.(单位 s)
}

@property (nonatomic, copy) NSString *videoUrl; //视频url
@property (nonatomic, assign) PlayerState currentPlayerState; //播放器状态

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerItem *avPlayerItem;
@property (strong, nonatomic) PlayerControlBarBase *playerControlBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation PlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self deinitAVPlayer];
    
    NSLog(@"播放器释放");
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
    //移除定时器
    [self removeTimer];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview != NULL)
    {
        //添加定时器
        [self addTimer];
        
        //添加到父视图，自动播放
        if (_autoPlay && _avPlayer)
        {
            [_avPlayer play];
            
            [self swithPlayerState:PlayerIsStart];
        }
    }
}

- (void)layoutSubviews
{
    if (!CGRectEqualToRect(_selfFrame, self.frame))
    {
        _indicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        _playerControlBar.frame = CGRectMake(0, self.frame.size.height - 35, self.frame.size.width, 35);
        
        _selfFrame = self.frame;
        
        if (!CGRectEqualToRect(_selfFrame, [UIScreen mainScreen].bounds))
        {
            _initFrame = _selfFrame;
        }
    }
}


#pragma mark -- Private API
- (void)initAVPlayerWithUrl:(NSString *)url
{
    NSURL *videoUrl = [NSURL URLWithString:url];
    _avPlayerItem = [[AVPlayerItem alloc] initWithURL:videoUrl];
    _avPlayer = [[AVPlayer alloc] initWithPlayerItem:_avPlayerItem];
    
    AVPlayerLayer *playLayer = (AVPlayerLayer *)self.layer;
    playLayer.videoGravity = AVLayerVideoGravityResizeAspect; //视频填充模式
    playLayer.player= _avPlayer;
 
    //保存url
    _videoUrl = url;
    
    //添加播放结束监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)deinitAVPlayer
{
    //通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //释放播放源
    if (_avPlayer.currentItem)
    {
        [_avPlayer.currentItem cancelPendingSeeks];
        [_avPlayer.currentItem.asset cancelLoading];
        [_avPlayer replaceCurrentItemWithPlayerItem:nil];
    }
    
    //释放AVPlayer
    _avPlayer = nil;
}

- (void)addTimer
{
    if (!_moniorTimer)
    {
        _moniorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playerMonitorService) userInfo:nil repeats:YES];
    }
}

- (void)removeTimer
{
    if (_moniorTimer)
    {
        [_moniorTimer invalidate];
        _moniorTimer = nil;
    }
}

- (void)initUI
{
    //添加控制栏
    _playerControlBar = [PlayerControlBarBase playerControlBar];
    _playerControlBar.delegate = self;
    [self addSubview:_playerControlBar];
    
    //切换状态
    [self swithPlayerState:PlayerIsStop];
    
    //菊花
    self.indicatorView.hidden = YES;
    self.indicatorView.hidesWhenStopped = YES;

    //手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //关闭UI更新
    _stopUpdateUI = YES;
    
    //显示控制栏时间
    _controlBarShowTime = kPlayerControlBarShowTime;
}

//更新UI
- (void)updateUI
{
    if (_stopUpdateUI)
    {
        return;
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
            
        //更新视频时长
        strongSelf.playerControlBar.durationTime = _durationTime;
        
        //更新当前播放时间标签
        strongSelf.playerControlBar.currentTime = _currentTime;
        
        if (_durationTime != 0)
        {
            //更新播放进度
            strongSelf.playerControlBar.process = _currentTime / _durationTime;
            
            //更新缓冲进度
            strongSelf.playerControlBar.bufferProcess = _bufferTime / _durationTime;
        }
    });
}

//重置UI
- (void)resetUI
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //更新当前播放时间标签
        strongSelf.playerControlBar.currentTime = 0.0;
        
        //更新播放进度
        strongSelf.playerControlBar.process = 0.0;
        
    });
}

//监控UI
- (void)moniorUI
{
    //控制条
    if (_playerControlBar.isHidden == NO)
    {
        if (--_controlBarShowTime == 0)
        {
            [_playerControlBar hiddenControlBarWithAnimation:YES];
        }
    }
}

//监控播放器播放状态
- (void)moniorPlayerState
{
    if (!_avPlayer.currentItem)
    {
        NSLog(@"AVPlayerItem 为空.");
        
        return;
    }
    
    if (_avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) //准备播放时开始监控
    {
        _durationTime = CMTimeGetSeconds(_avPlayer.currentItem.duration);  //计算视频时长
        
        _currentTime = CMTimeGetSeconds(_avPlayer.currentItem.currentTime); //计算播放时间
        
        _bufferTime = [self availableDurationWithLoadedTimeRanges:_avPlayer.currentItem.loadedTimeRanges]; //缓冲时间
        
        if (_bufferTime != _durationTime && _currentTime >= _bufferTime - 2)
        {
            if (_currentPlayerState == PlayerIsStart)
            {
                [_avPlayer pause];
                
                [self swithPlayerState:PlayerIsBuffering];
            }
        }
        else
        {
            if (_currentPlayerState == PlayerIsBuffering)
            {
                [_avPlayer play];
                
                [self swithPlayerState:PlayerIsStart];
            }
        }
        
        //更新UI
        [self updateUI];
    }
    else if (_avPlayer.currentItem.status == AVPlayerItemStatusFailed)
    {
        [self swithPlayerState:PlayerIsFail];
    }
    else
    {
        [self swithPlayerState:PlayerIsBuffering];
    }
}

//改变播放状态
- (void)swithPlayerState:(PlayerState)state
{
    if (_currentPlayerState == state) {
        return;
    }
    
    switch (state)
    {
        case PlayerIsStop:
        {
            _stopUpdateUI = NO;
            
            _playerControlBar.playBtnState = kBtnStatePlay;
            
            [_indicatorView stopAnimating];
            
            NSLog(@"视频停止");
            break;
        }
        case PlayerIsStart:
        {
            _stopUpdateUI = NO;
            
            _playerControlBar.playBtnState = kBtnStatePause;
            
            [_indicatorView stopAnimating];
            
            NSLog(@"视频播放中");
            break;
        }
        case PlayerIsBuffering:
        {
            _stopUpdateUI = NO;
            
            _playerControlBar.playBtnState = kBtnStatePause;
            
            [_indicatorView startAnimating];
            
            NSLog(@"视频缓冲中");
            break;
        }
        case PlayerIsFail:
        {
            _stopUpdateUI = YES;
            
            _playerControlBar.playBtnState = kBtnStatePlay;
            
            NSLog(@"视频播放失败");
            break;
        }
        default:
            break;
    }
    
    _currentPlayerState = state;
}

//强制转屏幕
- (void)forceChangeDeviceOrientation:(UIDeviceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark -- Public API
+ (PlayerView *)playerViewWithUrl:(NSString *)url
{
    PlayerView *player = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerView class]) owner:nil options:nil] firstObject];
    
    player.autoresizingMask = UIViewAutoresizingNone;
    
    [player initUI];
    
    [player initAVPlayerWithUrl:url];

    [[NSNotificationCenter defaultCenter] addObserver:player selector:@selector(orientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    return player;
}

#pragma mark -- Events
//屏幕旋转通知
- (void)orientationDidChanged:(NSNotification *)note
{
#warning 注意：因为旋转过程中frame会变，为避免控制栏错乱，在旋转之前将其显示
    [_playerControlBar showControlBarWithAnimation:NO];

    switch ([UIDevice currentDevice].orientation)
    {
        case UIDeviceOrientationPortrait:
        {
            //隐藏控制栏
            _playerControlBar.alpha = 0;
            
            //回调到外部做进一步处理
            if (_delegate && [_delegate respondsToSelector:@selector(player:willSwitchToModel:)])
            {
                [_delegate player:self willSwitchToModel:PlayerModelNormal];
            }
            
            //执行转屏
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = _initFrame;
            }completion:^(BOOL finished) {
                _playerControlBar.alpha = 1;
                _playerControlBar.scaleBtnState = kBtnStateNormal;
                _playerModel = PlayerModelNormal;
            }];
            
            break;
        }
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            //隐藏控制栏
            _playerControlBar.alpha = 0;
            
            //回调到外部做进一步处理
            if (_delegate && [_delegate respondsToSelector:@selector(player:willSwitchToModel:)])
            {
                [_delegate player:self willSwitchToModel:PlayerModelFullScreen];
            }
            
            //执行转屏
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = [UIScreen mainScreen].bounds;
            } completion:^(BOOL finished) {
                _playerControlBar.alpha = 1;
                _playerControlBar.scaleBtnState = kBtnStateFullScreen;
                _playerModel = PlayerModelFullScreen;
            }];
            
            break;
        }
 
        default:
            break;
    }
}

//播放结束通知
- (void)moviePlayDidEnd
{
    __weak typeof(self) weakSelf = self;
    
    [self.avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //重置UI
        [strongSelf resetUI];
        
        [self swithPlayerState:PlayerIsStop];
        
        if (_delegate && [_delegate respondsToSelector:@selector(playerDidPlayEnd:)])
        {
            [_delegate playerDidPlayEnd:self];
        }
    }];
}

//监控服务
- (void)playerMonitorService
{
    //监控控制条
    [self moniorUI];
    
    //监控播放状态
    [self moniorPlayerState];
}

//单击隐藏控制栏
- (void)tapAction
{
    if (_playerControlBar.isHidden == NO)
    {
        [_playerControlBar hiddenControlBarWithAnimation:YES];
    }
    else
    {
        [_playerControlBar showControlBarWithAnimation:YES];
    }
}

#pragma mark -- Tools

- (NSTimeInterval)availableDurationWithLoadedTimeRanges:(NSArray *)loadedTimeRanges
{
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; //获取缓冲区
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; //计算缓冲总进度
    return result;
}

#pragma mark -- <PlayerControlProtocol>
- (void)playerPlayBtnClicked
{
    switch (_currentPlayerState)
    {
        case PlayerIsStop:
        {
            [_avPlayer play];
            [self swithPlayerState:PlayerIsStart];
            break;
        }
        case PlayerIsStart:
        {
            [_avPlayer pause];
            [self swithPlayerState:PlayerIsStop];
            break;
        }
        case PlayerIsBuffering:
        {
            [_avPlayer pause];
            [self swithPlayerState:PlayerIsStop];
            break;
        }
        case PlayerIsFail:
        {
            [self deinitAVPlayer];
            
            [self initAVPlayerWithUrl:_videoUrl];
            
            [_avPlayer play];
            
            [self swithPlayerState:PlayerIsStart];
            
            break;
        }
            
        default:
            break;
    }
}

//全屏按钮点击
- (void)playerScaleBtnClicked
{
    switch (_playerModel)
    {
        case PlayerModelNormal:
        {
            [self forceChangeDeviceOrientation:UIDeviceOrientationLandscapeLeft];
            
            break;
        }
        case PlayerModelFullScreen:
        {
            [self forceChangeDeviceOrientation:UIDeviceOrientationPortrait];
            
            break;
        }
        default:
            break;
    }
}

//进度条值改变
- (void)playerSloderValueChangeEnd:(CGFloat)value
{
    PlayerState ProPlayerState = _currentPlayerState;
    
    //停止刷新UI
    _stopUpdateUI = YES;
    
    //暂停视频
    if (_currentPlayerState == PlayerIsStart)
    {
        [_avPlayer pause];
    }
    
    //调整进度
    [_avPlayer seekToTime:CMTimeMake(_durationTime * value, 1) completionHandler:^(BOOL finished) {
        
        //恢复播放
        if (ProPlayerState == PlayerIsStart)
        {
            [_avPlayer play];
        }
        
        //开始刷新UI
        _stopUpdateUI = NO;
        
    }];
}

#pragma mark -- <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //点击事件发生，重置控制栏显示时间
    _controlBarShowTime = kPlayerControlBarShowTime;
    
    if ([touch.view isKindOfClass:[self class]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end