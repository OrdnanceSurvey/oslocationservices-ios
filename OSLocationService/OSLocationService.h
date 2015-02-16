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
#import "OSLocationServiceObserverProtocol.h"

//! Project version number for OSGridPointConversion framework.
FOUNDATION_EXPORT double OSLocationServiceVersionNumber;

//! Project version string for OSGridPointConversion framework.
FOUNDATION_EXPORT const unsigned char OSLocationServiceVersionString[];

@class OSLocationService;

@protocol OSLocationServiceDelegate<NSObject>

@optional

/**
 *  locationService:didUpdateLocations:
 *
 *  Called when the service has one or more locations to notify the delegate about.
 *  If the service has deferred location updates to deliver then the array will
 *  contain more than one location object.
 *
 *  @param service   The instance of OSLocationService that has received the updated location(s).
 *  @param locations An array of one or more OSLocation objects in chronological order.
 */
- (void)locationService:(OSLocationService *)service didUpdateLocations:(NSArray *)locations;

/**
 *  locationService:didUpdateHeading:
 *
 *  Invoked when a new heading update is received by the service.
 *
 *  @param service Instance of OSLocationService that has received the updated heading.
 *  @param heading The heading in degrees from 0 to 359.9. Negative value indicates an invalid direction.
 */
- (void)locationService:(OSLocationService *)service didUpdateHeading:(OSLocationDirection)heading;

/**
 *  locationService:didFailWithError:
 *
 *  Invoked when an error is received by the service.
 *
 *  @param service Instance of OSLocationService that has received the error.
 *  @param error   The error received from the Corelocation Framework
 */
- (void)locationService:(OSLocationService *)service didFailWithError:(NSError *)error;

@end

/**
 *  How important is it to calibrate the location services
 */
typedef NS_ENUM(NSInteger, OSLocationServiceCalibrationImportance) {
    /**
     *  Not important, the device won't show the calibration UI
     */
    OSLocationServiceCalibrationImportanceNone,
    /**
     *  High importance, the device will accept a low variance in accuracy
     */
    OSLocationServiceCalibrationImportanceHigh = 1,
    /**
     *  Medium importance, the device will accept a medium variance in accuracy
     */
    OSLocationServiceCalibrationImportanceMedium = 5,
    /**
     *  Low importance, the device will accept a high variance in accuracy
     */
    OSLocationServiceCalibrationImportanceLow = 15
};

/**
 *  Delegate protocol to implement to query the calibration requirements for the service
 */
@protocol OSLocationServiceCalibrationDelegate<NSObject>

/**
 *  How important is it to calibrate the device
 *
 *  @return OSLocationServiceCalibrationImportance
 */
- (OSLocationServiceCalibrationImportance)calibrationImportance;

@end

/**
 *  OSLocationService
 *
 *  Service that abstracts Core Location to provide location and orientation 
 *  updates. Can be used with delegation using the OSLocationServiceDelegate
 *  procotol, or by using KVO on the properties below.
 */
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
@property (assign, nonatomic, readonly) OSLocationAccuracy headingAccuracy;

/** @name Service Preferences */
/** Set preferences for the service, such as accuracies */

/**
 *  Delegate to query whether we should display the calibration screen. If not set, the default
 *  behaviour is not to show the calibration screen.
 */
@property (weak, nonatomic) id<OSLocationServiceCalibrationDelegate> calibrationDelegate;

/**
 *  The number of degrees the heading must change before values are updated. Set to 0 for no filter (all events).
 */
@property (assign, nonatomic) float headingFilter;

/**
 *  Find whether the app is authorized to use Location Services. Required for OSLocationServiceLocationUpdates. If not allowed, the option is not available. Observe this property for changes to the authorization status.
 */
@property (assign, nonatomic, readonly) OSLocationServiceAuthorizationStatus locationAuthorizationStatus;

/**
 *  Indicates whether location services are enabled on the device.
 *
 *  @return true if location services are turned on, false if location services are turned off.
 */
+ (BOOL)locationServicesEnabled;

/** @name Starting updates */

/**
 *  Trigger the location service to start getting updates.
 *
 *  After calling this method, you should check the Options you passed are the same as the options returned, which indicates what actually what start updating. Options that are not available are overridden to off.
 *  Additionally, you should set up KVO to watch the properties you are intested in,
 *  or implement the OSLocationServiceDelegate protocol in a delegate.
 *
 *  @param updateOptions   The properties you would like to start updating.
 *  @param sender          The object sending this method (i.e. self).
 *  @param permissionLevel The desire location permission level ("always" or "when in use").
 *
 *  @return The actual options that will start to change. This may not be the same if, for example, an option you requested isn't available for this device. You should check that what you pass as an argument as Options and what is returned are equal, or act accoridngly if they are not.
 */
- (OSLocationServiceUpdateOptions)startUpdatingWithOptions:(OSLocationServiceUpdateOptions)updateOptions permissionLevel:(OSLocationServicePermission)permissionLevel sender:(id)sender;

/**
 *  Trigger the location service to start getting updates with default "when in use" permission level
 *
 *  @param updateOptions   The properties you would like to start updating.
 *  @param sender          The object sending this method (i.e. self).
 *
 *  @return The actual options that will start to change. This may not be the same if, for example, an option you requested isn't available for this device. You should check that what you pass as an argument as Options and what is returned are equal, or act accoridngly if they are not.
 */
- (OSLocationServiceUpdateOptions)startUpdatingWithOptions:(OSLocationServiceUpdateOptions)updateOptions sender:(id)sender;

/**
 *  Trigger location service to start, with a warning alert the first time if location services are disabled.
 *
 *  @param updateOptions The properties you would like to start updating.
 *  @param sender        The object sending this method (i.e. self).
 *
 *  @return The actual options that will start to change. This may not be the same if, for example, an option you requested isn't available for this device. You should check that what you pass as an argument as Options and what is returned are equal, or act accoridngly if they are not.
 */
- (OSLocationServiceUpdateOptions)startUpdatingWithFirstDisabledWarningAndOptions:(OSLocationServiceUpdateOptions)updateOptions sender:(id)sender;

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

/**
 *  If updates are needed in background, then this flag should be set to YES. The default implementation stops updates if the app is in background and resumes once it is in foreground.
 */
@property (assign, nonatomic) BOOL continueUpdatesInBackground;

@end
