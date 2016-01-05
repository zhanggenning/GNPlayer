//
//  NSObject+X.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/31.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "NSObject+X.h"
#import <objc/runtime.h>

@implementation NSObject (X)

+ (BOOL)haveInstanceMethod:(SEL)selector
{
    Method method = class_getInstanceMethod([self class], selector);
    Method supMethod = class_getInstanceMethod([self superclass], selector);
    if (method != NULL && method != supMethod)
    {
        return YES;
    }
    return NO;
}

- (BOOL)haveInstanceMethod:(SEL)selector
{
    return [[self class] haveInstanceMethod:selector];
}

@end
