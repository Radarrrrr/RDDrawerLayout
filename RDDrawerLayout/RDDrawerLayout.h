//
//  RDDrawerLayout.h
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//
//注：本框架不适合用系统原生NavgationBar，建议自定义导航条，或者直接使用本框架自带的导航条 （其实是犯懒不想做主控制器的container了 -_-!）
//1. 框架会根据menuVC和主控制器rootVC的statusBarStyle自动改变状态，前提是需要在这两个VC中使用 -(UIStatusBarStyle)preferredStatusBarStyle 方法声明自己的风格



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
@property (nonatomic, strong, nonnull) UIViewController *menuViewController;    //menu建议只使用UIViewController
@property (nonatomic, strong, nonnull) UIViewController *contentViewController; //content可以使用UINavigationController，或UIViewController，或UITabBarController


//主控制器滑开以后，剩余可见部分的一些属性设置
@property (nonatomic) float contentVisibleWidth;  //主控制器滑开以后，剩余可见部分的宽度 不填默认 60.0
@property (nonatomic) float contentScale;         //主控制器滑开以后，剩余可见部分的缩放比例 等比0～1 不填默认 0.618
@property (nonatomic) float contentRadius;        //主控制器滑开以后，剩余可见部分的圆角 0～随意 不填默认 15（0为无圆角）
@property (nonatomic) BOOL  contentShadowEnabled; //主控制器滑开以后，剩余可见部分的是否有阴影  不填默认 YES


//TO DO: 做自定义导航条并嵌入框架
//TO DO: 做整个menu view的缩放效果，带图片，带文字一起缩放


- (void)showMenu;  //显示菜单
- (void)hideMenu;  //隐藏菜单



@end
