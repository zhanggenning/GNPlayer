//
//  MainViewController.m
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/16.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "MainViewController.h"
#import "MainCell.h"
#import "DetailViewController.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) DetailViewController *detailViewCtl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeDetailViewController];
}

#pragma mark -- Private
- (void)showDetailViewController
{
    //销毁已经存在的ctl
    if (_detailViewCtl)
    {
        [self removeDetailViewController];
    }
    
    //强制竖屏
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait] forKey:@"orientation"];
    }
    
    //显示新的ctl
    self.detailViewCtl = [DetailViewController new];

    self.detailViewCtl.view.frame = CGRectMake(self.view.bounds.size.width - 50,
                                               self.view.bounds.size.height - 50,
                                               self.view.bounds.size.width,
                                               self.view.bounds.size.height);
    self.detailViewCtl.view.alpha = 0.f;
    self.detailViewCtl.view.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    [self addChildViewController:_detailViewCtl];
    [self.view addSubview:_detailViewCtl.view];
    
    //保存最初的frames
    self.detailViewCtl.onView = self.view;
    self.detailViewCtl.initialViewFrame = self.view.frame;
    
    [UIView animateWithDuration:0.9f animations:^{
        self.detailViewCtl.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.detailViewCtl.view.alpha = 1.0;
        self.detailViewCtl.view.frame = self.view.bounds;
    }];
}

- (void)removeDetailViewController
{
    [_detailViewCtl.view removeFromSuperview];
    [_detailViewCtl removeFromParentViewController];
    self.detailViewCtl = nil;
}


#pragma mark -- <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainCell *cell = [MainCell cellLoadXibWithTableView:tableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MainCell cellHeight:self.view.bounds.size.width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self showDetailViewController];
}

@end
