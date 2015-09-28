//
//  OSLocationProvider.h
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSLocationProviderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Different frequency options for location updates
 */
typedef NS_ENUM(NSInteger, OSLocationUpdatesFrequency) {
    /**
     *  Low frequency updates at 100 meters with accuracy kCLLocationAccuracyBest
     */
    OSLocationUpdatesFrequencyLow,
    /**
     *  Medium frequency updates at 40 meters with accuracy kCLLocationAccuracyNearestTenMeters
     */
    OSLocationUpdatesFrequencyMedium,
    /**
     *  High frequency updates at 10 meters with accuracy kCLLocationAccuracyHundredMeters
     */
    OSLocationUpdatesFrequencyHigh,
    /**
     *  Custom frequency updates. Use `distanceFilter` and `desiredAccuracy` properties to set desired values.
     */
    OSLocationUpdatesFrequencyCustom
};

/**
 *  Different update options for location and heading
 */
typedef NS_OPTIONS(NSUInteger, OSLocationServiceUpdateOptions) {
    /**
     *  Receive no updates
     */
    OSLocationServiceNoUpdates = 0,
    /**
     *  Receive only location change updates
     */
    OSLocationServiceLocationUpdates = 1 << 0,
    /**
     *  Receive only heading change updates
     */
    OSLocationServiceHeadingUpdates = 1 << 1,
    /**
     *  Receive both location and heading change updates
     */
    OSLocationServiceAllOptions = OSLocationServiceLocationUpdates | OSLocationServiceHeadingUpdates
};

/**
 * Wrapper around core location
 */
@interface OSLocationProvider : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Convenience initialiser with `OSLocationUpdatesFrequencyMedium` update frequency
 *
 *  @param delegate the delegate to receive callback
 *
 *  @return instance of `OSLocationProvider`
 */
- (instancetype)initWithDelegate:(id<OSLocationProviderDelegate>)delegate;

/**
 *  Designated initialiser
 *
 *  @param delegate  the delegate to receive callback
 *  @param frequency the frequency for the updates
 *
 *  @return instance of `OSLocationProvider`
 */
- (instancetype)initWithDelegate:(id<OSLocationProviderDelegate>)delegate frequency:(OSLocationUpdatesFrequency)frequency NS_DESIGNATED_INITIALIZER;

/**
 *  Starts location service updates
 *
 *  @param options the different updates needed
 */
- (void)startLocationServiceUpdatesWithOptions:(OSLocationServiceUpdateOptions)options;

/**
 *  Stops current location service updates
 */
- (void)stopLocationServiceUpdates;

/**
 *  Specifies the minimum update distance in meters
 */
@property (assign, nonatomic) CLLocationDistance distanceFilter;

/**
 *  The desired location accuracy
 */
@property (assign, nonatomic) CLLocationAccuracy desiredAccuracy;

@end

NS_ASSUME_NONNULL_END