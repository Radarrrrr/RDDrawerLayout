//
//  RDDrawerLayout.h
//  RDDrawerMenu
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//
//注：本框架不适合用系统原生NavgationBar，建议自定义导航条，或者直接使用本框架自带的导航条

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@class RDDrawerLayout;
@protocol RDDrawerLayoutDelegate <NSObject> 
@optional

- (void)drawerLayoutWillShowMenu:(RDDrawerLayout*)drawerLayout;
- (void)drawerLayoutDidShowMenu:(RDDrawerLayout*)drawerLayout;

- (void)drawerLayoutWillHideMenu:(RDDrawerLayout*)drawerLayout;
- (void)drawerLayoutDidHideMenu:(RDDrawerLayout*)drawerLayout;

@end


@interface RDDrawerLayout : UIViewController <UIGestureRecognizerDelegate>

@property (weak) id <RDDrawerLayoutDelegate> delegate;


//两个子控制器menuViewController和contentViewController，此处强制必须不能为空
@property (nonatomic, strong, nonnull) UIViewController *menuViewController;
@property (nonatomic, strong, nonnull) UIViewController *contentViewController;

@property (nonatomic) float contentLeaveWidth;  //主控制器滑开以后，剩余可见部分的宽度 不填默认 60.0
@property (nonatomic) float contentLeaveScale;  //主控制器滑开以后，剩余可见部分的缩放比例 等比0～1 不填默认 0.618

@property (nonatomic) float contentRadius;      //主控制器滑开以后，剩余可见部分的圆角 0～随意 不填默认 15（0为无圆角）


//TO DO: 做status bar颜色改变
//TO DO: 做content滑开以后有偏深色按钮覆盖，点击content区域可以关闭menu
//TO DO: 做content阴影
//TO DO: 做自定义导航条并嵌入框架
//TO DO: 做整个menu view的缩放效果，带图片，带文字一起缩放


- (void)showMenu;  //显示菜单
- (void)hideMenu;  //隐藏菜单



@end
