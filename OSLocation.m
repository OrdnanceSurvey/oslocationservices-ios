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
- (instancetype)initWithLatitude:(float)latitude longitude:(float)longitude dateTaken:(NSDate *)date
{
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _dateTaken = date;
    }
    return self;
}

- (instancetype)initWithLatitude:(float)latitude longitude:(float)longitude
{
    NSDate *dateNow = [NSDate date];
    self = [self initWithLatitude:latitude longitude:longitude dateTaken:dateNow];
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate dateTaken:(NSDate *)date
{
    self = [self initWithLatitude:coordinate.latitude longitude:coordinate.longitude dateTaken:date];
    return self;
}

#pragma mark - Computed Property Getters

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

@end
