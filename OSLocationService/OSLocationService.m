//
//  OSLocationProvider.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSLocationService+Private.h"
#import "OSServiceRelationshipManager.h"
#import "OSLocationServiceObserverProtocol.h"
#import "OSCoreLocationManager.h"
#import "UIViewController+VisibleViewController.h"

@import CoreLocation;

NSString *const OSLocationServicesDisabledAlertHasBeenShown = @"LocationServicesDisabledAlertHasBeenShown";

@implementation OSLocationService

+ (OSLocationServiceUpdateOptions)availableOptions {
    OSLocationServiceUpdateOptions availableOptions = OSLocationServiceNoUpdates;

    if ([OSCoreLocationManager locationUpdatesAvailable]) {
        availableOptions = availableOptions | OSLocationServiceLocationUpdates;
    }

    if ([OSCoreLocationManager headingUpdatesAvailable]) {
        availableOptions = availableOptions | OSLocationServiceHeadingUpdates;
    }

    return availableOptions;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _relationshipManager = [[OSServiceRelationshipManager alloc] init];
        _coreLocationManager.delegate = self;
        _locationAuthorizationStatus = [OSCoreLocationManager osAuthorizationStatus];
        _permissionLevel = OSLocationServicePermissionWhenInUse;
    }
    return self;
}

#pragma mark - Starting updates

- (OSLocationServiceUpdateOptions)startUpdatingWithFirstDisabledWarningAndOptions:(OSLocationServiceUpdateOptions)updateOptions sender:(id)sender {

    BOOL alertHasBeenShown = [[NSUserDefaults standardUserDefaults] boolForKey:OSLocationServicesDisabledAlertHasBeenShown];

    if (!alertHasBeenShown && ![OSLocationService locationServicesEnabled]) {
        [self displayLocationServicesDisabledAlert];
        return OSLocationServiceNoUpdates;
    } else {
        OSLocationServiceUpdateOptions newOptions = [self startUpdatingWithOptions:updateOptions permissionLevel:OSLocationServicePermissionWhenInUse sender:sender];
        return newOptions;
    }
}

- (OSLocationServiceUpdateOptions)startUpdatingWithOptions:(OSLocationServiceUpdateOptions)updateOptions sender:(id)sender {
    OSLocationServiceUpdateOptions newOptions = [self startUpdatingWithOptions:updateOptions permissionLevel:OSLocationServicePermissionWhenInUse sender:sender];
    return newOptions;
}

- (OSLocationServiceUpdateOptions)startUpdatingWithOptions:(OSLocationServiceUpdateOptions)updateOptions permissionLevel:(OSLocationServicePermission)permissionLevel sender:(id)sender {
    NSAssert([self objectIsAcceptableForRelationshipManager:sender], @"Passed Sender object is not suitable");

    id identifyingObject = [self identifyingObjectFromObject:sender];

    OSLocationServiceUpdateOptions availableOptions = [OSLocationService availableOptions];
    OSLocationServiceUpdateOptions wantedAvailableOptions = updateOptions & availableOptions;

    OSLocationServiceUpdateOptions updatedOptions = [self.relationshipManager addOptions:wantedAvailableOptions forObject:identifyingObject];

    self.permissionLevel = permissionLevel;

    [self reactToNewCumulativeOptions];

    return updatedOptions;
}

- (void)displayLocationServicesDisabledAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Location Services Disabled", @"Location Services Disabled message title")
                                                                   message:NSLocalizedString(@"Location Services are required to view your location on the map. Go to settings to enable them.", @"Location Services Disabled message displayed on map screen")
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert addAction:settingsAction];

    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:dismissAction];

    //Delay presenting the alert for 400ms to allow for things to calm down on e.g. app start
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)400 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        UIViewController *visibleViewController = [UIViewController visibleViewController:UIApplication.sharedApplication.keyWindow.rootViewController];
        [visibleViewController presentViewController:alert animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:OSLocationServicesDisabledAlertHasBeenShown];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

#pragma mark - Stopping updates

- (OSLocationServiceUpdateOptions)stopUpdatesForOptions:(OSLocationServiceUpdateOptions)options sender:(id)sender {
    NSAssert([self objectIsAcceptableForRelationshipManager:sender], @"Passed Sender object is not suitable");

    id identifyingObject = [self identifyingObjectFromObject:sender];

    OSLocationServiceUpdateOptions remainingOptions = [self.relationshipManager removeOptions:options forObject:identifyingObject];

    [self reactToNewCumulativeOptions];

    return remainingOptions;
}

