//
//  ViewController.h
//  OSLocationTestHost
//
//  Created by David Haynes (C) on 15/12/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <UIKit/UIKit.h>
@import OSLocationService;

@interface ViewController : UIViewController<OSLocationServiceDelegate, OSLocationServiceObserverProtocol>

@end
