//
//  PlayerControlBarBase.h
//  PlayerDemo
//
//  Created by zhanggenning on 16/1/4.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerControlProtocol;

//播放按钮的状态
typedef NS_ENUM(NSInteger, PlayBtnState)
{
    kBtnStatePause = 0,  //暂停状态
    kBtnStatePlay        //播放状态
};

typedef NS_ENUM(NSInteger, ScaleBtnState)
{
    kBtnStateNormal = 0, //常规状态
    kBtnStateFullScreen  //全屏状态
};

@interface PlayerControlBarBase : UIView

@property (nonatomic, assign) PlayBtnState playBtnState; //播放状态（播放/暂停）

@property (nonatomic, assign) CGFloat currentTime; //播放时间

@property (nonatomic, assign) CGFloat durationTime; //文件时长

@property (nonatomic, assign) CGFloat process; //播放进度

@property (nonatomic, assign) CGFloat bufferProcess; //缓冲进度

@property (nonatomic, assign) ScaleBtnState scaleBtnState; //缩放状态（全屏/普通）

@property (nonatomic, assign, readonly) BOOL isHidden;


@property (nonatomic, weak) id<PlayerControlProtocol>delegate;

+ (PlayerControlBarBase *)playerControlBar;

- (void)hiddenControlBarWithAnimation:(BOOL)animate;

- (void)showControlBarWithAnimation:(BOOL)animate;

@end
