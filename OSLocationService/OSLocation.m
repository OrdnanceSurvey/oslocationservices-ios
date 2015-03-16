//
//  OSLocation.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSLocation.h"

NSString *const kOSLocationLatitudeKey = @"OSLocationLatitudeKey";
NSString *const kOSLocationLongitudeKey = @"OSLocationLongitudeKey";
NSString *const kOSLocationDateTakenKey = @"OSLocationDateTakenKey";
NSString *const kOSLocationHorizontalAccuracyKey = @"OSLocationHorizontalAccuracyKey";
const OSLocationDistance kOSDistanceFilterNone;
const OSLocationAccuracy kOSLocationAccuracyBestForNavigation;
const OSLocationAccuracy kOSLocationAccuracyBest;
const OSLocationAccuracy kOSLocationAccuracyNearestTenMeters;
const OSLocationAccuracy kOSLocationAccuracyHundredMeters;
const OSLocationAccuracy kOSLocationAccuracyKilometer;
const OSLocationAccuracy kOSLocationAccuracyThreeKilometers;

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

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if ([other isKindOfClass:[OSLocation class]]) {
        return [self isEqualToLocation:(OSLocation *)other];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToLocation:(OSLocation *)other {
    OSLocationDegrees distanceThreshold = 0.00001;
    if ((self.latitude - other.latitude) < distanceThreshold &&
        (self.longitude - other.longitude) < distanceThreshold) {
        return YES;
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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSNumber numberWithDouble:self.latitude] forKey:kOSLocationLatitudeKey];
    [encoder encodeObject:[NSNumber numberWithDouble:self.longitude] forKey:kOSLocationLongitudeKey];
    [encoder encodeObject:[NSNumber numberWithDouble:self.horizontalAccuracyMeters] forKey:kOSLocationHorizontalAccuracyKey];
    [encoder encodeObject:self.dateTaken forKey:kOSLocationDateTakenKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    OSLocationDegrees latitude = [[decoder decodeObjectForKey:kOSLocationLatitudeKey] doubleValue];
    OSLocationDegrees longitude = [[decoder decodeObjectForKey:kOSLocationLongitudeKey] doubleValue];
    NSDate *date = [decoder decodeObjectForKey:kOSLocationDateTakenKey];
    OSLocationAccuracy accuracy = [[decoder decodeObjectForKey:kOSLocationHorizontalAccuracyKey] doubleValue];
    OSLocation *location = [self initWithLatitude:latitude longitude:longitude dateTaken:date horizontalAccuracy:accuracy];
    return location;
}

@end
