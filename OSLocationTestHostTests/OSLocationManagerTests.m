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

- (void)testItInitilisesItselfWithMediumFrequencyIfNoneIsProvided {
    expect(self.locationManager.updateFrequency).to.equal(OSLocationUpdatesFrequencyMedium);
}

- (void)testItUpdatesFiltersForLowFrequency {
    OSLocationManager *locationManager = [[OSLocationManager alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyLow];
    expect(locationManager.distanceFilter).to.equal(100);
    expect(locationManager.desiredAccuracy).to.equal(10);
}

- (void)testItUpdatesFiltersForMediumFrequency {
    OSLocationManager *locationManager = [[OSLocationManager alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyMedium];
    expect(locationManager.distanceFilter).to.equal(40);
    expect(locationManager.desiredAccuracy).to.equal(25);
}

- (void)testItUpdatesFiltersForHighFrequency {
    OSLocationManager *locationManager = [[OSLocationManager alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyHigh];
    expect(locationManager.distanceFilter).to.equal(10);
    expect(locationManager.desiredAccuracy).to.equal(40);
}

- (void)testItSetsFiltersOnlyForCustomFrequency {
    OSLocationManager *locationManager = [[OSLocationManager alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyCustom];
    [locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    locationManager.distanceFilter = 40;
    locationManager.desiredAccuracy = 50;
    expect(locationManager.coreLocationManager.distanceFilter).to.equal(40);
    expect(locationManager.coreLocationManager.desiredAccuracy).to.equal(50);
    [locationManager stopLocationserviceUpdates];

    locationManager = [[OSLocationManager alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyLow];
    [locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    locationManager.distanceFilter = 40;
    locationManager.desiredAccuracy = 50;
    expect(locationManager.coreLocationManager.distanceFilter).to.equal(100);
    expect(locationManager.coreLocationManager.desiredAccuracy).to.equal(10);
    [locationManager stopLocationserviceUpdates];
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateLocation {
    [self.locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    expect(self.locationManager.hasRequestedToUpdateLocation).to.beTruthy();
    [self.locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceHeadingUpdates];
    expect(self.locationManager.hasRequestedToUpdateLocation).to.beFalsy();
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateHeading {
    [self.locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceHeadingUpdates];
    expect(self.locationManager.hasRequestedToUpdateHeading).to.beTruthy();
    [self.locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    expect(self.locationManager.hasRequestedToUpdateHeading).to.beFalsy();
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateBothLocationAndHeading {
    [self.locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceAllOptions];
    expect(self.locationManager.hasRequestedToUpdateLocation).to.beTruthy();
    expect(self.locationManager.hasRequestedToUpdateHeading).to.beTruthy();

    [self.locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceNoUpdates];
    expect(self.locationManager.hasRequestedToUpdateLocation).to.beFalsy();
    expect(self.locationManager.hasRequestedToUpdateHeading).to.beFalsy();
}

- (void)testItInitilisesCoreLocationManagerWithGivenOptions {
    [self.locationManager startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    expect(self.locationManager.coreLocationManager.delegate).to.equal(self.locationManager);
    expect(self.locationManager.coreLocationManager.pausesLocationUpdatesAutomatically).to.beFalsy();
    expect(self.locationManager.coreLocationManager.distanceFilter).to.equal(40);
    expect(self.locationManager.coreLocationManager.desiredAccuracy).to.equal(25);
    expect(self.locationManager.coreLocationManager.activityType).to.equal(CLActivityTypeFitness);
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
