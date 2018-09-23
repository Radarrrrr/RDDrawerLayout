//
//  NextViewController.m
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/9/17.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "NextViewController.h"
#import "RDDrawerLayout.h"

@interface NextViewController ()

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //self.title = @"这是下一个页面哦";
    
    UIView *tView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    tView.backgroundColor = [UIColor greenColor];
    self.titleView =  tView;
}




@end
