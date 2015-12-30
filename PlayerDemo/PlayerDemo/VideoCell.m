//
//  VideoCell.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/30.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "VideoCell.h"

@interface VideoCell ()

@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation VideoCell

- (void)awakeFromNib {
    // Initialization code
    
    _backView.layer.borderWidth = 1;
    _backView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight
{
    CGFloat labelHeight = 20;
    CGFloat imgHeihgt = ([UIScreen mainScreen].bounds.size.width - 2 * 8 - 2 * 8) * 2 / 3;
    CGFloat btnViewHeight = 25;
    
    return 8 + labelHeight + 8 + imgHeihgt + 8 + btnViewHeight + 8 + 8;
}

- (IBAction)playAction:(UIButton *)sender
{
    if (_playActionBlock)
    {
        _playActionBlock(_indexPath);
    }
}

@end
