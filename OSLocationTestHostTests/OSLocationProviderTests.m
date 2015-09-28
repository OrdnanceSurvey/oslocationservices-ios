//
//  OSLocationProviderTests.m
//  OSLocationService
//
//  Created by Shrikantreddy Tekale on 25/09/2015.
//  Copyright © 2015 Ordnance Survey. All rights reserved.
//

@import MIQTestingFramework;
#import "OSLocationProvider.h"
#import "OSLocationProvider+Private.h"
#import "OSLocationProviderDelegate.h"

@interface OSLocationProviderTests : XCTestCase
@property (nonatomic, strong) id mockDelegate;
@property (nonatomic, strong) OSLocationProvider *locationProvider;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation OSLocationProviderTests

- (void)setUp {
    [super setUp];
    self.mockDelegate = OCMProtocolMock(@protocol(OSLocationProviderDelegate));
    self.locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    self.locationManager = [[CLLocationManager alloc] init];
}

- (void)tearDown {
    self.locationManager = nil;
    self.locationProvider = nil;
    self.mockDelegate = nil;
    [super tearDown];
}

- (void)testItInitilisesItselfWithMediumFrequencyIfNoneIsProvided {
    expect(self.locationProvider.updateFrequency).to.equal(OSLocationUpdatesFrequencyMedium);
}

- (void)testItUpdatesFiltersForLowFrequency {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyLow];
    expect(locationProvider.distanceFilter).to.equal(100);
    expect(locationProvider.desiredAccuracy).to.equal(kCLLocationAccuracyBest);
}

- (void)testItUpdatesFiltersForMediumFrequency {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyMedium];
    expect(locationProvider.distanceFilter).to.equal(40);
    expect(locationProvider.desiredAccuracy).to.equal(kCLLocationAccuracyNearestTenMeters);
}

- (void)testItUpdatesFiltersForHighFrequency {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyHigh];
    expect(locationProvider.distanceFilter).to.equal(10);
    expect(locationProvider.desiredAccuracy).to.equal(kCLLocationAccuracyHundredMeters);
}

- (void)testItSetsFiltersOnlyForCustomFrequency {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyCustom];
    [locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    locationProvider.distanceFilter = 40;
    locationProvider.desiredAccuracy = 50;
    expect(locationProvider.coreLocationManager.distanceFilter).to.equal(40);
    expect(locationProvider.coreLocationManager.desiredAccuracy).to.equal(50);
    [locationProvider stopLocationServiceUpdates];

    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate frequency:OSLocationUpdatesFrequencyLow];
    [locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    locationProvider.distanceFilter = 40;
    locationProvider.desiredAccuracy = 50;
    expect(locationProvider.coreLocationManager.distanceFilter).to.equal(100);
    expect(locationProvider.coreLocationManager.desiredAccuracy).to.equal(kCLLocationAccuracyBest);
    [locationProvider stopLocationServiceUpdates];
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateLocation {
    [self.locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    expect(self.locationProvider.hasRequestedToUpdateLocation).to.beTruthy();
    [self.locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceHeadingUpdates];
    expect(self.locationProvider.hasRequestedToUpdateLocation).to.beFalsy();
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateHeading {
    [self.locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceHeadingUpdates];
    expect(self.locationProvider.hasRequestedToUpdateHeading).to.beTruthy();
    [self.locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    expect(self.locationProvider.hasRequestedToUpdateHeading).to.beFalsy();
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateBothLocationAndHeading {
    [self.locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceAllOptions];
    expect(self.locationProvider.hasRequestedToUpdateLocation).to.beTruthy();
    expect(self.locationProvider.hasRequestedToUpdateHeading).to.beTruthy();

    [self.locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceNoUpdates];
    expect(self.locationProvider.hasRequestedToUpdateLocation).to.beFalsy();
    expect(self.locationProvider.hasRequestedToUpdateHeading).to.beFalsy();
}

- (void)testItInitilisesCoreLocationManagerWithGivenOptions {
    [self.locationProvider startLocationServiceUpdatesWithOptions:OSLocationServiceLocationUpdates];
    expect(self.locationProvider.coreLocationManager.delegate).to.equal(self.locationProvider);
    expect(self.locationProvider.coreLocationManager.pausesLocationUpdatesAutomatically).to.beFalsy();
    expect(self.locationProvider.coreLocationManager.distanceFilter).to.equal(40);
    expect(self.locationProvider.coreLocationManager.desiredAccuracy).to.equal(kCLLocationAccuracyNearestTenMeters);
    expect(self.locationProvider.coreLocationManager.activityType).to.equal(CLActivityTypeFitness);
}

- (void)testItInformsTheDelegateWhenLocationIsUpdated {
    NSArray *locations = @[ [[CLLocation alloc] initWithLatitude:10 longitude:10] ];
    [self.locationProvider locationManager:self.locationManager didUpdateLocations:locations];
    OCMVerify([self.mockDelegate locationProvider:self.locationProvider didUpdateLocations:locations]);
}

- (void)testItInformsTheDelegateWhenThereWasAnErrorInUpdatingLocation {
    NSError *error = [NSError errorWithDomain:@"Test" code:0 userInfo:@{ @"Test" : @"Test" }];
    [self.locationProvider locationManager:self.locationManager didFailWithError:error];
    OCMVerify([self.mockDelegate locationProvider:self.locationProvider didFailWithError:error]);
}

- (void)testItInformsTheDelegateWhenHeadingIsUpdated {
    CLHeading *heading = [[CLHeading alloc] init];
    [self.locationProvider locationManager:self.locationManager didUpdateHeading:heading];
    OCMVerify([self.mockDelegate locationProvider:self.locationProvider didUpdateHeading:heading]);
}

- (void)testItInformsTheDelegateWhenAuthorizationStatusIsChanged {
    CLAuthorizationStatus status = kCLAuthorizationStatusDenied;
    [self.locationProvider locationManager:self.locationManager didChangeAuthorizationStatus:status];
    OCMVerify([self.mockDelegate locationProvider:self.locationProvider didChangeAuthorizationStatus:status]);
}

@end
