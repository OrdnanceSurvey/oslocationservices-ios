//
//  OSLocationProvider.h
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSLocation.h"
#import "OSLocationServiceOptions.h"
#import "OSLocationServicePreferences.h"

@class OSLocationService;

@protocol OSLocationServiceDelegate<NSObject>

@optional
- (void)locationService:(OSLocationService *)service didUpdateLocations:(NSArray *)locations;
- (void)locationService:(OSLocationService *)service didUpdateHeading:(OSLocationDirection)heading;
@end

@interface OSLocationService : NSObject

/** @name Check Available Options */

/**
 *  Not all options are available on all devices. For example, some devices do not have a compass for heading updates. Use this to check which services are available on the current device.
 *
 *  @return The available Options to activate.
 */
+ (OSLocationServiceUpdateOptions)availableOptions;

/** @name KVO Properties */

/** You should Observe these values for changes after turning on updates */

/**
 *  The last available location. Only updates when OSLocationServiceLocationUpdates is on.
 */
@property (strong, nonatomic, readonly) OSLocation *currentLocation;

/**
 *  An array of OSLocations that could not be previously delivered (e.g. because the app was in the background). May be in any order. Only updates when OSLocationServiceLocationUpdates is on.
 */
@property (strong, nonatomic, readonly) NSArray *cachedLocations;

//Heading

/**
 *  The device's heading in degrees relative to magnetic north. Only updates when OSLocationServiceHeadingUpdates is on.
 */
@property (assign, nonatomic, readonly) OSLocationDirection headingMagneticDegrees;

/**
 *  The device's heading in degrees relative to true north. Only updates when OSLocationServiceHeadingUpdates is on.
 */
@property (assign, nonatomic, readonly) OSLocationDirection headingTrueDegrees;

/**
 *  The accuracy of the heading values given. Only updates when OSLocationServiceHeadingUpdates is on.
 */
@property (assign, nonatomic, readonly) double headingAccuracy;

/** @name Service Preferences */
/** Set preferences for the service, such as accuracies */

/**
 *  Whether to show the system compass calibration screen. Defaults to YES.
 */
@property (assign, nonatomic) BOOL shouldShowHeadingCalibration;

/**
 *  The number of degrees the heading must change before values are updated. Set to 0 for no filter (all events).
 */
@property (assign, nonatomic) float headingFilter;

/**
 *  Find whether the app is authorized to use Location Services. Required for OSLocationServiceLocationUpdates. If not allowed, the option is not available. Observe this property for changes to the authorization status.
 */
@property (assign, nonatomic, readonly) OSLocationServiceAuthorizationStatus locationAuthorizationStatus;

/** @name Starting updates */

/**
 *  Trigger the location service to start getting updates.
 *  After calling this method, you should check the Options you passed are the same as the options returned, which indicates what actually what start updating. Options that are not available are overridden to off.
 *  Additionally, you should set up KVO to watch the properties you are intested in,
 *  or implement the OSLocationServiceDelegate protocol in a delegate.
 *
 *  @param updateOptions The properties you would like to start updating.
 *  @param sender        The object sending this method (i.e. self).
 *
 *  @return The actual options that will start to change. This may not be the same if, for example, an option you requested isn't available for this device. You should check that what you pass as an argument as Options and what is returned are equal, or act accoridngly if they are not.
 */
- (OSLocationServiceUpdateOptions)startUpdatingWithOptions:(OSLocationServiceUpdateOptions)updateOptions sender:(id)sender;

/** @name Stopping updates */

/**
 *  Stop all updates for the sender. The options will continue to update if another object has expressed interest in them. Throws an exception if some options could not be removed.
 *
 *  @param sender The object sending this method (i.e. self)
 */
- (void)stopUpdatesForSender:(id)sender;

/**
 *  Stop updates for only specific Options, whilst keeping any others on. The Options will continue to update if another object has expressed interest in them. Any Options passed that were not started by you will be ignored.
 *
 *  @param options Options you want to stop watching
 *  @param sender  The object sending this method (i.e. self)
 *  @return The remaining Options after the specified Options were removed
 */
- (OSLocationServiceUpdateOptions)stopUpdatesForOptions:(OSLocationServiceUpdateOptions)options sender:(id)sender;

/**
 *  The currently active Options for the object passed.
 *
 *  @param sender The object to lookup
 *
 *  @return The Options for the object
 */
- (OSLocationServiceUpdateOptions)optionsForSender:(id)sender;

@property (weak, nonatomic) id<OSLocationServiceDelegate> delegate;

@end
