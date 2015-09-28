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
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyLow];
    expect(locationProvider.distanceFilter).to.equal(100);
    expect(locationProvider.desiredAccuracy).to.equal(kCLLocationAccuracyBest);
}

- (void)testItUpdatesFiltersForMediumFrequency {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyMedium];
    expect(locationProvider.distanceFilter).to.equal(40);
    expect(locationProvider.desiredAccuracy).to.equal(kCLLocationAccuracyNearestTenMeters);
}

- (void)testItUpdatesFiltersForHighFrequency {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyHigh];
    expect(locationProvider.distanceFilter).to.equal(10);
    expect(locationProvider.desiredAccuracy).to.equal(kCLLocationAccuracyHundredMeters);
}

- (void)testItSetsFiltersOnlyForCustomFrequency {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyCustom];
    [locationProvider startLocationServiceUpdates];
    locationProvider.distanceFilter = 40;
    locationProvider.desiredAccuracy = 50;
    expect(locationProvider.coreLocationManager.distanceFilter).to.equal(40);
    expect(locationProvider.coreLocationManager.desiredAccuracy).to.equal(50);
    [locationProvider stopLocationServiceUpdates];

    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyLow];
    [locationProvider startLocationServiceUpdates];
    locationProvider.distanceFilter = 40;
    locationProvider.desiredAccuracy = 50;
    expect(locationProvider.coreLocationManager.distanceFilter).to.equal(100);
    expect(locationProvider.coreLocationManager.desiredAccuracy).to.equal(kCLLocationAccuracyBest);
    [locationProvider stopLocationServiceUpdates];
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateLocation {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyCustom];
    expect(locationProvider.hasRequestedToUpdateLocation).to.beTruthy();
    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceHeadingUpdates frequency:OSLocationUpdatesFrequencyCustom];
    expect(locationProvider.hasRequestedToUpdateLocation).to.beFalsy();
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateHeading {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceHeadingUpdates frequency:OSLocationUpdatesFrequencyCustom];
    expect(locationProvider.hasRequestedToUpdateHeading).to.beTruthy();
    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyCustom];
    expect(locationProvider.hasRequestedToUpdateHeading).to.beFalsy();
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateBothLocationAndHeading {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceAllOptions frequency:OSLocationUpdatesFrequencyCustom];
    expect(locationProvider.hasRequestedToUpdateLocation).to.beTruthy();
    expect(locationProvider.hasRequestedToUpdateHeading).to.beTruthy();

    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceNoUpdates frequency:OSLocationUpdatesFrequencyCustom];
    expect(locationProvider.hasRequestedToUpdateLocation).to.beFalsy();
    expect(locationProvider.hasRequestedToUpdateHeading).to.beFalsy();
}

- (void)testItInitilisesCoreLocationManagerWithGivenOptions {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates frequency:OSLocationUpdatesFrequencyCustom];
    locationProvider.distanceFilter = 40;
    locationProvider.desiredAccuracy = 100;
    [locationProvider startLocationServiceUpdates];
    expect(locationProvider.coreLocationManager.delegate).to.equal(locationProvider);
    expect(locationProvider.coreLocationManager.pausesLocationUpdatesAutomatically).to.beFalsy();
    expect(locationProvider.coreLocationManager.distanceFilter).to.equal(40);
    expect(locationProvider.coreLocationManager.desiredAccuracy).to.equal(100);
    expect(locationProvider.coreLocationManager.activityType).to.equal(CLActivityTypeFitness);
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

- (void)testItAdjustsHeadingForOrientationWhenAskedTo {
    self.locationProvider.adjustHeadingForDeviceOrientation = YES;
    id mockLocationProvider = OCMPartialMock(self.locationProvider);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    OCMVerify([mockLocationProvider orientationChanged]);
}

- (void)testItDoesNotAdjustsHeadingForOrientationWhenAskedNotTo {
    self.locationProvider.adjustHeadingForDeviceOrientation = NO;
    id mockLocationProvider = OCMPartialMock(self.locationProvider);
    [[mockLocationProvider reject] orientationChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)testLocationProviderStopsUpdatesInBackgroundWhenAskedTo {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    locationProvider.coreLocationManager = mockLocationManager;
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    OCMVerify([mockLocationManager stopUpdatingLocation]);
    OCMVerify([mockLocationManager stopUpdatingHeading]);
}

- (void)testLocationProviderDoesNotStopUpdatesInBackgroundWhenAskedNotTo {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    locationProvider.continueUpdatesInBackground = YES;
    locationProvider.coreLocationManager = mockLocationManager;
    [[mockLocationManager reject] stopUpdatingLocation];
    [[mockLocationManager reject] stopUpdatingHeading];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
}

@end
