//
//  RDNavigationBar.h
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//
//注：本自定义导航条只适用于主控制器是UINavigationController的形式，
//   如果主控制器是UIViewController或者UITabBarController，那么在RDDrawerLayout主类中设定不使用本导航条，自己可再重新定义一个


#import <UIKit/UIKit.h>
#import "UIViewController+RDNavigationBar.h"

@class RDDrawerLayout;

@interface RDNavigationBar : UIView <UINavigationControllerDelegate>

+ (instancetype)sharedNavBar;

- (void)addNavBarOnLayout:(RDDrawerLayout*)drawerLayout; //添加本导航条到布局控制器上，本方法只能调用一次

- (void)changeBackButtonImage:(UIImage *)image; //更换返回按钮的图片



@end
