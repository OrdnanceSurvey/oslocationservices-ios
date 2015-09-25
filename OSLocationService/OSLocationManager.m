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
        _activityType = CLActivityTypeFitness;
    }
    return self;
}

- (void)updateFiltersForFrequency:(OSLocationUpdatesFrequency)frequency {
    switch (frequency) {
        case OSLocationUpdatesFrequencyLow:
            _distanceFilter = 100;
            _desiredAccuracy = 10;
            break;
        case OSLocationUpdatesFrequencyMedium:
            _distanceFilter = 40;
            _desiredAccuracy = 25;
            break;
        case OSLocationUpdatesFrequencyHigh:
        case OSLocationUpdatesFrequencyCustom:
            _distanceFilter = 10;
            _desiredAccuracy = 40;
            break;
    }
}

- (void)startLocationServiceUpdatesWithOptions:(OSLocationServiceUpdateOptions)options {
    if (self.coreLocationManager) {
        [self stopLocationserviceUpdates];
        self.coreLocationManager = nil;
    }
    self.updateOptions = options;
    self.coreLocationManager = [[CLLocationManager alloc] init];
    self.coreLocationManager.delegate = self;
    self.coreLocationManager.pausesLocationUpdatesAutomatically = NO;
    self.coreLocationManager.distanceFilter = self.distanceFilter;
    self.coreLocationManager.desiredAccuracy = self.desiredAccuracy;
    self.coreLocationManager.activityType = self.activityType;
    [self.coreLocationManager startUpdatingLocation];
    [self.coreLocationManager startUpdatingHeading];
}

- (void)stopLocationserviceUpdates {
    if (self.coreLocationManager) {
        [self.coreLocationManager stopUpdatingLocation];
        [self.coreLocationManager stopUpdatingHeading];
    }
}

- (void)setDistanceFilter:(CLLocationDistance)distanceFilter {
    if (_distanceFilter != distanceFilter && _updateFrequency == OSLocationUpdatesFrequencyCustom) {
        _distanceFilter = distanceFilter;
    }
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    if (_desiredAccuracy != desiredAccuracy && _updateFrequency == OSLocationUpdatesFrequencyCustom) {
        _desiredAccuracy = desiredAccuracy;
    }
}

#pragma mark - Delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if ([self.delegate respondsToSelector:@selector(osLocationManager:didUpdateLocations:)]) {
        [self.delegate osLocationManager:self didUpdateLocations:locations];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([self.delegate respondsToSelector:@selector(osLocationManager:didUpdateHeading:)]) {
        [self.delegate osLocationManager:self didUpdateHeading:newHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(osLocationManager:didFailWithError:)]) {
        [self.delegate osLocationManager:self didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([self.delegate respondsToSelector:@selector(osLocationManager:didChangeAuthorizationStatus:)]) {
        [self.delegate osLocationManager:self didChangeAuthorizationStatus:status];
    }
}

@end
