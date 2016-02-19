//
//  BaseCell.m
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/18.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "BaseCell.h"

@implementation BaseCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (instancetype)cellLoadXibWithTableView:(UITableView *)tableView
{
    BaseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    }
    
    return cell;
}

@end
