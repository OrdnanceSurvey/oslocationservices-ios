//
//  OSLocationProvider.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSLocationService.h"
#import "OSServiceRelationshipManager.h"

@import CoreLocation;

@interface OSLocationService () <OSServiceRelationshipManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) OSServiceRelationshipManager *relationshipManager;
@property (strong, nonatomic) CLLocationManager *coreLocationManager;

@end

@implementation OSLocationService

+ (OSLocationServiceUpdateOptions)availableOptions
{
    OSLocationServiceUpdateOptions availableOptions = OSLocationServiceNoUpdates;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        availableOptions = availableOptions | OSLocationServiceLocationUpdates;
    }
    
    if ([CLLocationManager headingAvailable]) {
        availableOptions = availableOptions | OSLocationServiceHeadingUpdates;
    }
    
    return availableOptions;
}

+ (instancetype)defaultService
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _relationshipManager = [[OSServiceRelationshipManager alloc] init];
        _coreLocationManager = [[CLLocationManager alloc] init];
        _coreLocationManager.delegate = self;
    }
    return self;
}

#pragma mark - Starting updates

- (OSLocationServiceUpdateOptions)startUpdatingWithOptions:(OSLocationServiceUpdateOptions)updateOptions sender:(id)sender
{
    OSLocationServiceUpdateOptions availableOptions = [OSLocationService availableOptions];
    OSLocationServiceUpdateOptions wantedAvailableOptions = updateOptions | availableOptions;
    
    OSLocationServiceUpdateOptions updatedOptions = [self.relationshipManager addOptions:wantedAvailableOptions forObject:sender];
    
    return updatedOptions;
}

#pragma mark - Stopping updates

- (OSLocationServiceUpdateOptions)stopUpdatesForOptions:(OSLocationServiceUpdateOptions)options sender:(id)sender
{
    OSLocationServiceUpdateOptions remainingOptions = [self.relationshipManager removeOptions:options forObject:sender];
    
    return remainingOptions;
}

- (void)stopUpdatesForSender:(id)sender
{
    OSLocationServiceUpdateOptions remainingOptions = [self stopUpdatesForOptions:OSLocationServiceAllOptions sender:sender];
    
    if (remainingOptions != OSLocationServiceNoUpdates) {
        NSDictionary *userInfo = @{@"object": sender, @"Options that could not be removed": @(remainingOptions)};
        NSException *exception = [NSException exceptionWithName:@"Error removing all Options for object" reason:@"Could not remove some options for the specified object" userInfo:userInfo];
        [exception raise];
    }
}

#pragma mark - Updating Managers
- (void)relationshipManagerDidChangeRelationships:(OSServiceRelationshipManager *)manager
{
    if (manager == self.relationshipManager) {
        [self reactToNewCumulativeOptions:[manager cumulativeOptions]];
    }
}

- (void)reactToNewCumulativeOptions:(OSLocationServiceUpdateOptions)options
{
    //New Managers (e.g. Core Motion) will be added here
    [self handleCoreLocationManagerForOptions:options];
}

- (void)handleCoreLocationManagerForOptions:(OSLocationServiceUpdateOptions)options
{
    BOOL wantsLocationUpdates = options & OSLocationServiceLocationUpdates;
    BOOL wantsHeadingUpdates  = options & OSLocationServiceHeadingUpdates;
    
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
        self.coreLocationManager.headingFilter = kCLHeadingFilterNone;
        [self.coreLocationManager startUpdatingHeading];
    } else {
        [self.coreLocationManager stopUpdatingHeading];
    }

}

#pragma mark - Core Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] > 1) {
        NSMutableArray *osLocations = [NSMutableArray arrayWithCapacity:[locations count]];
        for (CLLocation *location in locations) {
            OSLocation *osLocation = [[OSLocation alloc] initWithCoordinate:location.coordinate dateTaken:location.timestamp];
            [osLocations addObject:osLocation];
        }
    }
    
    CLLocation *mostRecentUpdate = [locations lastObject];
    CLLocationCoordinate2D coordinate = mostRecentUpdate.coordinate;
    OSLocation *currentLocation = [[OSLocation alloc] initWithCoordinate:coordinate dateTaken:[NSDate date]];
    _currentLocation = currentLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    _headingTrueDegrees = newHeading.trueHeading;
    _headingMagneticDegrees = newHeading.magneticHeading;
    _headingAccuracy = newHeading.headingAccuracy;
}

@end
