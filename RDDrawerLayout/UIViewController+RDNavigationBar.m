//
//  UIViewController+RDNavigationBar.m
//  RDDrawerLayoutDemo
//
//  Created by radar on 2018/8/27.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "UIViewController+RDNavigationBar.h"
#import "objc/runtime.h"

@implementation UIViewController (RDNavigationBar)

//titleView
static char titleViewKey;
- (void)setTitleView:(UIView *)titleView
{
    objc_setAssociatedObject(self, &titleViewKey, titleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id)titleView
{
    return objc_getAssociatedObject(self, &titleViewKey);
}



@end
