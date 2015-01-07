//
//  OSLocationService+Private.h
//  OSLocationService
//
//  Created by David Haynes (C) on 17/12/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSLocationService.h"
#import "OSServiceRelationshipManager.h"

@interface OSLocationService () <OSServiceRelationshipManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) OSServiceRelationshipManager *relationshipManager;
@property (strong, nonatomic) CLLocationManager *coreLocationManager;

//Property redefinitions to make readwrite
@property (strong, nonatomic, readwrite) OSLocation *currentLocation;
@property (strong, nonatomic, readwrite) NSArray *cachedLocations;
@property (assign, nonatomic, readwrite) OSLocationDirection headingMagneticDegrees;
@property (assign, nonatomic, readwrite) OSLocationDirection headingTrueDegrees;
@property (assign, nonatomic, readwrite) double headingAccuracy;

//iOS 8 location permission level - defaults to "When in use"
@property (assign, nonatomic) OSLocationServicePermission permissionLevel;

- (void)displayLocationServicesDisabledAlert;

@end
