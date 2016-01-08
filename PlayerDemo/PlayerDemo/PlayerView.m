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
    BOOL _stopUpdateUI; //停止刷新UI

    CGFloat _controlBarShowTime;
    dispatch_source_t _timer; //定时器
    
    CGFloat _currentTime; //当前播放时间(单位 s)
    CGFloat _bufferTime; //缓冲时间(单位 s)
    CGFloat _durationTime; //总时长.(单位 s)
}

@property (nonatomic, assign) PlayerState playerState; //播放器状态
@property (nonatomic, assign) PlayerModel playerModel; //全屏状态

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
    
    [self removeTimer];
    
    [self destoryAVPlayer];
    
    NSLog(@"播放器释放");
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview != NULL)
    {
        //添加到父视图，自动播放
        if (_autoPlay && _avPlayer)
        {
            [_avPlayer play];
            
            self.playerState = PlayerIsStart;
        }
    }
}

- (void)layoutSubviews
{
    if (!CGRectEqualToRect(_selfFrame, self.bounds))
    {
        _indicatorView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        
        if (_playerControlBar)
        {
#warning 这里playerControlBar需要回归原位
            [_playerControlBar showBarWithAnimation];
  
            _playerControlBar.frame = CGRectMake(0, self.bounds.size.height - 35, self.bounds.size.width, 35);
        }
        
        _selfFrame = self.bounds;
    }
}

#pragma mark -- Private API
- (void)createAVPlayerWithUrl:(NSString *)url
{
    NSURL *videoUrl = [NSURL URLWithString:url];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:videoUrl];
    _avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    
    AVPlayerLayer *playLayer = (AVPlayerLayer *)self.layer;
    playLayer.videoGravity = AVLayerVideoGravityResizeAspect; //视频填充模式
    playLayer.player= _avPlayer;
 
    //添加播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)destoryAVPlayer
{
    //移除播放结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //释放播放源
    if (_avPlayer && _avPlayer.currentItem)
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
    NSTimeInterval period = 1.0; //设置时间间隔
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, period * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf playerMonitorService];
    });
    
    dispatch_source_set_cancel_handler(_timer, ^{
        NSLog(@"取消定时器");
    });
    dispatch_resume(_timer);

}

- (void)removeTimer
{
    dispatch_source_cancel(_timer);
}

- (void)initUI
{
    //添加控制栏
    _playerControlBar = [PlayerControlBarBase playerControlBar];
    [_playerControlBar showBarWithAnimation];

    _playerControlBar.delegate = self;
    [self addSubview:_playerControlBar];
    
    //切换状态
    self.playerState = PlayerIsStop;
    
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
        
        [_playerControlBar showBarWithAnimation];
  
        //更新当前播放时间标签
        strongSelf.playerControlBar.currentTime = 0.0;
        
        //更新播放进度
        strongSelf.playerControlBar.process = 0.0;
        
        //更新缓冲进度
        strongSelf.playerControlBar.bufferProcess = 0.0;
    });
}

