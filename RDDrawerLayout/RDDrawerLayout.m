//
//  RDDrawerLayout.m
//  RDDrawerMenu
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "RDDrawerLayout.h"


#define SCRW [UIScreen mainScreen].bounds.size.width
#define SCRH [UIScreen mainScreen].bounds.size.height



@interface RDDrawerLayout ()

@property (nonatomic) float startX;
@property (nonatomic) float currentX;

@property (nonatomic) float showX;  //content滑开最远处的X值
@property (nonatomic) float showY;  //content滑开最远处的Y值

@property (nonatomic) BOOL  showing;  //if menu is showing

@end



@implementation RDDrawerLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.contentLeaveWidth = 60.0;
    self.contentLeaveScale = 0.75;
    self.contentRadius = 15;
    //self.menuStatusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blueColor];
   
    //根据外部设定属性，重新计算内部使用的属性
    self.startX = 0.0;
    self.currentX = 0.0;
    self.showX = SCRW - _contentLeaveWidth;
    self.showY = SCRH*(1-_contentLeaveScale)/2;
    self.showing = NO;
    
    //将menuViewController和contentViewController添加到self中作为子控制器。将他们的view添加到self.view中
    [self addChildViewController:self.menuViewController];
    [self.view addSubview:self.menuViewController.view];
    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];
    
    //设置一个按钮点击实现抽屉效果
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftButton.frame = CGRectMake(0, 50, 150, 150);
    [leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"left" forState:UIControlStateNormal];
    [self.contentViewController.view addSubview:leftButton];
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

-(void)leftButtonPressed
{
    //判断抽屉是否是展开状态
    if (self.contentViewController.view.frame.origin.x == 0) 
    {
        //to show
        [self showMenu];
        
    }
    else
    {
        //to hide
        [self hideMenu];
    }
}




#pragma mark -
#pragma mark 内部方法
- (void)changeContentRadius:(float)radius
{
    _contentViewController.view.layer.cornerRadius = radius;
    _contentViewController.view.layer.masksToBounds = YES;
}




#pragma mark -
#pragma mark Status Bar Appearance Management
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
//    
//    statusBarStyle = _showing ? _menuStatusBarStyle : _contentViewController.preferredStatusBarStyle;
//    if(_currentX >= 10)
//    {
//       statusBarStyle = _menuStatusBarStyle;
//    } 
//    else 
//    {
//       statusBarStyle = _contentViewController.preferredStatusBarStyle;
//    }
//    
//    return statusBarStyle;
//}
//- (void)statusBarNeedsAppearanceUpdate
//{
//    //更新statusbar风格的变化
//    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) 
//    {
//        [UIView animateWithDuration:0.15f animations:^{
//            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//        }];
//    }
//}




#pragma mark -
#pragma mark UIGestureRecognizer Delegate (Private)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    if([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) 
    {
        if(!_showing)
        {
            CGPoint point = [touch locationInView:gestureRecognizer.view];
            if(point.x < 25.0 || point.x > self.view.frame.size.width - 25.0) 
            {
                return YES;
            } 
            else 
            {
                return NO;
            }
        }
    }
    
    return YES;
}


