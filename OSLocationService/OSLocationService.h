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

@interface OSLocationService : NSObject

/** @name Instances */

/**
*  The default instance. You should only use the default instance to avoid conflicting management of
*  underlying services.
*
*  @return The default OSLocationService
*/
+ (instancetype)defaultService;


/** @name Check Available Options */

/**
 *  Not all options are available on all devices. For example, some devices do not have a compass for heading updates. Use this to check which services are available on the current device.
 *
 *  @return The available Options to activate.
 */
+ (OSLocationServiceUpdateOptions)availableOptions;


/** @name Properties */

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
@property (assign, nonatomic, readonly) double headingMagneticDegrees;

/**
 *  The device's heading in degrees relative to true north. Only updates when OSLocationServiceHeadingUpdates is on.
 */
@property (assign, nonatomic, readonly) double headingTrueDegrees;

/**
 *  The accuracy of the heading values given.
 */
@property (assign, nonatomic, readonly) double headingAccuracy;


/** @name Starting updates */



/**
 *  Trigger the location service to start getting updates.
 *  After calling this method, you should check the Options you passed are the same as the options returned, which indicates what actually what start updating. Options that are not available are overridden to off.
 *  Additionally, you should set up KVO to watch the properties you are intested in.
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

@end
