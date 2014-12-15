//
//  OSLocationProvider.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSLocationService.h"
#import "OSServiceRelationshipManager.h"
#import "OSLocationServiceObserverProtocol.h"
#import "OSCoreLocationManager.h"

@import CoreLocation;

@interface OSLocationService () <OSServiceRelationshipManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) OSServiceRelationshipManager *relationshipManager;
@property (strong, nonatomic) CLLocationManager *coreLocationManager;

//Property redefinitions to make readwrite
@property (strong, nonatomic, readwrite) OSLocation *currentLocation;
@property (strong, nonatomic, readwrite) NSArray *cachedLocations;
@property (assign, nonatomic, readwrite) OSLocationDirection headingMagneticDegrees;
@property (assign, nonatomic, readwrite) OSLocationDirection headingTrueDegrees;
@property (assign, nonatomic, readwrite) double headingAccuracy;

@end

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

+ (instancetype)defaultService {
    static dispatch_once_t pred;
    static id sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _relationshipManager = [[OSServiceRelationshipManager alloc] init];
        _coreLocationManager.delegate = self;
        _shouldShowHeadingCalibration = YES;
        _locationAuthorizationStatus = [OSCoreLocationManager authorizationStatus];
    }
    return self;
}

#pragma mark - Starting updates

- (OSLocationServiceUpdateOptions)startUpdatingWithOptions:(OSLocationServiceUpdateOptions)updateOptions sender:(id)sender {
    NSAssert([self objectIsAcceptableForRelationshipManager:sender], @"Passed Sender object is not suitable");

    id identifyingObject = [self identifyingObjectFromObject:sender];

    OSLocationServiceUpdateOptions availableOptions = [OSLocationService availableOptions];
    OSLocationServiceUpdateOptions wantedAvailableOptions = updateOptions & availableOptions;

    OSLocationServiceUpdateOptions updatedOptions = [self.relationshipManager addOptions:wantedAvailableOptions forObject:identifyingObject];

    [self reactToNewCumulativeOptions];

    return updatedOptions;
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

    return [self.relationshipManager optionsForObject:sender];
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
        [self.coreLocationManager startUpdatingLocation];
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
    OSLocation *currentLocation = [[OSLocation alloc] initWithCoordinate:coordinate dateTaken:[NSDate date] horizontalAccuracy:mostRecentUpdate.horizontalAccuracy];

    [self willChangeValueForKey:@"currentLocation"];
    _currentLocation = currentLocation;
    [self didChangeValueForKey:@"currentLocation"];
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
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return self.shouldShowHeadingCalibration;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    OSLocationServiceAuthorizationStatus newStatus = [OSCoreLocationManager OSAuthorizationStatusFromCLAuthorizationStatus:status];

    [self willChangeValueForKey:@"locationAuthorizationStatus"];
    _locationAuthorizationStatus = newStatus;
    [self didChangeValueForKey:@"locationAuthorizationStatus"];
}

@end
