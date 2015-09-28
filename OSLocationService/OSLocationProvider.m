//
//  OSLocationProvider.m
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

#import "OSLocationProvider.h"
#import "OSLocationProvider+Private.h"

const CLLocationDistance kDistanceFilterLow = 100;
const CLLocationDistance kDistanceFilterMedium = 40;
const CLLocationDistance kDistanceFilterHigh = 10;

@implementation OSLocationProvider

- (instancetype)initWithDelegate:(id<OSLocationProviderDelegate>)delegate {
    return [self initWithDelegate:delegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyMedium];
}

- (instancetype)initWithDelegate:(id<OSLocationProviderDelegate>)delegate options:(OSLocationServiceUpdateOptions)options frequency:(OSLocationUpdatesFrequency)frequency {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _updateOptions = options;
        _updateFrequency = frequency;
        [self updateFiltersForFrequency:frequency];
    }
    return self;
}

- (void)updateFiltersForFrequency:(OSLocationUpdatesFrequency)frequency {
    switch (frequency) {
        case OSLocationUpdatesFrequencyLow:
            _distanceFilter = kDistanceFilterLow;
            _desiredAccuracy = kCLLocationAccuracyBest;
            break;
        case OSLocationUpdatesFrequencyMedium:
            _distanceFilter = kDistanceFilterMedium;
            _desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            break;
        case OSLocationUpdatesFrequencyHigh:
        case OSLocationUpdatesFrequencyCustom:
            _distanceFilter = kDistanceFilterHigh;
            _desiredAccuracy = kCLLocationAccuracyHundredMeters;
            break;
    }
}

- (void)startLocationServiceUpdates {
    [self stopLocationServiceUpdates];
    if (self.coreLocationManager) {
        self.coreLocationManager = nil;
    }
    self.coreLocationManager = [[CLLocationManager alloc] init];
    self.coreLocationManager.delegate = self;
    self.coreLocationManager.pausesLocationUpdatesAutomatically = NO;
    self.coreLocationManager.distanceFilter = self.distanceFilter;
    self.coreLocationManager.desiredAccuracy = self.desiredAccuracy;
    self.coreLocationManager.activityType = CLActivityTypeFitness;

    if (self.hasRequestedToUpdateLocation) {
        //TODO: Handle permissions
        [self.coreLocationManager startUpdatingLocation];
    }
    if (self.hasRequestedToUpdateHeading) {
        [self.coreLocationManager startUpdatingHeading];
    }
}

- (void)stopLocationServiceUpdates {
    if (self.coreLocationManager) {
        if (self.hasRequestedToUpdateLocation) {
            [self.coreLocationManager stopUpdatingLocation];
        }
        if (self.hasRequestedToUpdateHeading) {
            [self.coreLocationManager stopUpdatingHeading];
        }
    }
}

- (BOOL)hasRequestedToUpdateLocation {
    return self.updateOptions & OSLocationServiceLocationUpdates;
}

- (BOOL)hasRequestedToUpdateHeading {
    return self.updateOptions & OSLocationServiceHeadingUpdates;
}

- (void)setDistanceFilter:(CLLocationDistance)distanceFilter {
    if (_distanceFilter != distanceFilter) {
        if (_updateFrequency == OSLocationUpdatesFrequencyCustom) {
            _distanceFilter = distanceFilter;
            self.coreLocationManager.distanceFilter = distanceFilter;
        } else {
            NSLog(@"Distance filter not updated. Change the update frequency to OSLocationUpdatesFrequencyCustom to use custom distance filter");
        }
    }
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    if (_desiredAccuracy != desiredAccuracy) {
        if (_updateFrequency == OSLocationUpdatesFrequencyCustom) {
            _desiredAccuracy = desiredAccuracy;
            self.coreLocationManager.desiredAccuracy = desiredAccuracy;
        } else {
            NSLog(@"Desired accuracy not updated. Change the update frequency to OSLocationUpdatesFrequencyCustom to use custom desired accuracy");
        }
    }
}

#pragma mark - Delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if ([self.delegate respondsToSelector:@selector(locationProvider:didUpdateLocations:)]) {
        [self.delegate locationProvider:self didUpdateLocations:locations];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([self.delegate respondsToSelector:@selector(locationProvider:didUpdateHeading:)]) {
        [self.delegate locationProvider:self didUpdateHeading:newHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(locationProvider:didFailWithError:)]) {
        [self.delegate locationProvider:self didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([self.delegate respondsToSelector:@selector(locationProvider:didChangeAuthorizationStatus:)]) {
        [self.delegate locationProvider:self didChangeAuthorizationStatus:status];
    }
}

@end
