//
//  OSLocationService.h
//  OSLocationService
//
//  Created by Layla Gordon on 10/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OSMap/OSMap.h>

#pragma mark - NSNotifications


#define NOTIFICATION_DIRECTION_NEEDS_CHANGE @"NotificationDirectionNeedsChange"

#define NOTIFICATION_LOCATION_SERVICES_ERROR @"NotificationLocationServicesError"

#define NOTIFICATION_COORD_SYSTEM_CHANGE @"NotificationCoordSystemChange"
#define NOTIFICATION_ALT_UNIT_CHANGE @"NotificationAltUnitChange"

#define NOTIFICATION_GRID_REFF_CHANGE @"NotificationGridReffChange"


@interface OSLocationService : NSObject
+ (OSLocationService *) shared;


/**
 startUpdatingLocation will start the location based services
 locatiion update .
 */
//- (BOOL)startUpdatingLocationWithAccuracy:(CLLocationAccuracy)accuracy;

/**
 stopUpdatingLocation
 */

-(BOOL) stopUpdatingLocation;

/**
 stopUpdatingHeading
 */

-(BOOL) stopUpdatingHeading;


/**
 startUpdatingHeading will start the location based services
 heading update.
 */
-(BOOL) startUpdatingHeading;

/**
 startAllServices will start all the location based services
 locatiion update and heading update.
 It returns NO if the Location service is not available or switched Off
 in the Settings
 */
//-(BOOL) startAllServices;

/**
 startAllServices will start all the location based services
 locatiion update and heading update with a desired accuracy value .
 It returns NO if the Location service is not available or switched Off
 in the Settings
 */

-(BOOL) startAllServicesWithAccuracy:(CLLocationAccuracy) accuracyValue;


/**
 stopAllServices will stop all the location based services
 locatiion update and heading update.
 
 */
-(BOOL) stopAllServices;

/**
 getGridPointRefference will return the National Grid details .
 a String which will have a grid easting and northing .
 */

//-(BOOL) isIpod;

-(NSString*) getGridPointRefference:(CLLocationCoordinate2D)coordinate;

/**
 The current position as OS Grid Reference with 3 digits per axis. Can be nil.
 */

//-(void) tryRestartingServices;

- (BOOL) isInUSA;

@property (strong, readonly) NSString *currentGridReferencePosition;
@property (strong, nonatomic) CLLocation *currentLatLongPosition;

/**
 If you return YES from this method, Core Location displays the heading calibration alert on top of the current window immediately. The calibration alert prompts the user to move the device in a particular pattern so that Core Location can distinguish between the Earth’s magnetic field and any local magnetic fields. The alert remains visible until calibration is complete or until you explicitly dismiss it by calling the dismissHeadingCalibrationDisplay method. In the latter case, you can use this method to set up a timer and dismiss the interface after a specified amount of time has elapsed.
 */
@property (assign, nonatomic)BOOL locationManagerShouldDisplayHeadingCalibration;

@property (assign, readonly) double curaltitude;



//@property NSString *documentTXTPath;

@end


