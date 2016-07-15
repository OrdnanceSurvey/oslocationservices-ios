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
        _coreLocationManager.distanceFilter = self.distanceFilter;
        _coreLocationManager.desiredAccuracy = self.desiredAccuracy;
        _coreLocationManager.activityType = CLActivityTypeFitness;
    }
    return _coreLocationManager;
}

- (instancetype)initWithDelegate:(id<OSLocationProviderDelegate>)delegate {
    return [self initWithDelegate:delegate options:OSLocationServiceLocationUpdates purpose:OSLocationUpdatePurposeCurrentLocation];
}

- (instancetype)initWithDelegate:(id<OSLocationProviderDelegate>)delegate options:(OSLocationServiceUpdateOptions)options purpose:(OSLocationUpdatePurpose)purpose {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _updateOptions = options;
        _distanceFilter = kCLDistanceFilterNone;
        _updatePurpose = purpose;
        [self updateFiltersForPurpose:purpose];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateFiltersForPurpose:(OSLocationUpdatePurpose)purpose {
    switch (purpose) {
        case OSLocationUpdatePurposeCurrentLocation:
            _desiredAccuracy = kCLLocationAccuracyBest;
            break;
        case OSLocationUpdatePurposeNavigation:
            _desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            break;
        case OSLocationUpdatePurposeCustom:
            break;
    }
}

- (void)startLocationServiceUpdatesForAuthorisationStatus:(CLAuthorizationStatus)authorisationStatus {
    if (self.hasRequestedToUpdateLocation && [OSLocationProvider canProvideLocationUpdates]) {
        CLAuthorizationStatus existingAuthorisationStatus = [CLLocationManager authorizationStatus];
        switch (authorisationStatus) {
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                if (existingAuthorisationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || existingAuthorisationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                    [self.coreLocationManager startUpdatingLocation];
                } else {
                    [self.coreLocationManager requestWhenInUseAuthorization];
                }
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                if (existingAuthorisationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                    [self.coreLocationManager startUpdatingLocation];
                } else {
                    [self.coreLocationManager requestAlwaysAuthorization];
                }
                break;
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusNotDetermined:
            case kCLAuthorizationStatusRestricted:
                [NSException raise:NSInvalidArgumentException format:@"%@ is an invalid authorisation status. Request either kCLAuthorizationStatusAuthorizedWhenInUse or kCLAuthorizationStatusAuthorizedAlways", @(authorisationStatus)];
                break;
        }
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
        if (self.updatePurpose == OSLocationUpdatePurposeCustom) {
            _distanceFilter = distanceFilter;
            self.coreLocationManager.distanceFilter = distanceFilter;
        } else {
            NSLog(@"Distance filter not updated. Change the update frequency to OSLocationUpdatesFrequencyCustom to use custom distance filter");
        }
    }
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    if (_desiredAccuracy != desiredAccuracy) {
        if (self.updatePurpose == OSLocationUpdatePurposeCustom) {
            _desiredAccuracy = desiredAccuracy;
            self.coreLocationManager.desiredAccuracy = desiredAccuracy;
        } else {
            NSLog(@"Desired accuracy not updated. Change the update frequency to OSLocationUpdatesFrequencyCustom to use custom desired accuracy");
        }
    }
}

- (void)setContinueUpdatesInBackground:(BOOL)continueUpdatesInBackground {
    _continueUpdatesInBackground = continueUpdatesInBackground;
    self.coreLocationManager.allowsBackgroundLocationUpdates = _continueUpdatesInBackground;
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

    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.coreLocationManager startUpdatingLocation];
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
