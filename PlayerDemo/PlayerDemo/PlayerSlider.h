//
//  PlayerSlider.h
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/25.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerSlider : UIControl

@property (nonatomic, assign) CGFloat process;

@property (nonatomic, assign) CGFloat bufferProcess;

@property (nonatomic, assign) UIColor *minimumTrackTintColor;

@property (nonatomic, assign) UIColor *maximumTrackTintColor;

@property (nonatomic, assign) UIColor *bufferTrackTintColor;

@end
