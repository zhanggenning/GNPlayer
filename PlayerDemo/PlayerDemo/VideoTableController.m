//
//  VideoTableController.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/30.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "VideoTableController.h"
#import "VideoCell.h"
#import "PlayerView.h"

static NSString * const kTestUrl2 = @"http://us.sinaimg.cn/0024T6n8jx06Y803DaoU05040100vlD00k01.mp4?KID=unistore,video&Expires=1451374368&ssig=yrVbabKvgo";

@interface VideoTableController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

{
    PlayerView *_playerView;
}

@property (weak, nonatomic) IBOutlet UITableView *videoTable;

@end

@implementation VideoTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_videoTable registerNib:[UINib nibWithNibName:NSStringFromClass([VideoCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//创建playerView
- (void)createPlayerView:(NSIndexPath *)indexPath
{
    //先移除
    [self destoryPlayerView];
    
    //获取frame
    CGRect rectInTableView = [_videoTable rectForRowAtIndexPath:indexPath];
    VideoCell *videoCell = [_videoTable cellForRowAtIndexPath:indexPath];
    CGRect playerFrame = [videoCell playerRectByCellFrame:rectInTableView];
    
    //创建
    _playerView = [PlayerView playerViewWithUrl:kTestUrl2];
    _playerView.frame = playerFrame;
    _playerView.autoPlay = YES;
    [_videoTable addSubview:_playerView];
}

//销毁playerview
- (void)destoryPlayerView
{
    if (_playerView)
    {
        [_playerView removeFromSuperview];
        
        _playerView = nil;
    }
}

#pragma mark -- <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

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
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    
    __weak typeof(self) weakSelf = self;
    cell.playActionBlock = ^(NSIndexPath *indexPath){
    
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf createPlayerView:indexPath];

    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VideoCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_playerView)
    {
        CGFloat downLimit = _playerView.frame.origin.y + _playerView.frame.size.height - 64;
        CGFloat upLimit = _playerView.frame.origin.y - [UIScreen mainScreen].bounds.size.height;
        
        if (scrollView.contentOffset.y >= downLimit || scrollView.contentOffset.y <= upLimit)
        {
            [self destoryPlayerView];
        }
        
    }
 
}


@end
