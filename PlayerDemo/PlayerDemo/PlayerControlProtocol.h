//
//  PlayerControlProtocol.h
//  PlayerDemo
//
//  Created by zhanggenning on 16/1/4.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerControlProtocol <NSObject>

@optional

//播放按钮点击
- (void)playerPlayBtnClicked;

//进度条值改变
- (void)playerSloderValueChangeEnd:(CGFloat)value;

//全屏按钮点击
- (void)playerScaleBtnClicked;

@end
