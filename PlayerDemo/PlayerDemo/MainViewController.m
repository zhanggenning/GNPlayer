//
//  MainViewController.m
//  PlayerDemo
//
//  Created by zhanggenning on 15/12/24.
//  Copyright © 2015年 zhanggenning. All rights reserved.
//

#import "MainViewController.h"
#import "PlayerView.h"
#import "PlayerSlider.h"
#import "PlayerCustomSlider.h"

@interface MainViewController ()
{
    PlayerView *player;
}

@property (weak, nonatomic) IBOutlet PlayerCustomSlider *testSlider;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    player = [PlayerView playerView];
    player.frame = CGRectMake(0, 0, 300, 200);
    [self.view addSubview:player];
    
    _testSlider.process = 0.5;
    _testSlider.bufferProcess = 0.7;
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