#pragma mark -
#pragma mark Gesture handling
- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if(![gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) return;
    
    UIGestureRecognizerState state = gestureRecognizer.state;
    if (state == UIGestureRecognizerStateBegan) 
    {
        //NSLog(@"pan began");
        
        self.startX = _contentViewController.view.frame.origin.x;
        self.currentX = _startX;
        
        if(!_showing)
        { 
            if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(drawerLayoutWillShowMenu:)])
            {
                [self.delegate drawerLayoutWillShowMenu:self];
            }
        }
        else
        {
            if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(drawerLayoutWillHideMenu:)])
            {
                [self.delegate drawerLayoutWillHideMenu:self];
            }
        }
    } 
    else if (state == UIGestureRecognizerStateChanged) 
    {
        //处理平移位移
        CGPoint tr = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self.view];
        //NSLog(@"tr:(%f, %f)", tr.x, tr.y);
        
        //tr.x < 0 向左滑动, tr.x > 0向右滑动
        float toX = _startX+tr.x;
        
        float k   = toX/_showX;
        float toY = _showY * k;
        float toH = SCRH - ((SCRH*(1-_contentLeaveScale)) * k);
        float toW = toH * (SCRW/SCRH);
        
        float toRadus = _contentRadius * k;
        
        if(toX > 0 && toX <=_showX) 
        {
            //改变位置
            CGRect uframe = _contentViewController.view.frame;
            uframe.origin.x = toX;
            uframe.origin.y = toY;
            uframe.size.width = toW;
            uframe.size.height = toH;
            _contentViewController.view.frame = uframe;
            
            //改变圆角
            [self changeContentRadius:toRadus];
            
            //取一下当前的x值
            self.currentX = toX;
        }
    } 
    else if (state == UIGestureRecognizerStateEnded) 
    {
        //NSLog(@"pan end");
        
        //速度基本公式： v=s/t   t=s/v
        
        //处理加速度
        CGPoint vr = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self.view];
        //NSLog(@"vr:(%f, %f)", vr.x, vr.y);
        
        //vr.x < 0 向左滑动, vr.x > 0向右滑动
        if(vr.x > 100) 
        {  
            //计算抬手时候的剩余距离
            float lastS = _showX - _currentX;
            
            //计算跑完剩余距离所需时间
            float dura = lastS/(vr.x+100);
            //NSLog(@"dura: %f", dura);
            
            [self showLeftMenu:YES duration:dura];
        } 
        else if(vr.x < -100) 
        {
            //计算抬手时候的剩余距离
            float lastS = _currentX;
            
            //计算跑完剩余距离所需时间
            float dura = lastS/(-vr.x+100);
            //NSLog(@"dura: %f", dura);
            
            [self showLeftMenu:NO duration:dura];
        } 
        else 
        {
            //检测是否越过limitline，自动移动到最左或者最右的位置
            [self fixContentPostion];
        }
    }
    
}


#pragma mark -
#pragma mark 滑动显示相关方法
- (void)showLeftMenu:(BOOL)bshow duration:(float)dura
{
    float nx;
    float ny;
    float nw;
    float nh;
    float nr;
    
    NSString *animID;
    if (bshow)
    {
        nx = _showX;
        ny = _showY;
        nw = SCRW*_contentLeaveScale;
        nh = SCRH*_contentLeaveScale;
        nr = _contentRadius;
        
        animID = @"show_menu";
    } 
    else 
    {
        nx = 0;
        ny = 0;
        nw = SCRW;
        nh = SCRH;
        nr = 0;
        
        animID = @"close_menu";
    }
    
    //动画移动
    [UIView beginAnimations:animID context:nil];
    [UIView setAnimationDuration:dura];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    CGRect uframe = _contentViewController.view.frame;
    uframe.origin.x = nx;
    uframe.origin.y = ny;
    uframe.size.width = nw;
    uframe.size.height = nh;
    _contentViewController.view.frame = uframe;
    
    [self changeContentRadius:nr];
    
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    if (!animationID || [animationID compare:@""] == NSOrderedSame) return;

    if([animationID compare:@"close_menu"] == NSOrderedSame) 
    {
        _showing = NO;

        if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(drawerLayoutDidHideMenu:)])
        {
            [self.delegate drawerLayoutDidHideMenu:self];
        }
    } 
    else if([animationID compare:@"show_menu"] == NSOrderedSame) 
    {
        _showing = YES;
        
        if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(drawerLayoutDidShowMenu:)])
        {
            [self.delegate drawerLayoutDidShowMenu:self];
        }
    }
    
}

- (void)fixContentPostion
{
    //判断是否越过中线, 修正接口列表位置
    float cx = _contentViewController.view.frame.origin.x;
    float limx = [UIScreen mainScreen].bounds.size.width/2;
    
    //判断是否显示和隐藏
    if (cx <= limx)
    {
        //移动到收起来的位置
        [self showLeftMenu:NO duration:0.15];
    } 
    else 
    {
        //移动到展开位置
        [self showLeftMenu:YES duration:0.15];
    }
}



#pragma mark -
#pragma mark 对外支持方法
- (void)showMenu
{
    [self showLeftMenu:YES duration:0.15];
}
- (void)hideMenu
{
    [self showLeftMenu:NO duration:0.15];
}









@end
