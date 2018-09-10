//
//  AppDelegate.m
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/9/9.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuViewController.h"
#import "HomeViewController.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    mainNav.navigationBar.translucent = NO; //不要导航条模糊，为了让页面从导航条下部是0开始，如果为YES，则从屏幕顶部开始是0
    mainNav.navigationBar.hidden=YES;  //注意，此处不要使用后面的这个方法 -> _mainNav.navigationBarHidden = YES; 用这个会影响右滑关闭手势

    
    //添加自定义导航栏
    //[[CustomNavBar sharedNavBar] addNavBarOnMainNav:_mainNav];
    
    
    MenuViewController  *menuVC = [[MenuViewController alloc] init];

    RDDrawerLayout *rootLayoutVC = [[RDDrawerLayout alloc]init];
    rootLayoutVC.delegate = self;
    rootLayoutVC.menuViewController = menuVC;
    rootLayoutVC.contentViewController = mainNav; 
    
    
    self.window.rootViewController = rootLayoutVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




#pragma mark -
#pragma RDDrawerLayoutDelegate
- (void)drawerLayoutWillShowMenu:(RDDrawerLayout*)drawerLayout
{
    //NSLog(@"drawerLayoutWillShowMenu");
}
- (void)drawerLayoutDidShowMenu:(RDDrawerLayout*)drawerLayout
{
    //NSLog(@"drawerLayoutDidShowMenu");
}
- (void)drawerLayoutWillHideMenu:(RDDrawerLayout*)drawerLayout
{
    //NSLog(@"drawerLayoutWillHideMenu");
}
- (void)drawerLayoutDidHideMenu:(RDDrawerLayout*)drawerLayout
{
    //NSLog(@"drawerLayoutDidHideMenu");
}




@end
