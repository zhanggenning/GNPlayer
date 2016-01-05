//
//  NSObject+X.h
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/31.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (X)

+ (BOOL)haveInstanceMethod:(SEL)selector;

- (BOOL)haveInstanceMethod:(SEL)selector;

@end
