//
//  OSLocationProviderProtocol.h
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

@class OSLocationProvider;
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

@protocol OSLocationProviderDelegate<NSObject>

@optional
/**
 *  Invoked when new locations are available.
 *
 *  @param manager   `OSLocationProvider` invoking the method
 *  @param locations array of CLLocation objects in chronological order
 */
- (void)locationProvider:(OSLocationProvider *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;

/**
 *  Invoked when a new heading is available
 *
 *  @param manager    `OSLocationProvider` invoking the method
 *  @param newHeading the updated new heading
 */
- (void)locationProvider:(OSLocationProvider *)manager didUpdateHeading:(CLHeading *)newHeading;

/**
 *  Invoked when an error has occurred.
 *
 *  @param manager `OSLocationProvider` invoking the method
 *  @param error   error describing the cause of failure. Error types are defined in "CLError.h".
 */
- (void)locationProvider:(OSLocationProvider *)manager didFailWithError:(NSError *)error;

/**
 *  Invoked when the authorization status changes for the application
 *
 *  @param manager `OSLocationProvider` invoking the method
 *  @param status  the updated authorization status
 */
- (void)locationProvider:(OSLocationProvider *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end

NS_ASSUME_NONNULL_END