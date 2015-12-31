//
//  MyNavigationController.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/31.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "MyNavigationController.h"
#import "NSObject+X.h"

@implementation MyNavigationController

- (BOOL)shouldAutorotate
{
    //转发一下
    
    UIViewController *top = self.topViewController;
    
    if ([top haveInstanceMethod:@selector(shouldAutorotate)])
    {
      return [top shouldAutorotate];
    }
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //转发一下
    
    UIViewController *top = self.topViewController;
    
    if ([top haveInstanceMethod:@selector(supportedInterfaceOrientations)])
    {
       return [top supportedInterfaceOrientations];
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
