//
//  PlayerView.h
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/24.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerViewProtocol;

@interface PlayerView : UIView

@property (nonatomic, assign) BOOL autoPlay; //进入自动播放

@property (nonatomic, assign) BOOL isFullScreen; //全屏状态

@property (nonatomic, weak) id<PlayerViewProtocol> delegate;

+ (PlayerView *)playerViewWithUrl:(NSString *)url;

@end


@protocol PlayerViewProtocol <NSObject>

@optional

//播放完成
- (void)playerViewPlayEnd:(PlayerView *)playerView;

//全屏播放
- (void)playerViewFullScreen:(PlayerView *)playerView;

@end