//
//  PlayerSlider.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/25.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "PlayerSlider.h"
#import <objc/message.h>

@interface PlayerSlider ()
{
    UISlider *_sliderView;
    UIProgressView *_processView;
    
    id _target;
    SEL _action;
}
@end


@implementation PlayerSlider

- (instancetype)init
{
    if (self = [super init])
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}


- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    
    _sliderView = [[UISlider alloc] init];
    
    UIImage *thumbImage = [UIImage imageNamed:@"player_slider_thumb_btn"];
    NSData *data = UIImagePNGRepresentation(thumbImage);
    [_sliderView setThumbImage:[UIImage imageWithData:data scale:3] forState:UIControlStateNormal];
    
    _sliderView.minimumTrackTintColor = [UIColor blueColor];
    _sliderView.maximumTrackTintColor = [UIColor clearColor];
    _sliderView.minimumValue = 0;
    _sliderView.maximumValue = 1.0;
    [self addSubview:_sliderView];
    
    _processView = [[UIProgressView alloc] init];
    _processView.trackTintColor = [UIColor lightGrayColor];
    _processView.progressTintColor = [UIColor whiteColor];
    _processView.progress = 0;
    _processView.userInteractionEnabled = NO;
    
    [_sliderView addSubview:_processView];
    [_sliderView sendSubviewToBack:_processView];
}

- (void)layoutSubviews
{
    _sliderView.frame = self.bounds;
    
    CGRect rect = _sliderView.bounds;
    rect.origin.x += 2;
    rect.size.width -= 2*2;
    _processView.frame = rect;
    _processView.center = CGPointMake(_sliderView.bounds.size.width / 2, _sliderView.bounds.size.height / 2);
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    _target = target;
    _action = action;
    
    [_sliderView addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onSliderValueChange:(UISlider *)slider
{
    _process = slider.value; //保存当前的process
    
    objc_msgSend(_target, _action, self); //消息转发
}

#pragma mark -- 公共API
- (void)setProcess:(CGFloat)process
{
    _process = process;

    _sliderView.value = process;
}

- (void)setBufferProcess:(CGFloat)bufferProcess
{
    _bufferProcess = bufferProcess;
    
    _processView.progress = bufferProcess;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor
{
    _minimumTrackTintColor = minimumTrackTintColor;
    
    _sliderView.minimumTrackTintColor = minimumTrackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor
{
    _maximumTrackTintColor = maximumTrackTintColor;
    
    _processView.progressTintColor = maximumTrackTintColor;
}

- (void)setBufferTrackTintColor:(UIColor *)bufferTrackTintColor
{
    _bufferTrackTintColor = bufferTrackTintColor;
    
    _processView.trackTintColor = bufferTrackTintColor;
}

@end
