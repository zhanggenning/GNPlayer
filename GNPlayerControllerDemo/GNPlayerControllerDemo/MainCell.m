//
//  MainCell.m
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/16.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "MainCell.h"

@interface MainCell ()

@end

@implementation MainCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat) cellHeight:(CGFloat)cellWidth
{
    CGFloat imageHeight = (cellWidth - 2 * 8) * 9 / 16;
    
    return 16 + imageHeight + 8 + 30 + 8;
}

@end
