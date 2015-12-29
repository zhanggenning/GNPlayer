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

static NSString * const kTestUrl = @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA";

typedef NS_ENUM(NSInteger, PlayerState)
{
    PlayerIsStop = 0,  //视频已经停止
    PlayerIsStart,     //视频已经开始
    PlayerIsBuffering,  //视频缓冲中
};

@interface PlayerView ()<PlayerCustomSliderProtocol>

{
    BOOL _controlBarIsHidden;
    BOOL _stopUpdateUI; //停止刷新UI
    
    id _playerTimeObserver; //播放时间监听
    
    CGFloat _currentTime; //当前播放时间(单位 s)
    CGFloat _bufferTime; //缓冲时间(单位 s)
    CGFloat _durationTime; //总时长.(单位 s)
}

@property (nonatomic, assign) PlayerState currentPlayerState; //播放器状态

@property (weak, nonatomic) AVPlayer *playerView;
@property (weak, nonatomic) AVPlayerItem *playerItem;

@property (weak, nonatomic) IBOutlet UIView *controlBar;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet PlayerCustomSlider *playerSlider;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_controlBarHeight;

@end

@implementation PlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

-(void)dealloc
{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    
    [self.playerView removeObserver:self forKeyPath:@"rate"];
    
    [self.playerView removeTimeObserver:_playerTimeObserver];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:AVPlayerItemDidPlayToEndTimeNotification];
}

- (void)initAVPlayerWithUrl:(NSString *)url
{
    NSURL *videoUrl = [NSURL URLWithString:url];
    _playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    _playerView = [AVPlayer playerWithPlayerItem:_playerItem];
    AVPlayerLayer *layer = (AVPlayerLayer *)self.layer;
    layer.player= _playerView;
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.playerView addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];

}

- (void)initUI
{
    _controlBarIsHidden = NO;
    
    [self swithPlayerState:PlayerIsStop];

    //进度条
    self.playerSlider.process = 0.0;
    self.playerSlider.bufferProcess = 0.0;
    self.playerSlider.delegate = self;
    
    //时间
    self.currentTimeLab.text = @"00:00";
    self.durationLab.text = @"00:00";
}

- (void)updateUI
{
    __weak typeof(self) weakSelf = self;
    
    if (_stopUpdateUI)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //更新当前播放时间标签
        strongSelf.currentTimeLab.text = [strongSelf convertTime:_currentTime];
        
        //更新播放进度
        strongSelf.playerSlider.process = _currentTime / _durationTime;
        
        //更新缓冲进度
        strongSelf.playerSlider.bufferProcess = _bufferTime / _durationTime;
        
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
            [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn_h"] forState:UIControlStateHighlighted];
            break;
        }
        case PlayerIsStart:
        {
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn_h"] forState:UIControlStateHighlighted];
            break;
        }
        case PlayerIsBuffering:
        {
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn_h"] forState:UIControlStateHighlighted];
            break;
        }
        default:
            break;
    }
    
    _currentPlayerState = state;
}


#pragma mark -- Public API
+ (PlayerView *)playerView
{
    PlayerView *player = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerView class]) owner:nil options:nil] firstObject];
    player.autoresizingMask = UIViewAutoresizingNone;
    
    [player initAVPlayerWithUrl:kTestUrl];

    [player initUI];
    
    return player;
}


#pragma mark -- Events
//播放按钮事件
- (IBAction)playBtnEvent:(UIButton *)sender
{
    if (_currentPlayerState == PlayerIsStop)
    {
        [_playerView play];
    }
    else
    {
        [_playerView pause];
    }
}

//播放结束
- (void)moviePlayDidEnd:(AVPlayerItem *)playerItem
{
    __weak typeof(self) weakSelf = self;
    
    [self.playerView seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //重置UI
        [strongSelf resetUI];
        
        //移除监听
        [self.playerView removeTimeObserver:_playerTimeObserver];
        _playerTimeObserver = nil;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"status"])
    {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;

        if ([playerItem status] == AVPlayerItemStatusReadyToPlay) //视频载入成功
        {
            NSLog(@"视频载入成功");
            
            //计算视频时长
            _durationTime = CMTimeGetSeconds(playerItem.duration);
            
            //更新视频时长
            self.durationLab.text = [self convertTime:_durationTime];
            
            //计算播放时长
            if (_playerTimeObserver)
            {
                [_playerView removeTimeObserver:_playerTimeObserver];
                _playerTimeObserver = nil;
            }
            
            __weak typeof(self) weakSelf = self;
            _playerTimeObserver = [_playerView addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
 
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if (_currentPlayerState == PlayerIsStart)
                {
                    _currentTime = CMTimeGetSeconds(_playerItem.currentTime); //计算播放时间
                    
                    _bufferTime = [strongSelf availableDurationWithLoadedTimeRanges:_playerItem.loadedTimeRanges]; //缓冲时间
                    
                    [strongSelf updateUI]; //更新UI
                }
                
            }];
        }
        else //视频播放失败
        {
            NSLog(@"播放失败");
        }
    }
    else if ([object isKindOfClass:[AVPlayer class]] && [keyPath isEqualToString:@"rate"])
    {
        AVPlayer *player = (AVPlayer *)object;
        
        if (player.rate == 1.0)
        {
            [self swithPlayerState:PlayerIsStart];
        }
        else
        {
            [self swithPlayerState:PlayerIsStop];
        }
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
        [_playerView pause];
    }
    
    //调整进度
    [_playerView seekToTime:CMTimeMake(_durationTime * value, 1) completionHandler:^(BOOL finished) {
        
        //恢复播放
        if (ProPlayerState == PlayerIsStart)
        {
            [_playerView play];
        }
     
        //开始刷新UI
        _stopUpdateUI = NO;
        
    }];
}

@end
