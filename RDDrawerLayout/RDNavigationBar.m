//
//  RDNavigationBar.m
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "RDNavigationBar.h"


#define RDNAV_STATUS_BAR_HEIGHT (RDNAV_IPHONEX_OR_LATER) ? 44.0f : 20.0f
#define RDNAV_IPHONEX_OR_LATER  [RDNavigationBar iPhoneXorLater]   //是否iPhoneX或者更高

#define RDNAV_SCRW  [UIScreen mainScreen].bounds.size.width
#define RDNAV_SCRH  [UIScreen mainScreen].bounds.size.height

#define RDNAV_RGB(r, g, b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RDNAV_RGBS(x)       [UIColor colorWithRed:x/255.0 green:x/255.0 blue:x/255.0 alpha:1.0]


typedef enum {
    directionLeft = 0,    //返回按钮方向向左
    directionRight        //返回按钮方向向右
} NavBtnDirection;



@interface RDNavigationBar () {
    
    UINavigationController *_navController;
}

@property (nonatomic, weak)   RDDrawerLayout *drawerLayout;          //布局控制器实例，本类也持有一份
@property (nonatomic, weak)   UINavigationController *navController; //主导航控制器

@property (nonatomic, strong) UIButton *navBackBtn;         //主导航返回按钮
@property (nonatomic)         NavBtnDirection curDirection; //当前按钮朝向

@property (nonatomic, strong) UILabel *titleLabel; //标题label

@end



@implementation RDNavigationBar
@dynamic navController;


+ (instancetype)sharedNavBar
{
    static dispatch_once_t onceToken;
    static RDNavigationBar *navBar;
    dispatch_once(&onceToken, ^{
        navBar = [[RDNavigationBar alloc] initWithFrame:CGRectMake(0, RDNAV_STATUS_BAR_HEIGHT, 60, 44)];
    });
    return navBar;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        self.curDirection = directionRight;
        
        
        //add titlelabel
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 8, RDNAV_SCRW-60-40, 28)]; 
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.alpha = 0.6;
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = RDNAV_RGBS(50);
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:_titleLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-4, CGRectGetHeight(_titleLabel.frame)-1.0, CGRectGetWidth(_titleLabel.frame)+4, 1.0)];
        line.backgroundColor = RDNAV_RGBS(150);
        [_titleLabel addSubview:line];
        
        
        //add navBackBtn
        self.navBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _navBackBtn.frame = CGRectMake(10, 2, 40, 40);
        [_navBackBtn setBackgroundImage:[UIImage imageNamed:@"rdnav_back.png"] forState:UIControlStateNormal];
        [_navBackBtn addTarget:self action:@selector(navBackAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_navBackBtn];
        
    }
    
    return self;
}

- (void)dealloc
{
}




#pragma mark - setter & getter
- (void)setNavController:(UINavigationController *)navController
{
    _navController = navController;
    
    if(_navController)
    {
        _navController.delegate = self;
    }
}
- (UINavigationController *)navController
{
    return _navController;
}




#pragma mark - 供外部使用
- (void)addNavBarOnLayout:(RDDrawerLayout*)drawerLayout
{
    if(!drawerLayout) return;
    if(!drawerLayout.contentViewController) return;
    if(![drawerLayout.contentViewController isKindOfClass:[UINavigationController class]]) return;
    
    self.drawerLayout = drawerLayout;
    self.navController = (UINavigationController*)drawerLayout.contentViewController;
    
    [drawerLayout.contentViewController.view addSubview:self];
}



#pragma mark - 内部方法
- (void)navBackAction:(id)sender
{
    if(!self.navController) return;
    
    NSInteger vcount = self.navController.viewControllers.count;
    if(vcount > 1)
    {
        //还有可以退的层，继续退
        [_navController popViewControllerAnimated:YES];
    }
    else
    {
        //已经到了root，打开左菜单
        [_drawerLayout showMenu];
    }
}

//旋转一个view
- (void)rotateView:(UIView*)view                //要旋转的view
             angle:(CGFloat)angle               //旋转的角度 +为顺时针 -为逆时针，如 M_PI 或 -M_PI/2
          duration:(float)duration              //旋转速度，要转完angle指定的角度需要的时间
        completion:(void(^)(void))completion
{
    if(!view) return;
    if(angle == 0.0) return;
    if(duration == 0.0) return;
    
    [UIView animateWithDuration:duration  
                          delay:0.0  
                        options:UIViewAnimationOptionCurveEaseInOut  
                     animations:^{  
                         view.transform = CGAffineTransformRotate(view.transform, angle);  
                     }  
                     completion:^(BOOL finished) {  
                         if(completion)
                         {
                             completion();
                         }
                     }]; 
}

+ (BOOL)iPhoneXorLater
{
    if([UIScreen instancesRespondToSelector:@selector(currentMode)])
    {
        float w = [[UIScreen mainScreen] currentMode].size.width;
        float h = [[UIScreen mainScreen] currentMode].size.height;
        float k = h/w; //屏幕高宽比
        
        if(k > 2) 
        {
            return YES;
        }
    }
       
    return NO;
}


//UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //显示或者隐藏title
    _titleLabel.text = viewController.title;
    if(self.titleLabel.text)
    {
        self.titleLabel.alpha = 0.6;
    }
    else
    {
        self.titleLabel.alpha = 0.0;
    }

    //调整返回按钮状态
    NSInteger vcount = _navController.viewControllers.count;
    //NSLog(@"vcount: %ld", vcount);
    
    if(vcount > 1)
    {
        //还有可以退的层，显示向左按钮
        [self rotateNavBtnToDirection:directionLeft];
    }
    else
    {
        //已经到了root，显示向右按钮
        [self rotateNavBtnToDirection:directionRight];
    }
        
}

- (void)rotateNavBtnToDirection:(NavBtnDirection)direction
{  
    if(_curDirection == direction) return;
    
    [self rotateView:_navBackBtn angle:M_PI duration:0.2 completion:^{
        
        self.curDirection = direction;
    }];
}  



@end
