//
//  OSCoreLocationManager.m
//  OSLocationService
//
//  Created by Jake Skeates on 03/07/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSCoreLocationManager.h"
@import CoreLocation;

@implementation OSCoreLocationManager

+ (OSLocationServiceAuthorizationStatus)OSAuthorizationStatus {
    return [OSCoreLocationManager OSAuthorizationStatusFromCLAuthorizationStatus:[CLLocationManager authorizationStatus]];
}

+ (BOOL)locationUpdatesAvailable {
    OSLocationServiceAuthorizationStatus authStatus = [OSCoreLocationManager OSAuthorizationStatus];
    switch (authStatus) {
        case OSLocationServiceAuthorizationNotDetermined:
            return YES;
            break;

        case OSLocationServiceAuthorizationAllowedAlways:
            return YES;
            break;

        case OSLocationServiceAuthorizationAllowedWhenInUse:
            return YES;
            break;

        default:
            return NO;
            break;
    }
}

+ (BOOL)headingUpdatesAvailable {
    return [CLLocationManager headingAvailable];
}

+ (OSLocationServiceAuthorizationStatus)OSAuthorizationStatusFromCLAuthorizationStatus:(CLAuthorizationStatus)clAuthorizationStatus {
    switch (clAuthorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            return OSLocationServiceAuthorizationNotDetermined;
            break;

        case kCLAuthorizationStatusRestricted:
            return OSLocationServiceAuthorizationRestricted;
            break;

        case kCLAuthorizationStatusDenied:
            return OSLocationServiceAuthorizationDenied;
            break;

        case kCLAuthorizationStatusAuthorizedAlways:
            return OSLocationServiceAuthorizationAllowedAlways;
            break;

        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return OSLocationServiceAuthorizationAllowedWhenInUse;

        default:
            break;
    }

    return OSLocationServiceAuthorizationUnknown;
}

@end
