//
//  ViewController.m
//  OSLocationTestHost
//
//  Created by David Haynes (C) on 15/12/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "ViewController.h"
#import "OSLocationProvider.h"

@interface ViewController ()<OSLocationProviderDelegate>
@property (nonatomic, strong) OSLocationProvider *locationProvider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationProvider = [[OSLocationProvider alloc] initWithDelegate:self];
    [self.locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - OSLocationProviderDelegate
- (void)locationProvider:(OSLocationProvider *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"location: %@", locations.firstObject);
}

- (void)locationProvider:(OSLocationProvider *)manager didUpdateHeading:(CLHeading *)newHeading {
    NSLog(@"heading: %@", newHeading);
}

- (void)locationProvider:(OSLocationProvider *)manager didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

@end