//监控播放器播放状态
- (void)moniorPlayerState
{
    if (!_avPlayer || !_avPlayer.currentItem)
    {
        NSLog(@"AVPlayerItem 为空.");
        
        return;
    }
    
    if (_avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) //准备播放时开始监控
    {
        _durationTime = CMTimeGetSeconds(_avPlayer.currentItem.duration);  //计算视频时长
        
        _currentTime = CMTimeGetSeconds(_avPlayer.currentItem.currentTime); //计算播放时间
        
        _bufferTime = [self availableDurationWithLoadedTimeRanges:_avPlayer.currentItem.loadedTimeRanges]; //缓冲时间
        
        if ((NSInteger)_bufferTime != (NSInteger)_durationTime && _currentTime >= _bufferTime - 2)
        {
            if (_playerState == PlayerIsStart)
            {
                [_avPlayer pause];
                
                self.playerState = PlayerIsBuffering;
            }
        }
        else
        {
            if (_playerState == PlayerIsBuffering)
            {
                [_avPlayer play];
                
                self.playerState = PlayerIsStart;
            }
        }
        
        //更新UI
        if (!_stopUpdateUI)
        {
            [self updateUI];
        }
        
    }
    else if (_avPlayer.currentItem.status == AVPlayerItemStatusFailed)
    {
        self.playerState = PlayerIsFail;
    }
    else
    {
        self.playerState = PlayerIsBuffering;
    }
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
    
    player.videoUrl = url;
    
    [player initUI];
    
    [player addTimer];

    [[NSNotificationCenter defaultCenter] addObserver:player selector:@selector(orientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    return player;
}

#pragma mark -- Events
//屏幕旋转通知
- (void)orientationDidChanged:(NSNotification *)note
{
    switch ([UIDevice currentDevice].orientation)
    {
        case UIDeviceOrientationPortrait:
        {
            if (self.playerModel != PlayerModelNormal)
            {
                self.playerModel = PlayerModelNormal;
 
                if (_delegate && [_delegate respondsToSelector:@selector(player:willSwitchToModel:)])
                {
                    [_delegate player:self willSwitchToModel:_playerModel];
                }
            }

            break;
        }
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            if (self.playerModel != PlayerModelFullScreen)
            {
                self.playerModel = PlayerModelFullScreen;
            
                if (_delegate && [_delegate respondsToSelector:@selector(player:willSwitchToModel:)])
                {
                    [_delegate player:self willSwitchToModel:_playerModel];
                }
            }
 
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
        
        self.playerState = PlayerIsStop;
        
        if (_delegate && [_delegate respondsToSelector:@selector(playerDidPlayEnd:)])
        {
            [_delegate playerDidPlayEnd:self];
        }
    }];
}

//监控服务
- (void)playerMonitorService
{
    //监控播放状态
    [self moniorPlayerState];
}

//单击隐藏控制栏
- (void)tapAction
{
    if (_playerControlBar.isHiddenBar)
    {
        [_playerControlBar showBarWithAnimation];
    }
    else
    {
        [_playerControlBar showBarWithAnimation];
    }
}


#pragma mark -- Property
- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl;
    
    if (_avPlayer)
    {
        [self destoryAVPlayer];
    }

    usleep(10 * 1000);
    
    [self createAVPlayerWithUrl:videoUrl];
}


//设置播放状态
- (void)setPlayerState:(PlayerState)playerState
{
    if (_playerState == playerState)
    {
        return;
    }
    
    //主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (playerState)
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

    });
    
    _playerState = playerState;
}

//设置播放模式
- (void)setPlayerModel:(PlayerModel)playerModel
{
    _playerModel = playerModel;
    
    switch (playerModel)
    {
        case PlayerModelNormal:
        {
            _playerControlBar.scaleBtnState = kBtnStateNormal;
            break;
        }
        case PlayerModelFullScreen:
        {
            _playerControlBar.scaleBtnState = kBtnStateFullScreen;
            break;
        }
        default:
            break;
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
    switch (_playerState)
    {
        case PlayerIsStop:
        {
            [_avPlayer play];
            self.playerState = PlayerIsStart;
            break;
        }
        case PlayerIsStart:
        {
            [_avPlayer pause];
            self.playerState = PlayerIsStop;
            break;
        }
        case PlayerIsBuffering:
        {
            [_avPlayer pause];
            self.playerState = PlayerIsStop;
            break;
        }
        case PlayerIsFail:
        {
            [self destoryAVPlayer];
            
            [self createAVPlayerWithUrl:_videoUrl];
            
            [_avPlayer play];
            
            self.playerState = PlayerIsStart;
  
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
    PlayerState ProPlayerState = _playerState;
    
    //停止刷新UI
    _stopUpdateUI = YES;
    
    //暂停视频
    if (_playerState == PlayerIsStart)
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