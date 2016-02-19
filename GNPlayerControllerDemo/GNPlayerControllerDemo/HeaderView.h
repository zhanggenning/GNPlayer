//
//  HeaderView.h
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/17.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ExpendBtnBlock)();

@interface HeaderView : UIView

+ (instancetype)headerView;

- (CGFloat)cellHeight:(CGFloat)cellWidth;

@property (nonatomic, strong) ExpendBtnBlock expendBtnBlock;


@end
