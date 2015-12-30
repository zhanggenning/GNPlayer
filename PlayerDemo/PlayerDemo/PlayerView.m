//
//  PlayerView.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/24.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"
#import "PlayerCustomSlider.h"

typedef NS_ENUM(NSInteger, PlayerState)
{
    PlayerIsStop = 0,  //视频已经停止
    PlayerIsBuffering, //视频缓冲中
    PlayerIsStart,     //视频已经开始
    PlayerIsFail,      //视频播放失败
};

@interface PlayerView ()<PlayerCustomSliderProtocol, UIGestureRecognizerDelegate>

{
    BOOL _stopUpdateUI; //停止刷新UI
    
    NSTimer *_moniorTimer; //定时器
    
    CGFloat _currentTime; //当前播放时间(单位 s)
    CGFloat _bufferTime; //缓冲时间(单位 s)
    CGFloat _durationTime; //总时长.(单位 s)
}

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, assign) PlayerState currentPlayerState; //播放器状态

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerItem *avPlayerItem;

@property (weak, nonatomic) IBOutlet UIView *controlBar;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet PlayerCustomSlider *playerSlider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation PlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)dealloc
{
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
        //添加到父视图，自动播放
        if (_isAutoPlay && _avPlayer)
        {
            [_avPlayer play];
            
            [self swithPlayerState:PlayerIsStart];
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
    playLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; //视频填充模式
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
        _moniorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playTimeMonior) userInfo:nil repeats:YES];
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
    [self swithPlayerState:PlayerIsStop];
    
    self.controlBar.alpha = 0;
  
    //进度条
    self.playerSlider.process = 0.0;
    self.playerSlider.bufferProcess = 0.0;
    self.playerSlider.delegate = self;
    
    //时间
    self.currentTimeLab.text = @"00:00";
    self.durationLab.text = @"00:00";

    //菊花
    self.indicatorView.hidden = YES;
    self.indicatorView.hidesWhenStopped = YES;

    //手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //关闭UI更新
    _stopUpdateUI = YES;
}

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
        self.durationLab.text = [self convertTime:_durationTime];
        
        //更新当前播放时间标签
        strongSelf.currentTimeLab.text = [strongSelf convertTime:_currentTime];
        
        if (_durationTime != 0)
        {
            //更新播放进度
            strongSelf.playerSlider.process = _currentTime / _durationTime;
            
            //更新缓冲进度
            strongSelf.playerSlider.bufferProcess = _bufferTime / _durationTime;
        }
    });
}

- (void)resetUI
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //更新当前播放时间标签
        strongSelf.currentTimeLab.text = @"00:00";
        
        //更新播放进度
        strongSelf.playerSlider.process = 0.0;
        
    });
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
            
            [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn_h"] forState:UIControlStateHighlighted];
            
            [_indicatorView stopAnimating];
            
            NSLog(@"视频停止");
            break;
        }
        case PlayerIsStart:
        {
            _stopUpdateUI = NO;
            
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn_h"] forState:UIControlStateHighlighted];
            
            [_indicatorView stopAnimating];
            
            NSLog(@"视频播放中");
            break;
        }
        case PlayerIsBuffering:
        {
            _stopUpdateUI = NO;
            
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn_h"] forState:UIControlStateHighlighted];
            
            [_indicatorView startAnimating];
            
            NSLog(@"视频缓冲中");
            break;
        }
        case PlayerIsFail:
        {
            _stopUpdateUI = YES;
            
            [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn_h"] forState:UIControlStateHighlighted];
            
            NSLog(@"视频播放失败");
            break;
        }
        default:
            break;
    }
    
    _currentPlayerState = state;
}


#pragma mark -- Public API
+ (PlayerView *)playerViewWithUrl:(NSString *)url
{
    PlayerView *player = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerView class]) owner:nil options:nil] firstObject];
    
    player.autoresizingMask = UIViewAutoresizingNone;
    
    [player initUI];
    
    [player initAVPlayerWithUrl:url];
    
    [player addTimer];

    return player;
}


#pragma mark -- Events
//播放按钮事件
- (IBAction)playBtnEvent:(UIButton *)sender
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

//播放结束
- (void)moviePlayDidEnd
{
    __weak typeof(self) weakSelf = self;
    
    [self.avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //重置UI
        [strongSelf resetUI];
        
        [self swithPlayerState:PlayerIsStop];
    
    }];
}

//播放时间监控
- (void)playTimeMonior
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

//单击隐藏控制栏
- (void)tapAction
{
    if (_controlBar.alpha == 1)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            _controlBar.alpha = 0;
        }];
    } else if (_controlBar.alpha == 0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            _controlBar.alpha = 1;
        }];
    }
    if (_controlBar.alpha == 1)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _controlBar.alpha = 0;
            }];
            
        });
    }
}

#pragma mark -- Tools
//转换时间格式
- (NSString *)convertTime:(CGFloat)second
{
    static NSDateFormatter *dateFormatter = nil;
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    if (second/3600 >= 1)
    {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    else
    {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [dateFormatter stringFromDate:d];
    
    return showtimeNew;
}

- (NSTimeInterval)availableDurationWithLoadedTimeRanges:(NSArray *)loadedTimeRanges
{
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; //获取缓冲区
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; //计算缓冲总进度
    return result;
}

#pragma mark -- <PlayerCustomSliderProtocol>

- (void)slider:(PlayerCustomSlider *)slider valueChangedEnd:(CGFloat)value
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
