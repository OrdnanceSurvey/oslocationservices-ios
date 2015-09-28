//
//  OSLocationProvider+Private.h
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

@import CoreLocation;

@interface OSLocationProvider ()<CLLocationManagerDelegate>

@property (weak, nonatomic) id<OSLocationProviderDelegate> delegate;
@property (assign, nonatomic) OSLocationUpdatesFrequency updateFrequency;
@property (assign, nonatomic) OSLocationServiceUpdateOptions updateOptions;
@property (strong, nonatomic) CLLocationManager *coreLocationManager;

- (BOOL)hasRequestedToUpdateLocation;
- (BOOL)hasRequestedToUpdateHeading;
- (void)orientationChanged;

@end