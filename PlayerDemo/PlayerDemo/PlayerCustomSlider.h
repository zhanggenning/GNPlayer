//
//  PlayerCustomSlider.h
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/29.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerCustomSliderProtocol;


@interface PlayerCustomSlider : UIView

@property (nonatomic, assign) CGFloat process;

@property (nonatomic, assign) CGFloat bufferProcess;

@property (nonatomic, weak) id<PlayerCustomSliderProtocol>delegate;

@end


@protocol PlayerCustomSliderProtocol <NSObject>

@optional

- (void)slider:(PlayerCustomSlider *)slider valueChangedBegin:(CGFloat) value;

- (void)slider:(PlayerCustomSlider *)slider valueChangedEnd:(CGFloat) value;

@end



