//
//  PlayerControlBarBase.m
//  PlayerDemo
//
//  Created by zhanggenning on 16/1/4.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "PlayerControlBarBase.h"
#import "PlayerCustomSlider.h"
#import "PlayerControlProtocol.h"

static NSString * const kHiddenControlBar = @"controlBarHidden";

@interface PlayerControlBarBase () <PlayerCustomSliderProtocol>

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *curTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;
@property (weak, nonatomic) IBOutlet PlayerCustomSlider *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;

@end

@implementation PlayerControlBarBase

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHiddenControlBar object:nil];
}

- (void)defaultUI
{
    self.playBtnState = kBtnStatePlay;
    self.currentTime = 0.0;
    self.durationTime = 0.0;
    self.process = 0.0;
    self.bufferProcess = 0.0;
    self.scaleBtnState = kBtnStateNormal;
    self.clipsToBounds = YES;
    
    _sliderView.delegate = self;
    self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
}

#pragma mark -- 私有API
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

#pragma mark -- 事件
- (IBAction)playBtnClicked:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(playerPlayBtnClicked)])
    {
        [_delegate playerPlayBtnClicked];
    }
}

- (IBAction)fullScreenBtnClicked:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(playerScaleBtnClicked)])
    {
        [_delegate playerScaleBtnClicked];
    }
}

static

//SIGALRM信号捕捉
void signal_handler(int signo)
{
    if (signo == SIGALRM)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenControlBar object:nil];
    }
}

#pragma mark -- 属性
//播放状态
- (void)setPlayBtnState:(PlayBtnState)playBtnState
{
    _playBtnState = playBtnState;
    
    switch (playBtnState)
    {
        case kBtnStatePause:
        {
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_pause_btn_h"] forState:UIControlStateHighlighted];
            break;
        }
        case kBtnStatePlay:
        {
            [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"player_play_btn_h"] forState:UIControlStateHighlighted];
            break;
        }
        default:
            break;
    }
}

//播放时间
- (void)setCurrentTime:(CGFloat)currentTime
{
    _currentTime = currentTime;
    
    _curTimeLab.text = [self convertTime:currentTime];
}

//文件时间
- (void)setDurationTime:(CGFloat)durationTime
{
    _durationTime = durationTime;
    
    _durationLab.text = [self convertTime:durationTime];
}

//进度
- (void)setProcess:(CGFloat)process
{
    _process = process;
    
    _sliderView.process = process;
}

//缓冲进度
- (void)setBufferProcess:(CGFloat)bufferProcess
{
    _bufferProcess = bufferProcess;
    
    _sliderView.bufferProcess = bufferProcess;
}

//全屏状态
- (void)setScaleBtnState:(ScaleBtnState)scaleBtnState
{
    _scaleBtnState = scaleBtnState;
    
    switch (scaleBtnState)
    {
        case kBtnStateNormal:
        {
            [_fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
            break;
        }
        case kBtnStateFullScreen:
        {
            [_fullScreenBtn setTitle:@"普通" forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

- (CGRect)getBarFrameWithHidden:(BOOL)hiddenControlBar
{
    CGRect rect = self.frame;
    
    if (hiddenControlBar == YES)
    {
        rect.origin.y = self.frame.origin.y + self.frame.size.height;
    }
    else
    {
        rect.origin.y = self.frame.origin.y - self.frame.size.height;
    }
    
    return rect;
}


#pragma mark -- 公共API
+ (PlayerControlBarBase *)playerControlBar
{
    PlayerControlBarBase *controlBar = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerControlBarBase class]) owner:nil options:nil] lastObject];
    
    controlBar.autoresizingMask = UIViewAutoresizingNone;
    
    [controlBar defaultUI];
    
    signal(SIGALRM, signal_handler);
    
    [[NSNotificationCenter defaultCenter] addObserver:controlBar selector:@selector(hiddenBarWithAnimation) name:kHiddenControlBar object:nil];
    
    return controlBar;
}


- (void)hiddenBarWithAnimation
{
    if (_isHiddenBar == NO)
    {
        _isHiddenBar = YES;
        
        CGRect frame = [self getBarFrameWithHidden:_isHiddenBar];
        
        __weak typeof(self) weakSelf = self;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.frame = frame;
            
            _isHiddenBar = YES;
        }];
    }
}

- (void)showBarWithAnimation
{
    if (_isHiddenBar == YES)
    {
        _isHiddenBar = NO;
        
        CGRect frame = [self getBarFrameWithHidden:_isHiddenBar];
        
        __weak typeof(self) weakSelf = self;
            
        [UIView animateWithDuration:0.3 animations:^{
                
            __strong typeof(weakSelf) strongSelf = self;
                
            strongSelf.frame = frame;

        } completion:^(BOOL finished) {
                alarm(5);
        }];
    }
    else
    {
        alarm(5);
    }
}

#pragma mark -- 代理 <PlayerCustomSliderProtocol>
- (void)slider:(PlayerCustomSlider *)slider valueChangedEnd:(CGFloat) value
{
    if (_delegate && [_delegate respondsToSelector:@selector(playerSloderValueChangeEnd:)])
    {
        [_delegate playerSloderValueChangeEnd:value];
    }
}

@end