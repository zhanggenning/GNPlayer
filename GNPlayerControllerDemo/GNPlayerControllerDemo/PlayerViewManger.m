//
//  PlayerViewManger.m
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/18.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "PlayerViewManger.h"

@implementation PlayerViewManger

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PlayerViewManger alloc] init];
    });
    
    return instance;
}

- (UIView *)playerView
{
    if (_playerView == nil)
    {
        _playerView = [[UIView alloc] init];
    }
    
    return _playerView;
}

@end
