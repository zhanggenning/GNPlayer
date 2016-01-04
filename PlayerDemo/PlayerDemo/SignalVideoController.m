//
//  SignalVideoController.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/30.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "SignalVideoController.h"
#import "PlayerView.h"

static NSString * const kTestUrl1 = @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA";

static NSString * const kTestUrl2 = @"http://us.sinaimg.cn/0024T6n8jx06Y803DaoU05040100vlD00k01.mp4?KID=unistore,video&Expires=1451374368&ssig=yrVbabKvgo";


@interface SignalVideoController () <PlayerViewProtocol>
{
    PlayerView *_player;
}
@end

@implementation SignalVideoController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addBtton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrames:) name:UIDeviceOrientationDidChangeNotification object:nil];
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
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLayoutSubviews
{
    UIView *backView = [self.view viewWithTag:20];
    backView.center = CGPointMake(self.view.bounds.size.width / 2, 124);
    
    if (_player)
    {
        if (_player.playerModel == PlayerModelFullScreen)
        {
            _player.center = self.view.center;
        }
        else
        {
            _player.center = CGPointMake(self.view.frame.size.width / 2,
                                     backView.center.y + backView.frame.size.height / 2 + 20 + _player.frame.size.height / 2);
        }
    }
}

#pragma mark -- Private API
- (void)createPlayer
{
    _player = [PlayerView playerViewWithUrl:kTestUrl2];
    _player.frame = CGRectMake(0, 0, 300, 200);
    _player.autoPlay = YES;
    _player.delegate = self;
    [self.view addSubview:_player];
}

- (void)destroyPlayer
{
    [_player removeFromSuperview];
    _player = nil;
}

- (void)addBtton
{
    NSArray *names = @[@"添加", @"移除"];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100 * 2 + 100, 50)];
    backView.tag = 20;
    
    for (int i = 0; i < names.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i * (100 + 100), 0, 100, 50);
        btn.tag = 10 + i;
        [btn setTitle:names[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor greenColor];
        [backView addSubview:btn];
    }
    
    [self.view addSubview:backView];
}

#pragma mark -- Events

- (void)btnAction:(UIButton *)btn
{
    if (btn.tag == 10)
    {
        [self createPlayer];
    }
    else if (btn.tag == 11)
    {
        [self destroyPlayer];
    }
}

- (void)changeFrames:(NSNotification *)notification
{
    NSLog(@"change notification: %@", notification.userInfo);
    
    switch ([UIDevice currentDevice].orientation)
    {
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeRight:
            break;
        case UIDeviceOrientationLandscapeLeft:
            break;
        default:
            break;
    }
}

#pragma mark -- <PlayerViewProtocol>

- (void)playerViewPlayEnd:(PlayerView *)playerView
{
    [self destroyPlayer];
}

- (void)playerWillSwitchModel:(PlayerModel)playerModel
{
    switch (playerModel)
    {
        case PlayerModelNormal:
        {
            NSLog(@"正常模式");
            self.navigationController.navigationBarHidden = NO;
            break;
        }
        case PlayerModelFullScreen:
        {
            NSLog(@"全屏模式");
            self.navigationController.navigationBarHidden = YES;
            break;
        }
        default:
            break;
    }
}

@end
