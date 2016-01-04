//
//  PlayerView.h
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/24.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerViewProtocol;

typedef NS_ENUM(NSInteger, PlayerModel)
{
    PlayerModelNormal = 0, //普通模式
    PlayerModelFullScreen, //全屏模式
};

@interface PlayerView : UIView

@property (nonatomic, assign) BOOL autoPlay; //进入自动播放

@property (nonatomic, assign, readonly) PlayerModel playerModel; //全屏状态

@property (nonatomic, weak) id<PlayerViewProtocol> delegate;

+ (PlayerView *)playerViewWithUrl:(NSString *)url;

@end


@protocol PlayerViewProtocol <NSObject>

@optional

//播放已经完成
- (void)playerDidPlayEnd:(PlayerView *)playerView;

//即将切换屏幕显示模式（全屏/普通）
- (void)playerWillSwitchModel:(PlayerModel)playerModel;

@end