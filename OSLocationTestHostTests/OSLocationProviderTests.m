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

- (void)testItInitilisesItselfWithCurrentLocationPurposeIfNoneIsProvided {
    expect(self.locationProvider.updatePurpose).to.equal(OSLocationUpdatePurposeCurrentLocation);
}

- (void)testItUpdatesFiltersForCurrentLocation {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates purpose:OSLocationUpdatePurposeCurrentLocation];
    expect(locationProvider.distanceFilter).to.equal(kCLDistanceFilterNone);
    expect(locationProvider.desiredAccuracy).to.equal(kCLLocationAccuracyBest);
}

- (void)testItUpdatesFiltersForNavigation {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates purpose:OSLocationUpdatePurposeNavigation];
    expect(locationProvider.distanceFilter).to.equal(kCLDistanceFilterNone);
    expect(locationProvider.desiredAccuracy).to.equal(kCLLocationAccuracyBestForNavigation);
}

- (void)testItSetsFiltersOnlyForCustomPurpose {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates purpose:OSLocationUpdatePurposeCustom];
    [locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
    locationProvider.distanceFilter = 40;
    locationProvider.desiredAccuracy = 50;
    expect(locationProvider.coreLocationManager.distanceFilter).to.equal(40);
    expect(locationProvider.coreLocationManager.desiredAccuracy).to.equal(50);
    [locationProvider stopLocationServiceUpdates];

    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates purpose:OSLocationUpdatePurposeNavigation];
    [locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
    locationProvider.distanceFilter = 40;
    locationProvider.desiredAccuracy = 50;
    expect(locationProvider.coreLocationManager.distanceFilter).to.equal(kCLDistanceFilterNone);
    expect(locationProvider.coreLocationManager.desiredAccuracy).to.equal(kCLLocationAccuracyBestForNavigation);
    [locationProvider stopLocationServiceUpdates];
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateLocation {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates purpose:OSLocationUpdatePurposeCustom];
    expect(locationProvider.hasRequestedToUpdateLocation).to.beTruthy();
    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceHeadingUpdates purpose:OSLocationUpdatePurposeCustom];
    expect(locationProvider.hasRequestedToUpdateLocation).to.beFalsy();
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateHeading {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceHeadingUpdates purpose:OSLocationUpdatePurposeCustom];
    expect(locationProvider.hasRequestedToUpdateHeading).to.beTruthy();
    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates purpose:OSLocationUpdatePurposeCustom];
    expect(locationProvider.hasRequestedToUpdateHeading).to.beFalsy();
}

- (void)testItReportsCorrectlyIfItHasRequestedToUpdateBothLocationAndHeading {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceAllOptions purpose:OSLocationUpdatePurposeCustom];
    expect(locationProvider.hasRequestedToUpdateLocation).to.beTruthy();
    expect(locationProvider.hasRequestedToUpdateHeading).to.beTruthy();

    locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceNoUpdates purpose:OSLocationUpdatePurposeCustom];
    expect(locationProvider.hasRequestedToUpdateLocation).to.beFalsy();
    expect(locationProvider.hasRequestedToUpdateHeading).to.beFalsy();
}

- (void)testItInitilisesCoreLocationManagerWithGivenOptions {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate options:OSLocationServiceLocationUpdates purpose:OSLocationUpdatePurposeCustom];
    locationProvider.distanceFilter = 40;
    locationProvider.desiredAccuracy = 100;
    [locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
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

- (void)testItAdjustsHeadingWhenOrientationChanges {
    id mockLocationProvider = OCMPartialMock(self.locationProvider);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    OCMVerify([mockLocationProvider orientationChanged]);
    [mockLocationProvider stopMocking];
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
    locationProvider.coreLocationManager = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - Authorisation Status
- (void)testItRaisesWhenRequestingAuthorisationForInvalidStatuses {
    expect(^{
        [self.locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusNotDetermined];
    }).to.raise(NSInvalidArgumentException);
    expect(^{
        [self.locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusRestricted];
    }).to.raise(NSInvalidArgumentException);
    expect(^{
        [self.locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusDenied];
    }).to.raise(NSInvalidArgumentException);
}

- (void)testItRequestsTheCorrectAuthorisationLevelForValidStatuses {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    locationProvider.coreLocationManager = mockLocationManager;

    [[[mockLocationManager stub] andReturnValue:@(kCLAuthorizationStatusNotDetermined)] authorizationStatus];
    [[mockLocationManager expect] requestWhenInUseAuthorization];
    [locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
    [mockLocationManager verify];

    [[[mockLocationManager stub] andReturnValue:@(kCLAuthorizationStatusNotDetermined)] authorizationStatus];
    [[mockLocationManager expect] requestAlwaysAuthorization];
    [locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedAlways];
    [mockLocationManager verify];

    [mockLocationManager stopMocking];
}

- (void)testItStartsUpdatingLocationsWhenInUseLocationUpdatesAreRequestedAtAnAlreadyAuthorisedLevel {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    locationProvider.coreLocationManager = mockLocationManager;

    [[[mockLocationManager stub] andReturnValue:@(kCLAuthorizationStatusAuthorizedWhenInUse)] authorizationStatus];
    [[mockLocationManager expect] startUpdatingLocation];
    [locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
    [mockLocationManager verify];

    [[[mockLocationManager stub] andReturnValue:@(kCLAuthorizationStatusAuthorizedAlways)] authorizationStatus];
    [[mockLocationManager expect] startUpdatingLocation];
    [locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
    [mockLocationManager verify];
}

- (void)testItStartsUpdatingLocationsWhenAlwaysLocationUpdatesAreRequestedAtAnAlreadyAuthorisedLevel {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    locationProvider.coreLocationManager = mockLocationManager;

    [[[mockLocationManager stub] andReturnValue:@(kCLAuthorizationStatusAuthorizedAlways)] authorizationStatus];
    [[mockLocationManager expect] startUpdatingLocation];
    [locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedAlways];
    [mockLocationManager verify];
}

- (void)testItStartsUpdatingLocationsWhenTheUserAuthorisesInUseLocationUpdates {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    locationProvider.coreLocationManager = mockLocationManager;

    [[mockLocationManager expect] startUpdatingLocation];
    [locationProvider locationManager:locationProvider.coreLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
    [mockLocationManager verify];
}

- (void)testItStartsUpdatingLocationsWhenTheUserAuthorisesAlwaysLocationUpdates {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    locationProvider.coreLocationManager = mockLocationManager;

    [[mockLocationManager expect] startUpdatingLocation];
    [locationProvider locationManager:locationProvider.coreLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
    [mockLocationManager verify];
}

- (void)testItDoesNotStartUpdatingLocationsWhenTheUserDeniesLocationUpdateAuthorisation {
    OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self.mockDelegate];
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    locationProvider.coreLocationManager = mockLocationManager;

    [[mockLocationManager reject] startUpdatingLocation];
    [locationProvider locationManager:locationProvider.coreLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusDenied];
    [mockLocationManager verify];
}

- (void)testItDoesNotAllowBackgroundLocationUpdatesByDefault {
    expect(self.locationProvider.coreLocationManager.allowsBackgroundLocationUpdates).to.beFalsy();
}

- (void)testItAllowsBackgroundLocationUpdatesToBeEnabledAndDisabled {
    self.locationProvider.continueUpdatesInBackground = YES;
    expect(self.locationProvider.coreLocationManager.allowsBackgroundLocationUpdates).to.beTruthy();
    self.locationProvider.continueUpdatesInBackground = NO;
    expect(self.locationProvider.coreLocationManager.allowsBackgroundLocationUpdates).to.beFalsy();
}

@end
