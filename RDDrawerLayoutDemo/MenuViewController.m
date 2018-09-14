//
//  MenuViewController.m
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    float width  = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    
    UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    backView.image = [UIImage imageNamed:@"back_img"];
    [self.view addSubview:backView];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}




@end
