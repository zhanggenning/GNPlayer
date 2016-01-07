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

@interface VideoTableController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PlayerViewProtocol>

@property (nonatomic, strong) PlayerView *playerView;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
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

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (CGRect)getPlayerFrameWithIndexPath:(NSIndexPath *)indexPath
{
    CGRect rectInTableView = [_videoTable rectForRowAtIndexPath:indexPath];
    VideoCell *videoCell = [_videoTable cellForRowAtIndexPath:indexPath];
    CGRect playerFrame = [videoCell playerRectByCellFrame:rectInTableView];
    
    return playerFrame;
}

//创建playerView
- (void)createPlayerView:(NSIndexPath *)indexPath
{
    [_playerView removeFromSuperview];

    //创建
    if (!_playerView)
    {
        _playerView = [PlayerView playerViewWithUrl:kTestUrl2];
        _playerView.autoPlay = YES;
        _playerView.delegate = self;
    }
    else
    {
        _playerView.videoUrl = kTestUrl2;
    }
    
    _playerView.frame = [self getPlayerFrameWithIndexPath:indexPath];
    
    [_videoTable addSubview:_playerView];
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
        
        strongSelf.selectIndexPath = indexPath;
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

#pragma mark -- <PlayerViewProtocol>
- (void)playerDidPlayEnd:(PlayerView *)playerView
{
    [_playerView removeFromSuperview];
}

- (void)player:(PlayerView *)playerView willSwitchToModel:(PlayerModel)playerModel
{
    switch (playerModel)
    {
        case PlayerModelNormal:
        {
            NSLog(@"[Demo] 切换至普通状态");
            
            self.navigationController.navigationBarHidden = NO;
            
            CGRect frameInTableView = [_playerView convertRect:_playerView.bounds toView:_videoTable];
            
            [_playerView removeFromSuperview];
            _playerView.frame = frameInTableView;
            [_videoTable addSubview:_playerView];
            
            CGRect playerFrame = [self getPlayerFrameWithIndexPath:_selectIndexPath];
            [UIView animateWithDuration:0.3 animations:^{
                _playerView.transform = CGAffineTransformIdentity;
                _playerView.frame = playerFrame;
            }];
            
            break;
        }
        case PlayerModelFullScreen:
        {
            NSLog(@"[Demo] 切换至全屏状态");
            
            self.navigationController.navigationBarHidden = YES;
            
            CGRect frameInSelfView = [_playerView convertRect:_playerView.bounds toView:self.view];
            [_playerView removeFromSuperview];
            _playerView.frame = frameInSelfView;
            [self.view addSubview:_playerView];
            
            switch ([UIDevice currentDevice].orientation)
            {
                case UIDeviceOrientationLandscapeLeft:
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        _playerView.transform = CGAffineTransformMakeRotation(M_PI_2);
                        _playerView.frame = [UIScreen mainScreen].bounds;
                    }];
                    break;
                }
                case UIDeviceOrientationLandscapeRight:
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        _playerView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                        _playerView.frame = [UIScreen mainScreen].bounds;
                    }];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
}


@end