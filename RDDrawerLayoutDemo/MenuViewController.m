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
    [self fixPositionForBackView:backView];
    [self.view addSubview:backView];
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


//根据背景图片修正背景容器的位置
- (void)fixPositionForBackView:(UIImageView*)backV
{
    if(!backV) return;
    if(!backV.image) return;
    
    float SCRW = [UIScreen mainScreen].bounds.size.width;
    float SCRH = [UIScreen mainScreen].bounds.size.height;
    
    float scr_ratio = SCRW/SCRH;
    float img_ratio = backV.image.size.width/backV.image.size.height;
    
    //0.01范围内接受差距
    if(img_ratio >= scr_ratio-0.01 && img_ratio <= scr_ratio+0.01) return; 
    
    //计算新位置
    CGRect newRect;
    if(img_ratio > scr_ratio) //图片矮了
    {
        newRect.size.height = SCRH;
        newRect.size.width = SCRH*img_ratio;
        
        newRect.origin.y = 0.0;
        newRect.origin.x = -(SCRH*img_ratio - SCRW)/2;
    }
    else                      //图片高了
    {
        newRect.size.height = -(SCRW/img_ratio - SCRH)/2;
        newRect.size.width = SCRW;
        
        newRect.origin.y = 0.0;
        newRect.origin.x = 0.0;
    }
    
    //调整位置
    backV.frame = newRect;
    
}


//图片按屏幕比例裁剪
- (UIImage*)imageConvertedForScreen:(UIImage*)image
{    
    if(image == nil) return nil;
    
    float SCRW = [UIScreen mainScreen].bounds.size.width;
    float SCRH = [UIScreen mainScreen].bounds.size.height;
    float ratio = SCRW/SCRH;
    
    //容错前后0.01比例，都可以返回，因为这点差距看不出来，还可以提高效率
    float imgRatio = image.size.width/image.size.height;
    if(imgRatio >= ratio-0.01 && imgRatio <= ratio+0.01) return image; 
    
    //创建画布
    float contxWidth;
    float contxHeight;
    float offsetx;
    float offsety;
    
    if(image.size.width < image.size.height*ratio)
    {
        contxWidth = image.size.width;
        contxHeight = image.size.width/ratio;
        offsetx = 0.0;
        offsety = (contxHeight-image.size.height)/2;
    }
    else
    {
        contxHeight = image.size.height;
        contxWidth = contxHeight*ratio;
        offsetx = (contxWidth-image.size.width)/2;
        offsety = 0.0;
    }
    
    
    // Create a graphics image context
    UIGraphicsBeginImageContext(CGSizeMake(contxWidth, contxHeight));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, contxWidth, contxHeight));
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(offsetx, offsety, image.size.width, image.size.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}



@end
