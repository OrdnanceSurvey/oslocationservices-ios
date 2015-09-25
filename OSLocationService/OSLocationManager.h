//
//  OSLocationManager.h
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSLocationManagerDelegate.h"

typedef NS_ENUM(NSInteger, OSLocationUpdatesFrequency) {
    OSLocationUpdatesFrequencyLow,
    OSLocationUpdatesFrequencyMedium,
    OSLocationUpdatesFrequencyHigh,
    OSLocationUpdatesFrequencyCustom
};

@interface OSLocationManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id<OSLocationManagerDelegate>)delegate;
- (instancetype)initWithDelegate:(id<OSLocationManagerDelegate>)delegate frequency:(OSLocationUpdatesFrequency)frequency;

@end
