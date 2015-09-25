//
//  OSLocationManagerTests.m
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

@import MIQTestingFramework;
#import "OSLocationManager.h"
#import "OSLocationManager+Private.h"
#import "OSLocationManagerDelegate.h"

@interface OSLocationManagerTests : XCTestCase
@property (nonatomic, strong) id mockDelegate;
@property (nonatomic, strong) OSLocationManager *locationManager;
@property (nonatomic, strong) CLLocationManager *clLocationManager;
@end

@implementation OSLocationManagerTests

- (void)setUp {
    [super setUp];
    self.mockDelegate = OCMProtocolMock(@protocol(OSLocationManagerDelegate));
    self.locationManager = [[OSLocationManager alloc] initWithDelegate:self.mockDelegate];
    self.clLocationManager = [[CLLocationManager alloc] init];
}

- (void)tearDown {
    self.clLocationManager = nil;
    self.locationManager = nil;
    self.mockDelegate = nil;
    [super tearDown];
}

- (void)testItInformsTheDelegateWhenLocationIsUpdated {
    NSArray *locations = @[ [[CLLocation alloc] initWithLatitude:10 longitude:10] ];
    [self.locationManager locationManager:self.clLocationManager didUpdateLocations:locations];
    OCMVerify([self.mockDelegate osLocationManager:self.locationManager didUpdateLocations:locations]);
}

- (void)testItInformsTheDelegateWhenThereWasAnErrorInUpdatingLocation {
    NSError *error = [NSError errorWithDomain:@"Test" code:0 userInfo:@{ @"Test" : @"Test" }];
    [self.locationManager locationManager:self.clLocationManager didFailWithError:error];
    OCMVerify([self.mockDelegate osLocationManager:self.locationManager didFailWithError:error]);
}

- (void)testItInformsTheDelegateWhenHeadingIsUpdated {
    CLHeading *heading = [[CLHeading alloc] init];
    [self.locationManager locationManager:self.clLocationManager didUpdateHeading:heading];
    OCMVerify([self.mockDelegate osLocationManager:self.locationManager didUpdateHeading:heading]);
}

- (void)testItInformsTheDelegateWhenAuthorizationStatusIsChanged {
    CLAuthorizationStatus status = kCLAuthorizationStatusDenied;
    [self.locationManager locationManager:self.clLocationManager didChangeAuthorizationStatus:status];
    OCMVerify([self.mockDelegate osLocationManager:self.locationManager didChangeAuthorizationStatus:status]);
}

@end
