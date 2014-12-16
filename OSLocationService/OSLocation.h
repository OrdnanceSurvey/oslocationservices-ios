//
//  OSLocation.h
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>
@import OSGridPointConversion;
@import CoreLocation;

/*
 *  OSLocationDirection
 *
 *    As per CLLocationDirection. Type used to represent heading in degrees from
 *    0 to 359.9. Negative value indicates an invalid direction.
 */
typedef double OSLocationDirection;

/*
 *  OSLocationDegrees
 *
 *    Used to represent a latitude or longitude in WGS84 projection.
 *    Values North of the equator or East of the Greenwich meridian will be postitive.
 *    Values South of the equator or West of the Greenwich meridian will be negative.
 */
typedef double OSLocationDegrees;

/*
 *  OSLocationAccuracy
 *
 *  Discussion:
 *    Represents a the accuracy of a location in meters. A lower value indicates
 *    a more precise location. Invalid locations will have negative accuracy.
 */
typedef double OSLocationAccuracy;

@interface OSLocation : NSObject
/** @name Properties */

/**
*  Latitude in float format.
*/
@property (assign, nonatomic, readonly) OSLocationDegrees latitude;

/**
 *  Longitude in float format.
 */
@property (assign, nonatomic, readonly) OSLocationDegrees longitude;

/**
 *  The date this location was valid for.
 */
@property (strong, nonatomic, readonly) NSDate *dateTaken;

/**
 *  The accuracy of the latitude and longitude for this location
 */
@property (assign, nonatomic, readonly) OSLocationAccuracy horizontalAccuracyMeters;

/**
 *  The latitude and longitude of this location returned as a Core Location object.
 */
@property (assign, nonatomic, readonly) CLLocationCoordinate2D coordinate;

/**
 *  The location as an British National Grid Point in eastings and northings
 */
@property (assign, nonatomic, readonly) OSGridPoint gridPoint;

/** @name Initializers */

/**
 *  Initialize with latitude, longitude and a date
 *
 *  @param latitude  Latitude of co-ordinate
 *  @param longitude Longitude of co-ordinate
 *  @param date      Date this location was taken
 *  @param horizontalAccuracy The accuracy of this measurement in meters
 *
 *  @return Initialized OSLocation object
 */
- (instancetype)initWithLatitude:(OSLocationDegrees)latitude
                       longitude:(OSLocationDegrees)longitude
                       dateTaken:(NSDate *)date
              horizontalAccuracy:(OSLocationAccuracy)horizontalAccuracy;

/**
 *  Initialize with the current date/time
 *
 *  @param latitude  Latitude of co-ordinate
 *  @param longitude Longitude of co-ordinate
 *  @param horizontalAccuracy The accuracy of this measurement in meters
 *
 *  @return Initialized OSLocation object
 */
- (instancetype)initWithLatitude:(OSLocationDegrees)latitude
                       longitude:(OSLocationDegrees)longitude
              horizontalAccuracy:(OSLocationAccuracy)horizontalAccuracy;

/**
 *  Initialize with a Core Location co-ordinate
 *
 *  @param coordinate Core Location co-ordinate
 *  @param date       Date this location was taken
 *  @param horizontalAccuracy The accuracy of this measurement in meters
 *
 *  @return Initialized OSLocation object
 */
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                         dateTaken:(NSDate *)date
                horizontalAccuracy:(OSLocationAccuracy)horizontalAccuracy;

@end
