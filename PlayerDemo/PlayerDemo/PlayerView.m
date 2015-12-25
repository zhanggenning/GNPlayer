//
//  PlayerView.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/24.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"
#import "PlayerSlider.h"

static NSString * const kTestUrl = @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA";

@interface PlayerView ()

{
    BOOL _isPlaying;
    BOOL _controlBarIsHidden;
    NSDateFormatter *_dateFormatter;
    id _playerTimeObserver;
}

@property (weak, nonatomic) AVPlayer *playerView;
@property (weak, nonatomic) AVPlayerItem *playerItem;

@property (weak, nonatomic) IBOutlet UIView *controlBar;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;
@property (weak, nonatomic) IBOutlet PlayerSlider *playerSlider;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

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
    [self.playerView removeTimeObserver:_playerTimeObserver];
}

- (void)awakeFromNib
{
    self.controlBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.playBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
    _isPlaying = NO;
    _controlBarIsHidden = NO;
    
    [self changePlayBtnState:_isPlaying];

    self.playerSlider.process = 0.0;
    self.playerSlider.bufferProcess = 0.0;
    
    self.currentTimeLab.text = @"00:00";
    self.durationLab.text = @"00:00";
}


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

- (void)changePlayBtnState:(BOOL)isPlaying
{
    if (!isPlaying)
    {
        [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn_h"] forState:UIControlStateHighlighted];
    }
    else
    {
        [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn_h"] forState:UIControlStateHighlighted];
    }
}

#pragma mark -- 公共api
+ (PlayerView *)playerView
{
    PlayerView *player = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerView class]) owner:nil options:nil] firstObject];
    player.autoresizingMask = UIViewAutoresizingNone;
    
    [player initAVPlayerWithUrl:kTestUrl];

    [player initUI];
    
    return player;
}


#pragma mark -- 事件
- (IBAction)playBtnEvent:(UIButton *)sender
{
    [_playerView play];
        
    _isPlaying = YES;
    
    [self changePlayBtnState:_isPlaying];
}

- (IBAction)sliderValueChangeEnd:(PlayerSlider *)sender
{
    CGFloat durationSeconds = CMTimeGetSeconds(_playerItem.duration);
    
    _isPlaying = NO;
    
    [self.playerView seekToTime:CMTimeMake(durationSeconds * sender.process, 1) completionHandler:^(BOOL finished) {
        _isPlaying = YES;
    }];
}

- (void)moviePlayDidEnd:(AVPlayerItem *)playerItem
{
    [self.playerView seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        _playerSlider.process = 0;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;

        if ([playerItem status] == AVPlayerItemStatusReadyToPlay) //视频载入成功
        {
            //更新视频时长
            CGFloat durationSeconds = CMTimeGetSeconds(playerItem.duration);
            self.durationLab.text = [self convertTime:durationSeconds];
            
            [_playerView addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
                
                if (_isPlaying)
                {
                    //更新当前播放时间label
                    CGFloat currentSeconds = CMTimeGetSeconds(_playerItem.currentTime);
                    _currentTimeLab.text = [self convertTime:currentSeconds];
                    
                    //更新进度
                    CGFloat durationSeconds = CMTimeGetSeconds(_playerItem.duration);
                    CGFloat process = currentSeconds / durationSeconds;
                    _playerSlider.process = process;
                    
                    //更新缓冲进度
                    NSTimeInterval bufferSeconds = [self availableDurationWithLoadedTimeRanges:_playerItem.loadedTimeRanges];
                    CGFloat bufferProcess = bufferSeconds / durationSeconds;
                    _playerSlider.bufferProcess = bufferProcess;
                    
                    NSLog(@"%f, %f", process, bufferProcess);
                }
                
            }];
        }
        else if ([playerItem status] == AVPlayerItemStatusFailed) //视频播放失败
        {
            //提示播放失败
            NSLog(@"播放失败");
        }
        else
        {
            //提示载入中
            NSLog(@"载入中");
        }
    }
    else if ([keyPath isEqualToString:@"rate"])
    {
        AVPlayer *player = (AVPlayer *)object;
        
        if (player.rate == 1.0)
        {
            NSLog(@"正在播放");
        }
        else
        {
            NSLog(@"已经停止");
        }
    }
}

@end
