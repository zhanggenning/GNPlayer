//
//  VideoCell.h
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/30.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PlayActionBlock)(NSIndexPath *indexPath);

@interface VideoCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) PlayActionBlock playActionBlock;

+ (CGFloat)cellHeight;

@end
