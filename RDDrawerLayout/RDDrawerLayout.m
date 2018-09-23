//
//  RDDrawerLayout.m
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "RDDrawerLayout.h"


#define SCRW [UIScreen mainScreen].bounds.size.width
#define SCRH [UIScreen mainScreen].bounds.size.height


#define MASK_BTN_SHOW_ALPHA 0.1 
#define SHADOW_OPACITY      0.5


@interface RDDrawerLayout ()

@property (nonatomic) float startX;
@property (nonatomic) float currentX;

@property (nonatomic) float showX;  //content滑开最远处的X值
@property (nonatomic) float showY;  //content滑开最远处的Y值

@property (nonatomic) BOOL  showing;  //if menu is showing

@property (nonatomic, strong) UIButton *maskBtn;  //content滑开以后的覆盖层btn
@property (nonatomic, strong) UIView *shadowView; //content的阴影背景

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
    self.contentVisibleWidth = 60.0;
    self.contentScale = 0.618;
    self.contentRadius = 20;
    self.contentShadowEnabled = YES;
    self.menuScale = 2.0;
    self.ihaveNavBar = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
   
    //根据外部设定属性，重新计算内部使用的属性
    self.startX = 0.0;
    self.currentX = 0.0;
    self.showX = SCRW-_contentVisibleWidth;
    self.showY = SCRH*(1-_contentScale)/2;
    self.showing = NO;
    
    
    //将menuViewController和contentViewController添加到self中作为子控制器。将他们的view添加到self.view中
    //添加menu
    [self addChildViewController:self.menuViewController];
    [self.view addSubview:self.menuViewController.view];
    
    //添加shadow
    if(_contentShadowEnabled)
    {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCRW, SCRH)];
        _shadowView.backgroundColor = [UIColor clearColor];
        _shadowView.userInteractionEnabled = NO;
        [self.view addSubview:_shadowView];
        
        [self bindingShadowToContent];
        [self updateContentShadow];
    }
    
    //添加content
    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];
    
    
    //初始化缩放menu控制器
    _menuViewController.view.transform = CGAffineTransformMakeScale(_menuScale, _menuScale);
    
    
    //添加手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    
    //添加自定义导航条RDNavigationBar
    if(!_ihaveNavBar)
    {
        [[RDNavigationBar sharedNavBar] addNavBarOnLayout:self];
    }
    
    //设置maskbtn
    self.maskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _maskBtn.frame = CGRectMake(0, 0, SCRW, SCRH);
    [_maskBtn addTarget:self action:@selector(maskBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _maskBtn.backgroundColor = [UIColor blackColor];
    _maskBtn.alpha = 0.0;
    [self.contentViewController.view addSubview:_maskBtn];
    
}

- (void)dealloc
{
    [self removeKVOfromContent];
}



#pragma mark -
#pragma mark 内部方法
- (void)maskBtnAction:(id)sender
{
    [self hideMenu];
}

- (void)changeContentRadius:(float)radius
{
    _contentViewController.view.layer.cornerRadius = radius;
    _contentViewController.view.layer.masksToBounds = YES;
}

- (void)updateContentShadow
{
    //更新阴影状态
    CALayer *layer = _shadowView.layer;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
    layer.shadowPath = path.CGPath;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = SHADOW_OPACITY;
    layer.shadowRadius = _contentRadius <= 6 ? 6:_contentRadius;
}

- (void)bindingShadowToContent
{
    //把shadow绑定到content上，跟着动
    [self addKVOtoContent];
}




#pragma mark -
#pragma mark KVO操作
- (void)addKVOtoContent
{
    if(!_contentViewController) return;
    if(!_shadowView) return;
    
    [_contentViewController.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)removeKVOfromContent
{
    if(!_contentViewController) return;
    if(!_shadowView) return;
    
    [_contentViewController.view removeObserver:self forKeyPath:@"frame"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(_shadowView && _contentViewController && object == _contentViewController.view && [keyPath isEqualToString:@"frame"]) 
    {
        float cx             = _contentViewController.view.frame.origin.x;
        float cy             = _contentViewController.view.frame.origin.y;
        CGAffineTransform ct = _contentViewController.view.transform;
        
        //shadow跟进
        _shadowView.transform = ct;
        
        CGRect sframe = _shadowView.frame;
        sframe.origin.x = cx;
        sframe.origin.y = cy;
        _shadowView.frame = sframe;
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}




#pragma mark -
#pragma mark Status Bar Appearance Management
- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    
    UIViewController *cntRootVC = _contentViewController;
    
    if([_contentViewController isKindOfClass:[UINavigationController class]])
    {
        //找到content的root
        UINavigationController *cntNav = (UINavigationController*)_contentViewController;
        if(cntNav.viewControllers.count > 0)
        {
            cntRootVC = [cntNav.viewControllers firstObject];
        }
    }
    
    statusBarStyle = _showing ? _menuViewController.preferredStatusBarStyle : cntRootVC.preferredStatusBarStyle;
    
    if(_currentX >= 10)
    {
       statusBarStyle = _menuViewController.preferredStatusBarStyle;
    } 
    else 
    {
       statusBarStyle = cntRootVC.preferredStatusBarStyle;
    }
    
    return statusBarStyle;
}
- (void)updateStatusBarStyle
{
    //更新statusbar风格的变化
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) 
    {
        [UIView animateWithDuration:0.15f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}



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
        
        if(toX > 0 && toX <=_showX) 
        {
            float k   = toX/_showX;
            float toY = _showY * k;
            float toH = SCRH - ((SCRH*(1-_contentScale)) * k);
            float toW = toH * (SCRW/SCRH);
            
            float toRadius = _contentRadius * k;
            float toCScale = 1-(1-_contentScale)*k;
            float toMScale = _menuScale-(_menuScale-1.0)*k;
         
            //改变content的缩放比例
            self.contentViewController.view.transform = CGAffineTransformMakeScale(toCScale, toCScale);
            
            //改变menu的缩放比例
            self.menuViewController.view.transform = CGAffineTransformMakeScale(toMScale, toMScale);
            
            //改变位置
            CGRect uframe = _contentViewController.view.frame;
            uframe.origin.x = toX;
            uframe.origin.y = toY;
            uframe.size.width = toW;
            uframe.size.height = toH;
            _contentViewController.view.frame = uframe;
            
            //改变圆角
            [self changeContentRadius:toRadius];
            
            //改变maskbtn的状态
            _maskBtn.alpha = MASK_BTN_SHOW_ALPHA*k;
            
            //取一下当前的x值
            self.currentX = toX;
        }
        
        //更新状态栏风格
        [self updateStatusBarStyle];
        
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
    float nr;
    float na;
    float cscale;
    float mscale;
    
    NSString *animID;
    if (bshow)
    {
        nx = _showX;
        ny = _showY;
        nr = _contentRadius;
        na = MASK_BTN_SHOW_ALPHA;
        cscale = _contentScale;
        mscale = 1.0;
        
        animID = @"show_menu";
    } 
    else 
    {
        nx = 0;
        ny = 0;
        nr = 0;
        na = 0.0;
        cscale = 1.0;
        mscale = _menuScale;
        
        animID = @"close_menu";
    }
    
    //动画移动
    [UIView beginAnimations:animID context:nil];
    [UIView setAnimationDuration:dura];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    //改变content的缩放比例
    self.contentViewController.view.transform = CGAffineTransformMakeScale(cscale, cscale);
    
    //改变menu的缩放比利
    self.menuViewController.view.transform = CGAffineTransformMakeScale(mscale, mscale);
    
    //改变content的位置
    CGRect uframe = _contentViewController.view.frame;
    uframe.origin.x = nx;
    uframe.origin.y = ny;
    _contentViewController.view.frame = uframe;
    
    //改变圆角
    [self changeContentRadius:nr];
    
    //改变maskbtn的状态
    _maskBtn.alpha = na;
    
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    if (!animationID || [animationID compare:@""] == NSOrderedSame) return;

    if([animationID compare:@"show_menu"] == NSOrderedSame) 
    {
        _showing = YES;
        _currentX = _showX;
        
        if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(drawerLayoutDidShowMenu:)])
        {
            [self.delegate drawerLayoutDidShowMenu:self];
        }
    }
    else if([animationID compare:@"close_menu"] == NSOrderedSame) 
    {
        _showing = NO;
        _currentX = 0;

        if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(drawerLayoutDidHideMenu:)])
        {
            [self.delegate drawerLayoutDidHideMenu:self];
        }
    } 
    
    [self updateStatusBarStyle];
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
