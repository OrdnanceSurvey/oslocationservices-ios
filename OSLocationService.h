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


/** @name Properties */

@property (strong, nonatomic) OSLocation *currentLocation;


/** @name Starting updates */

/**
 *  Trigger the location service to start getting updates.
 *  After calling this method, you should check the Options you passed are the same as the options returned, which indicates what actually what start updating.
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
 *  Stop all updates for the sender. The options will continue to update if another object has expressed interest in them.
 *
 *  @param sender The object sending this method (i.e. self)
 */
- (void)stopUpdatesForSender:(id)sender;

/**
 *  Stop updates for only specific Options, whilst keeping any others on. The Options will continue to update if another object has expressed interest in them. Any Options passed that were not started by you will be ignored.
 *
 *  @param options Options you want to stop watching
 *  @param sender  The object sending this method (i.e. self)
 */
- (void)stopUpdatesForOptions:(OSLocationServiceUpdateOptions)options sender:(id)sender;

@end
