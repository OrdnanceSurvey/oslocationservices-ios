//
//  UIViewController+UIViewController_VisibleViewController.m
//  OSLocationService
//
//  Created by David Haynes (C) on 07/01/2015.
//  Copyright (c) 2015 Ordnance Survey. All rights reserved.
//

#import "UIViewController+VisibleViewController.h"

@implementation UIViewController (VisibleViewController)

+ (UIViewController *)visibleViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];

        return [self visibleViewController:lastViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;

        return [self visibleViewController:selectedViewController];
    }

    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;

    return [self visibleViewController:presentedViewController];
}

@end
