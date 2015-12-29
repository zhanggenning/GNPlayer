//
//  MainViewController.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/24.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "MainViewController.h"
#import "PlayerView.h"
#import "PlayerCustomSlider.h"

static NSString * const kTestUrl = @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA";

static NSString * const kTestUrl2 = @"http://us.sinaimg.cn/0024T6n8jx06Y803DaoU05040100vlD00k01.mp4?KID=unistore,video&Expires=1451374368&ssig=yrVbabKvgo";


@interface MainViewController ()
{
    PlayerView *player;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *names = @[@"添加", @"移除"];
    
    for (int i = 0; i < names.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i * 100, 320, 50, 30);
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
        player = [PlayerView playerViewWithUrl:kTestUrl];
        player.frame = CGRectMake(0, 0, 300, 200);
        [self.view addSubview:player];
    }
    else if (btn.tag == 11)
    {
        [player removeFromSuperview];
        player = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    player.center = self.view.center;
}

@end
