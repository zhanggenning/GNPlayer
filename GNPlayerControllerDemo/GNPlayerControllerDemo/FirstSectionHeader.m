//
//  FirstSectionHeader.m
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/17.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "FirstSectionHeader.h"

@interface FirstSectionHeader ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_topSeparateHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_bottomSeparateHeight;

@end

@implementation FirstSectionHeader

-(void)awakeFromNib
{
    _constraint_bottomSeparateHeight.constant = 1.f / [UIScreen mainScreen].scale;
    _constraint_topSeparateHeight.constant = 1.f / [UIScreen mainScreen].scale;
}

+ (instancetype)sectionHeaderView
{
    FirstSectionHeader *sectionView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FirstSectionHeader class]) owner:nil options:nil] firstObject];
    return sectionView;
}

@end
