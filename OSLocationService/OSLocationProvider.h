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
 *  Options for predefined setups for the location provider
 */
typedef NS_ENUM(NSInteger, OSLocationUpdatePurpose) {
    /**
     *  The provider will be used to provide the user's location.
     *  No distance filter will be set and the desired accuracy will be set to 
     *  `kCLLocationAccuracyBest`
     */
    OSLocationUpdatePurposeCurrentLocation,
    /**
     *  The provider will be used to provide the navigation information.
     *  No distance filter will be set and the desired accuracy will be set to
     *  `kCLLocationAccuracyBestForNavigation`
     */
    OSLocationUpdatePurposeNavigation,
    /**
     *  The provider will be used to route recording.
     *  5 meters distance filter will be set and the desired accuracy will be set to
     *  `kCLLocationAccuracyBestForNavigation`
     */
    OSLocationUpdatePurposeRouteRecording,
    /**
     *  The provider is being used for an unknown purpose. `distanceFilter`
     *  and `desiredAccuracy` properties should be set as desired.
     */
    OSLocationUpdatePurposeCustom
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

@property (weak, nonatomic) id<OSLocationProviderDelegate> delegate;

/**
 *  Convenience initialiser with `OSLocationServiceLocationUpdates` options and `OSLocationUpdatePurposeCurrentLocation` purpose
 *
 *  @param delegate the delegate to receive callback
 *
 *  @return instance of `OSLocationProvider`
 */
- (instancetype)initWithDelegate:(id<OSLocationProviderDelegate> _Nullable)delegate;

/**
 *  Designated initialiser
 *
 *  @param delegate  the delegate to receive callback
 *  @param options   the different updates needed
 *  @param purpose   the purpose of the provider
 *
 *  @return instance of `OSLocationProvider`
 */
- (instancetype)initWithDelegate:(id<OSLocationProviderDelegate> _Nullable)delegate options:(OSLocationServiceUpdateOptions)options purpose:(OSLocationUpdatePurpose)purpose NS_DESIGNATED_INITIALIZER;

/**
 *  Starts location service updates by requesting authorization of the given
 *  status.
 *  Calling this method several times in succession does not automatically result in new events being generated. Calling stopUpdatingLocation in between, however, does cause a new initial event to be sent the next time you call this method.
 *
 *  @param authorisationStatus The authorisation status to request location
 *  updates for. Raises an exception unless
 *  `kCLAuthorizationStatusAuthorizedAlways` or
 *  `kCLAuthorizationStatusAuthorizedWhenInUse` is given.
 */
- (void)startLocationServiceUpdatesForAuthorisationStatus:(CLAuthorizationStatus)authorisationStatus;

/**
 *  Stops current location service updates
 */
- (void)stopLocationServiceUpdates;

/**
 *  Indicates whether location provider can provide location updates.
 */
+ (BOOL)canProvideLocationUpdates;

/**
 *  Indicates whether location provider can provide heading updates.
 */
+ (BOOL)canProvideHeadingUpdates;

/**
 *  Specifies the minimum update distance in meters
 */
@property (assign, nonatomic) CLLocationDistance distanceFilter;

/**
 *  The desired location accuracy
 */
@property (assign, nonatomic) CLLocationAccuracy desiredAccuracy;

/**
 *  If updates are needed in background, then this flag should be set to YES. The default implementation stops updates if the app is in background and resumes once it is in foreground.
 */
@property (assign, nonatomic) BOOL continueUpdatesInBackground;

/**
 *  Should we allow the underlying location manager to defer updates?
 */
@property (assign, nonatomic) BOOL allowsDeferredUpdates;

@end

NS_ASSUME_NONNULL_END
