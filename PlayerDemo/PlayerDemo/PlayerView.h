//
//  PlayerView.h
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/24.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerView : UIView

@property (nonatomic, assign) BOOL isAutoPlay; //进入自动播放

+ (PlayerView *)playerViewWithUrl:(NSString *)url;

@end
