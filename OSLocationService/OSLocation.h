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

/**
 *  OSLocationDistance
 *
 *  Discussion:
 *  Type used to represent a distance in meters.
 */
typedef double OSLocationDistance;

/*
 *  OSLocationDistanceMax
 *
 *  Discussion:
 *  	Used to specify the maximum OSLocationDistance
 */
extern const OSLocationDistance OSLocationDistanceMax;

/**
 *  kOSDistanceFilterNone
 *
 *  Discussion:
 *    Use as the distanceFilter to indicate location service that no minimum movement filter is desired
 */
extern const OSLocationDistance kOSDistanceFilterNone;

/*
 *  kOSLocationAccuracy<x>
 *
 *  Discussion:
 *    Used to specify the accuracy level desired. The location service will try its best to achieve
 *    your desired accuracy. However, it is not guaranteed. To optimize
 *    power performance, be sure to specify an appropriate accuracy for your usage scenario (eg,
 *    use a large accuracy value when only a coarse location is needed).
 */
extern const OSLocationAccuracy kOSLocationAccuracyBestForNavigation;
extern const OSLocationAccuracy kOSLocationAccuracyBest;
extern const OSLocationAccuracy kOSLocationAccuracyNearestTenMeters;
extern const OSLocationAccuracy kOSLocationAccuracyHundredMeters;
extern const OSLocationAccuracy kOSLocationAccuracyKilometer;
extern const OSLocationAccuracy kOSLocationAccuracyThreeKilometers;

@interface OSLocation : NSObject<NSCoding>
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

/**
 *  Test that two locations are equal, within tolerance.
 *
 *  @param other The location to compare to.
 *
 *  @return true if the two locations are within 0.00001 degrees of each other 
 *  in latitude and longitude (which is approximately 1m at 50 degrees of latitude).
 */
- (BOOL)isEqualToLocation:(OSLocation *)other;

@end
