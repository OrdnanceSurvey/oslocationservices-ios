//
//  OSLocation.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSLocation.h"

@implementation OSLocation

#pragma mark - Initializers
- (instancetype)initWithLatitude:(OSLocationDegrees)latitude longitude:(OSLocationDegrees)longitude dateTaken:(NSDate *)date horizontalAccuracy:(OSLocationAccuracy)horizontalAccuracy {
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _dateTaken = date;
        _horizontalAccuracyMeters = horizontalAccuracy;
    }
    return self;
}

- (instancetype)initWithLatitude:(OSLocationDegrees)latitude longitude:(OSLocationDegrees)longitude horizontalAccuracy:(OSLocationAccuracy)horizontalAccuracy {
    NSDate *dateNow = [NSDate date];
    self = [self initWithLatitude:latitude longitude:longitude dateTaken:dateNow horizontalAccuracy:horizontalAccuracy];
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate dateTaken:(NSDate *)date horizontalAccuracy:(OSLocationAccuracy)horizontalAccuracy {
    self = [self initWithLatitude:coordinate.latitude longitude:coordinate.longitude dateTaken:date horizontalAccuracy:horizontalAccuracy];
    return self;
}

#pragma mark - Equality

/**
 *  Test that two locations are equal, within tolerance.
 *
 *  @param other The location to compare to.
 *
 *  @return true if the two locations are the same object, or if they are within
 *  0.00001 degrees of each other in latitude and longitude (which is approximately
 *  1m at 50 degrees of latitude).
 */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if ([other isKindOfClass:[OSLocation class]]) {
        OSLocation *otherLocation = other;
        OSLocationDegrees distanceThreshold = 0.00001;
        if ((self.latitude - otherLocation.latitude) < distanceThreshold &&
            (self.longitude - otherLocation.longitude) < distanceThreshold) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

#pragma mark - Computed Property Getters

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (OSGridPoint)gridPoint {
    return OSGridPointForCoordinate([self coordinate]);
}

@end