- (void)stopUpdatesForSender:(id)sender {
    NSAssert([self objectIsAcceptableForRelationshipManager:sender], @"Passed Sender object is not suitable");

    id identifyingObject = [self identifyingObjectFromObject:sender];

    OSLocationServiceUpdateOptions remainingOptions = [self stopUpdatesForOptions:OSLocationServiceAllOptions sender:identifyingObject];

    if (remainingOptions != OSLocationServiceNoUpdates) {
        NSDictionary *userInfo = @{ @"object" : sender,
                                    @"Options that could not be removed" : @(remainingOptions) };
        NSException *exception = [NSException exceptionWithName:@"Error removing all Options for object" reason:@"Could not remove some options for the specified object" userInfo:userInfo];
        [exception raise];
    }

    [self reactToNewCumulativeOptions];
}

#pragma mark - Current Options
- (OSLocationServiceUpdateOptions)optionsForSender:(id)sender {
    if (![self objectIsAcceptableForRelationshipManager:sender]) {
        return OSLocationServiceNoUpdates;
    }
    id identifyingObject = [self identifyingObjectFromObject:sender];
    return [self.relationshipManager optionsForObject:identifyingObject];
}

- (BOOL)objectIsAcceptableForRelationshipManager:(id)object {
    if (object == nil) {
        return NO;
    } else if ([object conformsToProtocol:@protocol(OSLocationServiceObserverProtocol)]) {
        return YES;
    } else if ([object conformsToProtocol:@protocol(NSCopying)]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)identifyingObjectFromObject:(id)object {
    if ([object conformsToProtocol:@protocol(OSLocationServiceObserverProtocol)]) {
        id<OSLocationServiceObserverProtocol> objectWithProtocol = object;
        return [objectWithProtocol locationServiceIdentifier];
    } else if ([object conformsToProtocol:@protocol(NSCopying)]) {
        return object;
    } else {
        return nil;
    }
}

#pragma mark - Updating Managers
- (void)relationshipManagerDidChangeRelationships:(OSServiceRelationshipManager *)manager {
    if (manager == self.relationshipManager) {
        [self reactToNewCumulativeOptions:[manager cumulativeOptions]];
    }
}

- (void)reactToNewCumulativeOptions {
    [self reactToNewCumulativeOptions:[self.relationshipManager cumulativeOptions]];
}

- (void)reactToNewCumulativeOptions:(OSLocationServiceUpdateOptions)options {
    //New Managers (e.g. Core Motion) will be added here
    [self handleCoreLocationManagerForOptions:options];
}

- (void)handleCoreLocationManagerForOptions:(OSLocationServiceUpdateOptions)options {
    BOOL wantsLocationUpdates = options & OSLocationServiceLocationUpdates;
    BOOL wantsHeadingUpdates = options & OSLocationServiceHeadingUpdates;

    if (self.coreLocationManager == nil) {
        self.coreLocationManager = [[CLLocationManager alloc] init];
        self.coreLocationManager.delegate = self;
    }

    if (wantsLocationUpdates) {
        self.coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.coreLocationManager startUpdatingLocation];
        } else {
            if (self.permissionLevel == OSLocationServicePermissionWhenInUse) {
                [self.coreLocationManager requestWhenInUseAuthorization];
            } else if (self.permissionLevel == OSLocationServicePermissionAlways) {
                [self.coreLocationManager requestAlwaysAuthorization];
            }
        }

    } else {
        [self.coreLocationManager stopUpdatingLocation];
    }

    if (wantsHeadingUpdates) {
        if (self.headingFilter == 0) {
            self.coreLocationManager.headingFilter = kCLHeadingFilterNone;
        } else {
            self.coreLocationManager.headingFilter = self.headingFilter;
        }

        [self.coreLocationManager startUpdatingHeading];
    } else {
        [self.coreLocationManager stopUpdatingHeading];
    }
}

#pragma mark - Updating Preferences
- (void)setHeadingFilter:(float)headingFilter {
    if (headingFilter == 0) {
        self.coreLocationManager.headingFilter = kCLHeadingFilterNone;
    } else {
        self.coreLocationManager.headingFilter = headingFilter;
    }

    _headingFilter = headingFilter;
}

