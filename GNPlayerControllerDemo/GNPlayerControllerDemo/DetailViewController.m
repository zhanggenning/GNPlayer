//
//  DetailViewController.m
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/17.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "DetailViewController.h"
#import "HeaderView.h"
#import "FirstSectionHeader.h"
#import "FirstSectionCell.h"

#import "PlayerViewManger.h"

@interface DetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    CGRect _currentBounds;
}


@property (strong, nonatomic) UIView *playerView;
@property (strong, nonatomic) HeaderView *headerView;

@property (weak, nonatomic) IBOutlet UIView *videoWrapperView;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic, assign) CGRect minRect;
@property (nonatomic, assign) CGRect maxRect;

@end

@implementation DetailViewController

- (void)dealloc
{
    NSLog(@"释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupHeaderView];
    
    [self setupPlayerView];

    [self setupBackBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    if (!CGRectEqualToRect(_currentBounds, self.view.bounds))
    {
        _headerView.frame = CGRectMake(0, 0, _mainTable.bounds.size.width, [_headerView cellHeight:_mainTable.bounds.size.width]);
        _mainTable.tableHeaderView = _headerView;
        
        _backBtn.frame = CGRectMake(0, 0, 50, 50);
        
        _playerView.frame = _videoWrapperView.bounds;
        
        _currentBounds = self.view.bounds;
    }
}


#pragma mark -- Private(UI控件相关)

- (void)setupHeaderView
{
    _headerView = [HeaderView headerView];
    
    __weak typeof(self) weakSelf = self;
    _headerView.expendBtnBlock = ^() {
        weakSelf.mainTable.tableHeaderView = weakSelf.headerView;
    };
}

- (void)setupPlayerView
{
    //先写一个假的
    _playerView = [PlayerViewManger shareInstance].playerView;
    _playerView.frame = _videoWrapperView.bounds;
    _playerView.backgroundColor = [UIColor redColor];
    [_videoWrapperView addSubview:_playerView];
}

- (void)setupBackBtn
{
    [_playerView addSubview:_backBtn];
    
    [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionRepeat | UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
        
            _backBtn.transform = CGAffineTransformMakeScale(1.5, 1.5);
            
            CGRect rect = _backBtn.frame;
            rect.origin.y += 17;
            _backBtn.frame = rect;
            
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            _backBtn.transform = CGAffineTransformIdentity;
            
            CGRect rect = _backBtn.frame;
            rect.origin.y -= 17;
            _backBtn.frame = rect;
  
        }];
        
    } completion:NULL];
}

- (CGRect)minRect
{
    return CGRectMake([UIScreen mainScreen].bounds.size.width - _playerView.frame.size.width * 0.4,
                      [UIScreen mainScreen].bounds.size.height - _playerView.frame.size.height * 0.4,
                      _playerView.frame.size.width * 0.4,
                      _playerView.frame.size.height * 0.4);
}

#pragma mark -- Events
- (IBAction)backBtnAction:(UIButton *)sender
{
    //将_playerView移动至window
    [_playerView removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:_playerView];
    
    [UIView animateWithDuration:1 animations:^{
        
        CGPoint center = self.view.center;
        center.x = self.view.bounds.size.width - (self.view.bounds.size.width * 0.4) / 2;
        center.y = self.view.bounds.size.height + (center.y - _playerView.bounds.size.height) * 0.4;
        self.view.center = center;
        
        self.view.transform = CGAffineTransformMakeScale(0.4, 0.4);
        
        self.view.alpha = 0.0;
        
        _playerView.frame = self.minRect;
        
    } completion:^(BOOL finished) {
        
        _backBtn.hidden = YES;
        
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
}


#pragma mark  -- <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    FirstSectionCell *cell = [FirstSectionCell cellLoadXibWithTableView:tableView];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [FirstSectionHeader sectionHeaderView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

@end
