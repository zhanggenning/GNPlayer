//
//  PlayerViewManger.h
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/18.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface PlayerViewManger : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, strong) UIView *playerView;

@end
