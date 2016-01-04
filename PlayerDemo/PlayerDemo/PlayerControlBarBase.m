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

@interface PlayerControlBarBase () <PlayerCustomSliderProtocol>
{
    CGRect _selfFrame;
}

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *curTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;
@property (weak, nonatomic) IBOutlet PlayerCustomSlider *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;

@end

@implementation PlayerControlBarBase

- (void)defaultUI
{
    self.playBtnState = kBtnStatePlay;
    self.currentTime = 0.0;
    self.durationTime = 0.0;
    self.process = 0.0;
    self.bufferProcess = 0.0;
    self.fullScreenBtnState = kBtnStateNormal;
    
    _isHidden = NO;
    
    self.clipsToBounds = YES;
    
    _sliderView.delegate = self;
    self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
}

- (void)layoutSubviews
{
    CGFloat timeLabWidth = 40.0; //时间label长度
    
    if (!CGRectEqualToRect(_selfFrame, self.frame))
    {
        _selfFrame = self.frame;
  
        //播放按钮
        _playBtn.frame = CGRectMake(8, 0, 30, 30);
        _playBtn.center = CGPointMake(_playBtn.frame.size.width / 2, _selfFrame.size.height / 2);
            
        //当前播放时间
        _curTimeLab.frame = CGRectMake(_playBtn.frame.origin.x + _playBtn.frame.size.width, 0, timeLabWidth, _selfFrame.size.height);
            
        //全屏按钮
        _fullScreenBtn.frame = CGRectMake(_selfFrame.size.width - timeLabWidth - 8, 0, timeLabWidth, _selfFrame.size.height);
            
        //视频时长
        _durationLab.frame = CGRectMake(_fullScreenBtn.frame.origin.x - timeLabWidth, 0, timeLabWidth, _selfFrame.size.height);
            
        //进度条
        CGFloat sliderStartX = _curTimeLab.frame.origin.x + timeLabWidth + 10;
        _sliderView.frame = CGRectMake(sliderStartX, 0, _durationLab.frame.origin.x - sliderStartX - 10, 20);
        _sliderView.center = CGPointMake(_sliderView.center.x, _selfFrame.size.height / 2);
    }
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

- (IBAction)fullScreenBtnCliced:(UIButton *)sender
{
    switch (_fullScreenBtnState)
    {
        case kBtnStateNormal:
        {
            self.fullScreenBtnState = kBtnStateFullState;
            break;
        }
        case kBtnStateFullState:
        {
            self.fullScreenBtnState = kBtnStateNormal;
            break;
        }
        default:
            break;
    }
 
    if (_delegate && [_delegate respondsToSelector:@selector(playerFullBtnClicked:)])
    {
        [_delegate playerFullBtnClicked:_fullScreenBtnState];
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

#pragma mark -- 公共API
+ (PlayerControlBarBase *)playerControlBar
{
    PlayerControlBarBase *controlBar = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayerControlBarBase class]) owner:nil options:nil] lastObject];
    
    controlBar.autoresizingMask = UIViewAutoresizingNone;
    
    [controlBar defaultUI];
    
    return controlBar;
}

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
- (void)setFullScreenBtnState:(FullScreenBtnState)fullScreenBtnState
{
    _fullScreenBtnState = fullScreenBtnState;
    
    switch (fullScreenBtnState)
    {
        case kBtnStateNormal:
        {
            [_fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
            break;
        }
        case kBtnStateFullState:
        {
            [_fullScreenBtn setTitle:@"普通" forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

//隐藏控制栏
- (void)hiddenControlBarWithAnimation:(BOOL)animate
{
    if (_isHidden == NO)
    {
        CGRect rect = self.frame;
        rect.origin.y = self.frame.origin.y + self.frame.size.height;
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (animate)
            {
                [UIView animateWithDuration:0.3 animations:^{
                self.frame = rect;
                }];
            }
            else
            {
                self.frame = rect;
            }
        
            _isHidden = YES;
        });
    
    }
}

//显示控制栏
- (void)showControlBarWithAnimation:(BOOL)animate
{
    if (_isHidden == YES)
    {
        CGRect rect = self.frame;
        rect.origin.y = self.frame.origin.y - self.frame.size.height;
        
        if (animate)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = rect;
            }];
        }
        else
        {
            self.frame = rect;
        }
        
        _isHidden = NO;
    }
}

@end
