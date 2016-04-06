//
//  OSLocationProvider.m
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

#import "OSLocationProvider.h"
#import "OSLocationProvider+Private.h"

@import UIKit.UIDevice;
@import UIKit.UIApplication;

const CLLocationDistance kDistanceFilterLow = 100;
const CLLocationDistance kDistanceFilterMedium = 40;
const CLLocationDistance kDistanceFilterHigh = 10;

@implementation OSLocationProvider

- (CLLocationManager *)coreLocationManager {
    if (!_coreLocationManager) {
        _coreLocationManager = [[CLLocationManager alloc] init];
        _coreLocationManager.delegate = self;
        _coreLocationManager.pausesLocationUpdatesAutomatically = NO;
        _coreLocationManager.distanceFilter = self.distanceFilter;
        _coreLocationManager.desiredAccuracy = self.desiredAccuracy;
        _coreLocationManager.activityType = CLActivityTypeFitness;
    }
    return _coreLocationManager;
}

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

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
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

- (void)startLocationServiceUpdatesForAuthorisationStatus:(CLAuthorizationStatus)authorisationStatus {
    if (self.hasRequestedToUpdateLocation && [OSLocationProvider canProvideLocationUpdates]) {
        switch (authorisationStatus) {
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [self.coreLocationManager requestWhenInUseAuthorization];
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                [self.coreLocationManager requestAlwaysAuthorization];
                break;
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusNotDetermined:
            case kCLAuthorizationStatusRestricted:
                [NSException raise:NSInvalidArgumentException format:@"%@ is an invalid authorisation status. Request either kCLAuthorizationStatusAuthorizedWhenInUse or kCLAuthorizationStatusAuthorizedAlways", @(authorisationStatus)];
                break;
            default:
                break;
        }
        [self.coreLocationManager startUpdatingLocation];
    }
    if (self.hasRequestedToUpdateHeading && [OSLocationProvider canProvideHeadingUpdates]) {
        [self.coreLocationManager startUpdatingHeading];
    }
}

- (void)stopLocationServiceUpdates {
    if (self.hasRequestedToUpdateLocation) {
        [self.coreLocationManager stopUpdatingLocation];
    }
    if (self.hasRequestedToUpdateHeading) {
        [self.coreLocationManager stopUpdatingHeading];
    }
}

+ (BOOL)canProvideLocationUpdates {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    return [CLLocationManager locationServicesEnabled] && (authorizationStatus != kCLAuthorizationStatusRestricted || authorizationStatus != kCLAuthorizationStatusDenied);
}

+ (BOOL)canProvideHeadingUpdates {
    return [CLLocationManager headingAvailable];
}

- (BOOL)hasRequestedToUpdateLocation {
    return self.updateOptions & OSLocationServiceLocationUpdates;
}

- (BOOL)hasRequestedToUpdateHeading {
    return self.updateOptions & OSLocationServiceHeadingUpdates;
}

#pragma mark - Setters
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

#pragma mark - Notifications
- (void)didEnterBackground:(id)sender {
    if (self.coreLocationManager && !self.continueUpdatesInBackground) {
        [self.coreLocationManager stopUpdatingLocation];
        [self.coreLocationManager stopUpdatingHeading];
    }
}

- (void)willEnterForeground:(id)sender {
    if (self.coreLocationManager && !self.continueUpdatesInBackground) {
        [self.coreLocationManager startUpdatingLocation];
        [self.coreLocationManager startUpdatingHeading];
    }
}

- (void)orientationChanged {
    self.coreLocationManager.headingOrientation = (CLDeviceOrientation)UIDevice.currentDevice.orientation;
}

- (void)dealloc {
    _coreLocationManager.delegate = nil;
    [self stopLocationServiceUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
