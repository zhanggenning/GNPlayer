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

@property (nonatomic, assign) BOOL hiddenCloseBtn; //隐藏关闭按钮

@property (nonatomic, copy) NSString *videoUrl; //视频url

@property (nonatomic, weak) id<PlayerViewProtocol> delegate;

+ (PlayerView *)playerViewWithUrl:(NSString *)url;

@end


@protocol PlayerViewProtocol <NSObject>

@optional

//播放完成
- (void)playerDidPlayEnd:(PlayerView *)playerView;

//切换显示模式
- (void)player:(PlayerView *)playerView willSwitchToModel:(PlayerModel)playerModel;


@end