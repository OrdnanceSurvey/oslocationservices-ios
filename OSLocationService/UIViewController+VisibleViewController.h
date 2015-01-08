//
//  UIViewController+UIViewController_VisibleViewController.h
//  OSLocationService
//
//  Created by David Haynes (C) on 07/01/2015.
//  Copyright (c) 2015 Ordnance Survey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VisibleViewController)

+ (UIViewController *)visibleViewController:(UIViewController *)rootViewController;

@end
