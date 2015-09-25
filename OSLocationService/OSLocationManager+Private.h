//
//  OSLocationManager+Private.h
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

@import CoreLocation;

@interface OSLocationManager ()<CLLocationManagerDelegate>

@property (weak, nonatomic) id<OSLocationManagerDelegate> delegate;
@property (assign, nonatomic) OSLocationUpdatesFrequency updateFrequency;

@end