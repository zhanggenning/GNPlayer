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


@interface SignalVideoController ()
{
    PlayerView *_player;
}
@end

@implementation SignalVideoController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self addBtton];
}

- (void)createPlayer
{
    _player = [PlayerView playerViewWithUrl:kTestUrl1];
    _player.frame = CGRectMake(0, 0, 300, 200);
    _player.isAutoPlay = YES;
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
    
    for (int i = 0; i < names.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((80 + i * 100), 380, 50, 30);
        btn.tag = 10 + i;
        [btn setTitle:names[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor greenColor];
        [self.view addSubview:btn];
    }
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    _player.center = self.view.center;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end