#pragma mark - derived property
+ (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

#pragma mark - Core Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([locations count] > 1) {
        NSMutableArray *osLocations = [NSMutableArray arrayWithCapacity:[locations count]];
        for (CLLocation *location in locations) {
            OSLocation *osLocation = [[OSLocation alloc] initWithCoordinate:location.coordinate dateTaken:location.timestamp horizontalAccuracy:location.horizontalAccuracy];
            [osLocations addObject:osLocation];
        }

        [self willChangeValueForKey:@"cachedLocations"];
        _cachedLocations = [osLocations copy];
        [self didChangeValueForKey:@"cachedLocations"];
    }

    CLLocation *mostRecentUpdate = [locations lastObject];
    CLLocationCoordinate2D coordinate = mostRecentUpdate.coordinate;
    OSLocation *currentLocation = [[OSLocation alloc] initWithCoordinate:coordinate dateTaken:mostRecentUpdate.timestamp horizontalAccuracy:mostRecentUpdate.horizontalAccuracy];

    [self willChangeValueForKey:@"currentLocation"];
    _currentLocation = currentLocation;
    [self didChangeValueForKey:@"currentLocation"];

    if ([self.delegate respondsToSelector:@selector(locationService:didUpdateLocations:)]) {
        if ([locations count] > 1) {
            [self.delegate locationService:self didUpdateLocations:self.cachedLocations];
        } else {
            [self.delegate locationService:self didUpdateLocations:@[ currentLocation ]];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    [self willChangeValueForKey:@"headingTrueDegrees"];
    _headingTrueDegrees = newHeading.trueHeading;
    [self didChangeValueForKey:@"headingTrueDegrees"];

    [self willChangeValueForKey:@"headingMagneticDegrees"];
    _headingMagneticDegrees = newHeading.magneticHeading;
    [self didChangeValueForKey:@"headingMagneticDegrees"];

    [self willChangeValueForKey:@"headingAccuracy"];
    _headingAccuracy = newHeading.headingAccuracy;
    [self didChangeValueForKey:@"headingAccuracy"];

    if ([self.delegate respondsToSelector:@selector(locationService:didUpdateHeading:)]) {
        [self.delegate locationService:self didUpdateHeading:self.headingTrueDegrees];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    OSLocationServiceAuthorizationStatus newStatus = [OSCoreLocationManager OSAuthorizationStatusFromCLAuthorizationStatus:status];

    [self willChangeValueForKey:@"locationAuthorizationStatus"];
    _locationAuthorizationStatus = newStatus;
    [self didChangeValueForKey:@"locationAuthorizationStatus"];

    // Respond to change in location service permissions appropriately.
    // Ignore OSLocationServiceAuthorizationNotDetermined and OSLocationServiceAuthorizationUnknown.
    if (newStatus == OSLocationServiceAuthorizationAllowedWhenInUse || newStatus == OSLocationServiceAuthorizationAllowedAlways) {
        [self.coreLocationManager startUpdatingLocation];
    } else if (newStatus == OSLocationServiceAuthorizationDenied || newStatus == OSLocationServiceAuthorizationRestricted) {
        [self.coreLocationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(locationService:didFailWithError:)]) {
        [self.delegate locationService:self didFailWithError:error];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    // If there is no delegate set then we assume the calibration is of relatively low
    // importance at present. The documentation states that even without the calibration
    // screen, the device should eventually be able to calibrate itself anyway, so unless
    // otherwise asked, we'll assume it's ok to use the standard device behaviour.
    if (self.calibrationDelegate == nil) {
        return NO;
    } else {
        CLLocationDirection accuracyTolerance = 0;
        OSLocationServiceCalibrationImportance importance = [self.calibrationDelegate calibrationImportance];

        switch (importance) {
            case OSLocationServiceCalibrationImportanceNone:
                return NO; // All is good. Compass is precise enough.
            default:
                accuracyTolerance = (CLLocationDirection)importance;
                break;
        }

        if (self.headingAccuracy < 0) {
            return YES; // Negative value means invalid heading, so recalibrate
        } else if (self.headingAccuracy > accuracyTolerance) {
            return YES;
        }
    }
    return NO; // All is good. Compass is precise enough.
}

@end
