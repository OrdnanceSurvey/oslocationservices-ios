//
//  OSLocation.h
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OSMap/OSMap.h>

@import CoreLocation;

@interface OSLocation : NSObject

/** @name Properties */

/**
*  Latitude in float format.
*/
@property (assign, nonatomic, readonly) float latitude;

/**
 *  Longitude in float format.
 */
@property (assign, nonatomic, readonly) float longitude;

/**
 *  The date this location was valid for.
 */
@property (strong, nonatomic, readonly) NSDate *dateTaken;

/**
 *  The latitude and longitude of this location returned as a Core Location object.
 */
@property (assign, nonatomic, readonly) CLLocationCoordinate2D coordinate;


@property (assign, nonatomic, readonly) OSGridPoint gridPoint;


/** @name Initializers */

/**
 *  Initialize with latitude, longitude and a date
 *
 *  @param latitude  Latitude of co-ordinate
 *  @param longitude Longitude of co-ordinate
 *  @param date      Date this location was taken
 *
 *  @return Initialized OSLocation object
 */
- (instancetype)initWithLatitude:(float)latitude longitude:(float)longitude dateTaken:(NSDate *)date;

/**
 *  Initialize with the current date/time
 *
 *  @param latitude  Latitude of co-ordinate
 *  @param longitude Longitude of co-ordinate
 *
 *  @return Initialized OSLocation object
 */
- (instancetype)initWithLatitude:(float)latitude longitude:(float)longitude;

/**
 *  Initialize with a Core Location co-ordinate
 *
 *  @param coordinate Core Location co-ordinate
 *  @param date       Date this location was taken
 *
 *  @return Initialized OSLocation object
 */
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate dateTaken:(NSDate *)date;

@end
