//
//  OSLocationManager.m
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

#import "OSLocationManager.h"
#import "OSLocationManager+Private.h"

@implementation OSLocationManager

- (instancetype)initWithDelegate:(id<OSLocationManagerDelegate>)delegate {
    return [self initWithDelegate:delegate frequency:OSLocationUpdatesFrequencyMedium];
}

- (instancetype)initWithDelegate:(id<OSLocationManagerDelegate>)delegate frequency:(OSLocationUpdatesFrequency)frequency {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _updateFrequency = frequency;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
        [self.delegate locationManager:self didUpdateLocations:locations];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
        [self.delegate locationManager:self didUpdateHeading:newHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
        [self.delegate locationManager:self didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([self.delegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)]) {
        [self.delegate locationManager:self didChangeAuthorizationStatus:status];
    }
}

@end
