//
//  HomeViewController.m
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    float width  = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    
    UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    backView.image = [UIImage imageNamed:@"back_img"];
    [self.view addSubview:backView];
    

//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftButton.frame = CGRectMake(0, 150, 60, 20);
//    leftButton.backgroundColor = [UIColor redColor];
//    //[leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//    [leftButton setTitle:@"RGIHTH" forState:UIControlStateNormal];
//    [self.view addSubview:leftButton];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


@end
