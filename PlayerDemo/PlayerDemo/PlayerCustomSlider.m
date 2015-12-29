//
//  PlayerCustomSlider.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/29.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "PlayerCustomSlider.h"

static const CGFloat kSliderHeight = 4; //进度条宽度
static const CGFloat kSliderThumbHeight = 20; //正方形滑块边长

@interface PlayerCustomSlider ()
{
    UIView *_sliderView;
    CALayer *_processLayer;
    CALayer *_bufferProcessLayer;
    UIImageView *_thumbView;

}
@end

@implementation PlayerCustomSlider

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
    
    //进度条
    _sliderView = [[UIView alloc] init];
    _sliderView.backgroundColor = [UIColor lightGrayColor];
    
    _bufferProcessLayer = [CALayer layer];
    _bufferProcessLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [_sliderView.layer addSublayer:_bufferProcessLayer];
    
    _processLayer = [CALayer layer];
    _processLayer.backgroundColor = [UIColor blueColor].CGColor;
    [_sliderView.layer addSublayer:_processLayer];
    [self addSubview:_sliderView];
    
    //滑块
    _thumbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"player_slider_thumb_btn"]];
    _thumbView.userInteractionEnabled = YES;
    [self addSubview:_thumbView];
    
    //手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [_thumbView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tap];
}


- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    //背景view
    _sliderView.frame = CGRectMake(layer.bounds.origin.x,
                                   layer.bounds.size.height / 2 - kSliderHeight / 2,
                                   layer.bounds.size.width,
                                   kSliderHeight);
    
    //进度layer
    _processLayer.frame = [self dstRectWithSrcRect:_sliderView.bounds withProcess:_process];
    _bufferProcessLayer.frame = [self dstRectWithSrcRect:_sliderView.bounds withProcess:_bufferProcess];
    
    //滑块
    _thumbView.frame = CGRectMake(0, 0, kSliderThumbHeight, kSliderThumbHeight);
    _thumbView.center = CGPointMake(self.bounds.size.width * _process,
                                     self.bounds.size.height / 2);
}


#pragma mark -- Private API
- (CGRect)dstRectWithSrcRect:(CGRect)rect withProcess:(CGFloat)process
{
    CGRect tmp = rect;
    tmp.size.width = rect.size.width * process;
    return tmp;
}

#pragma mark -- Event
- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(slider:valueChangedBegin:)])
            {
                [_delegate slider:self valueChangedBegin:_process];
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self updateProgressWithGestureReconizer:pan];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(slider:valueChangedEnd:)])
            {
                [_delegate slider:self valueChangedEnd:_process];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap
{
    CGPoint locationInSlider = [tap locationInView:self];

    if (locationInSlider.x < self.bounds.origin.x)
    {
        locationInSlider.x = self.bounds.origin.x;
    }
    else if (locationInSlider.x > self.bounds.origin.x + self.bounds.size.width)
    {
        locationInSlider.x = (self.bounds.origin.x + self.bounds.size.width);
    }
    
    self.process = locationInSlider.x / _sliderView.bounds.size.width;
    
    if (_delegate && [_delegate respondsToSelector:@selector(slider:valueChangedEnd:)])
    {
        [_delegate slider:self valueChangedEnd:_process];
    }
}

- (void)updateProgressWithGestureReconizer:(UIGestureRecognizer *)gesture
{
    CGPoint locationInSlider =  [gesture locationInView:_sliderView];
    
    if (locationInSlider.x < _sliderView.bounds.origin.x)
    {
        locationInSlider.x = _sliderView.bounds.origin.x;
    }
    else if (locationInSlider.x > (_sliderView.bounds.origin.x + _sliderView.bounds.size.width))
    {
        locationInSlider.x = _sliderView.bounds.origin.x + _sliderView.bounds.size.width;
    }
    
    self.process = locationInSlider.x / _sliderView.bounds.size.width;
}

#pragma mark - Property
- (void)setProcess:(CGFloat)process
{
    _process = process;

    _thumbView.center = CGPointMake(_sliderView.bounds.size.width * process, _thumbView.center.y);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _processLayer.frame = [self dstRectWithSrcRect:_sliderView.bounds withProcess:process];
    [CATransaction commit];
}

- (void)setBufferProcess:(CGFloat)bufferProcess
{
    _bufferProcess = bufferProcess;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _bufferProcessLayer.frame = [self dstRectWithSrcRect:_sliderView.bounds withProcess:bufferProcess];
    [CATransaction commit];
}

@end
