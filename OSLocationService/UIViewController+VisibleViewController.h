//
//  UIViewController+UIViewController_VisibleViewController.h
//  OSLocationService
//
//  Created by David Haynes (C) on 07/01/2015.
//  Copyright (c) 2015 Ordnance Survey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VisibleViewController)

/**
 *  Finds the currently visible view controller in the view hierarchy.
 *
 *  @param rootViewController The root view controller to start traversing from
 *  (i.e. the application key window's rootViewController).
 *
 *  @return The view controller that is currently visibile (i.e. presented)
 */
+ (UIViewController *)visibleViewController:(UIViewController *)rootViewController;

@end
