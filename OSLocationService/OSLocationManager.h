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

typedef NS_OPTIONS(NSUInteger, OSLocationServiceUpdateOptions) {
    OSLocationServiceNoUpdates = 0,
    OSLocationServiceLocationUpdates = 1 << 0,
    OSLocationServiceHeadingUpdates = 1 << 1,
    OSLocationServiceAllOptions = OSLocationServiceLocationUpdates | OSLocationServiceHeadingUpdates
};

@interface OSLocationManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id<OSLocationManagerDelegate>)delegate;
- (instancetype)initWithDelegate:(id<OSLocationManagerDelegate>)delegate frequency:(OSLocationUpdatesFrequency)frequency;

- (void)startLocationServiceUpdatesWithOptions:(OSLocationServiceUpdateOptions)options;
- (void)stopLocationserviceUpdates;

@property (assign, nonatomic) CLActivityType activityType;
@property (assign, nonatomic) CLLocationDistance distanceFilter;
@property (assign, nonatomic) CLLocationAccuracy desiredAccuracy;

@end
