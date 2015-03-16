//
//  OSLocationServiceTests.m
//  OSLocationServiceTests
//
//  Created by Layla Gordon on 10/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

@import MIQTestingFramework;
#import "OSLocationService.h"
#import "OSLocationService+Private.h"
#import "OSCoreLocationManager.h"
#import "OSServiceRelationshipManager.h"
#import "OSLocationServiceObserverProtocol.h"

@import CoreLocation;

extern NSString *const OSLocationServicesDisabledAlertHasBeenShown;

@interface OSLocationService ()

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

@end

@interface OSLocationServiceTests : XCTestCase

@end

@implementation OSLocationServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (id)mockCoreLocationManagerAllowLocation:(BOOL)allowLocation allowHeading:(BOOL)allowHeading {
    id mockCoreLocationManager = [OCMockObject niceMockForClass:[OSCoreLocationManager class]];
    [[[[mockCoreLocationManager stub] classMethod] andReturnValue:OCMOCK_VALUE(allowLocation)] locationUpdatesAvailable];
    [[[[mockCoreLocationManager stub] classMethod] andReturnValue:OCMOCK_VALUE(allowHeading)] headingUpdatesAvailable];

    return mockCoreLocationManager;
}

- (void)testThatLocationServiceIsInitilisedWithDefaultValues {
    OSLocationService *locationService = [[OSLocationService alloc] init];
    expect(locationService.permissionLevel).to.equal(OSLocationServicePermissionWhenInUse);
    expect(locationService.activityType).to.equal(CLActivityTypeOther);
    expect(locationService.distanceFilter).to.equal(kOSDistanceFilterNone);
    expect(locationService.desiredAccuracy).to.equal(kOSLocationAccuracyBest);
    expect(locationService.pausesLocationUpdatesAutomatically).to.equal(YES);
}

- (void)testThatLocationServiceAsksForCorrectDefaultPermissionWhenActivated {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    [OCMStub([mockLocationManager authorizationStatus]) andReturnValue:@(kCLAuthorizationStatusNotDetermined)];

    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.coreLocationManager = mockLocationManager;

    NSString *dummyIdentifier = @"Dummy";
    [locationService startUpdatingWithOptions:OSLocationServiceAllOptions sender:dummyIdentifier];
    OCMVerify([mockLocationManager requestWhenInUseAuthorization]);
}

- (void)testThatLocationServiceAsksForCorrectPermissionWhenActivatedWithAlwaysPermission {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    [OCMStub([mockLocationManager authorizationStatus]) andReturnValue:@(kCLAuthorizationStatusNotDetermined)];

    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.coreLocationManager = mockLocationManager;

    NSString *dummyIdentifier = @"Dummy";
    [locationService startUpdatingWithOptions:OSLocationServiceAllOptions permissionLevel:OSLocationServicePermissionAlways sender:dummyIdentifier];
    OCMVerify([mockLocationManager requestAlwaysAuthorization]);
}

- (void)testThatLocationServiceAsksForCorrectPermissionWhenActivatedWithWhenInUsePermission {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    [OCMStub([mockLocationManager authorizationStatus]) andReturnValue:@(kCLAuthorizationStatusNotDetermined)];

    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.coreLocationManager = mockLocationManager;

    NSString *dummyIdentifier = @"Dummy";
    [locationService startUpdatingWithOptions:OSLocationServiceAllOptions permissionLevel:OSLocationServicePermissionWhenInUse sender:dummyIdentifier];
    OCMVerify([mockLocationManager requestWhenInUseAuthorization]);
}

- (void)testThatLocationServiceStartsUpdatingLocationWhenPermissionIsGranted {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    [OCMStub([mockLocationManager authorizationStatus]) andReturnValue:@(kCLAuthorizationStatusNotDetermined)];

    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.coreLocationManager = mockLocationManager;

    NSString *dummyIdentifier = @"Dummy";
    [locationService startUpdatingWithOptions:OSLocationServiceAllOptions sender:dummyIdentifier];
    [locationService locationManager:mockLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
    OCMVerify([mockLocationManager startUpdatingLocation]);
}

- (void)testThatLocationServiceStopsUpdatingLocationWhenPermissionIsDenied {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    OCMStub([mockLocationManager alloc]).andReturn(mockLocationManager);

    OSLocationService *locationService = [[OSLocationService alloc] init];
    NSString *dummyIdentifier = @"Dummy";
    [locationService startUpdatingWithOptions:OSLocationServiceAllOptions sender:dummyIdentifier];
    [locationService locationManager:mockLocationManager didChangeAuthorizationStatus:kCLAuthorizationStatusDenied];
    OCMVerify([mockLocationManager stopUpdatingLocation]);
}

- (void)testThatLocationUpdateNotifiesDelegate {
    id mockDelegate = OCMProtocolMock(@protocol(OSLocationServiceDelegate));

    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.delegate = mockDelegate;

    CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:50 longitude:-1];

    OSLocation *expectedLocation = [[OSLocation alloc] initWithCoordinate:testLocation.coordinate
                                                                dateTaken:[NSDate date]
                                                       horizontalAccuracy:testLocation.horizontalAccuracy];

    // Doing this the old fashioned way of expectation set up in advance followed by verification as there
    // appears to be a bug on 64bit checking an array value passed in as an expected parameter.
    [[mockDelegate expect] locationService:locationService didUpdateLocations:@[ expectedLocation ]];

    [locationService locationManager:nil didUpdateLocations:@[ testLocation ]];

    [mockDelegate verify];
}

- (void)testThatHeadingUpdateNotifiesDelegate {
    id mockDelegate = OCMProtocolMock(@protocol(OSLocationServiceDelegate));
    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.delegate = mockDelegate;

    id testHeading = OCMClassMock([CLHeading class]);
    OCMStub([testHeading trueHeading]).andReturn(90);
    [locationService locationManager:nil didUpdateHeading:testHeading];

    OCMVerify([mockDelegate locationService:locationService didUpdateHeading:90]);
}

- (void)testThatItNotifiesDelegateWhenDeferringUpdatesHasStopped {
    id mockDelegate = OCMProtocolMock(@protocol(OSLocationServiceDelegate));
    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.delegate = mockDelegate;
    [locationService locationManager:nil didFinishDeferredUpdatesWithError:nil];
    OCMVerify([mockDelegate locationService:locationService didFinishDeferredUpdatesWithError:nil]);
}

- (void)testThatDeferringLocationUpdatesTheParametersCorrectly {
    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.distanceFilter = 10;
    locationService.desiredAccuracy = kCLLocationAccuracyKilometer;
    NSString *dummyIdentifier = @"Dummy";
    [locationService startUpdatingWithOptions:OSLocationServiceLocationUpdates sender:dummyIdentifier];
    [locationService allowDeferredLocationUpdatesUntilTraveled:10 timeout:10];
    expect(locationService.coreLocationManager.distanceFilter).to.equal(kCLDistanceFilterNone);
    expect(locationService.coreLocationManager.desiredAccuracy).to.equal(kCLLocationAccuracyBest);
}

- (void)testThatDisallowingDeferringLocationUpdatesLocationServiceCorrectly {
    id mockLocationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.coreLocationManager = mockLocationManager;
    [locationService disallowDeferredLocationUpdates];
    OCMVerify([mockLocationManager disallowDeferredLocationUpdates]);
}

- (void)testAddingLocationOptionTurnsOnCoreLocation {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);

    id mockManager = OCMClassMock([CLLocationManager class]);
    [OCMStub([mockManager authorizationStatus]) andReturnValue:@(kCLAuthorizationStatusAuthorizedWhenInUse)];

    OSLocationService *service = [[OSLocationService alloc] init];
    service.coreLocationManager = mockLocationManager;
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceLocationUpdates sender:dummyIdentifier];

    OCMVerify([mockLocationManager startUpdatingLocation]);
}

- (void)testAddingHeadingOptionTurnsOnCoreLocationHeading {
    id mockLocationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];

    [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];

    OSLocationService *service = [[OSLocationService alloc] init];
    service.coreLocationManager = mockLocationManager;
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:dummyIdentifier];

    OCMVerify([mockLocationManager startUpdatingHeading]);
}

- (void)testStopUpdateForObjectRemovesAllOptions {
    OSLocationService *service = [[OSLocationService alloc] init];
    id mockValidObject = [OCMockObject mockForProtocol:@protocol(OSLocationServiceObserverProtocol)];
    [[[mockValidObject stub] andReturn:@"DummyID"] locationServiceIdentifier];
    [service startUpdatingWithOptions:OSLocationServiceHeadingUpdates | OSLocationServiceLocationUpdates sender:mockValidObject];

    [service stopUpdatesForSender:mockValidObject];

    OSLocationServiceUpdateOptions expectedOptions = OSLocationServiceNoUpdates;
    OSLocationServiceUpdateOptions actualOptions = [service optionsForSender:mockValidObject];
    XCTAssertEqual(expectedOptions, actualOptions, @"All Options were not removed properly");
}

- (void)testStopUpdatesForCertainOptionsOnlyTurnsOffThoseOptions {
    [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];

    OSLocationService *service = [[OSLocationService alloc] init];
    id mockValidObject = [OCMockObject mockForProtocol:@protocol(OSLocationServiceObserverProtocol)];
    [[[mockValidObject stub] andReturn:@"DummyID"] locationServiceIdentifier];

    OSLocationServiceUpdateOptions startingOptions = OSLocationServiceHeadingUpdates | OSLocationServiceLocationUpdates;
    [service startUpdatingWithOptions:startingOptions sender:mockValidObject];

    OSLocationServiceUpdateOptions optionsToRemove = OSLocationServiceLocationUpdates;
    [service stopUpdatesForOptions:optionsToRemove sender:mockValidObject];

    OSLocationServiceUpdateOptions expectedReaminingOptions = OSLocationServiceHeadingUpdates;
    OSLocationServiceUpdateOptions actualRemainingOptions = [service optionsForSender:mockValidObject];

    XCTAssertEqual(expectedReaminingOptions, actualRemainingOptions, @"Selected Options were not removed properly");
}

- (void)testPassingIncompatibleSenderToStartThrowsException {
    NSObject *nonCopyingObject = [[NSObject alloc] init];

    OSLocationService *service = [[OSLocationService alloc] init];
    XCTAssertThrows([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:nonCopyingObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingNilSenderToStartThrowsException {
    NSObject *nonCopyingObject = nil;

    OSLocationService *service = [[OSLocationService alloc] init];
    XCTAssertThrows([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:nonCopyingObject], @"Nil object doesn't throw exception");
}

- (void)testPassingCompatibleSenderToStartThatImplementsNSCopyingDoesntThrowException {
    NSString *validObject = @"Valid"; //NSString conforms to NSCopying

    OSLocationService *service = [[OSLocationService alloc] init];
    XCTAssertNoThrow([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:validObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingCompatibleSenderToStartThatImplementsLocationServiceProtocolDoesntThrowException {
    id mockValidObject = [OCMockObject mockForProtocol:@protocol(OSLocationServiceObserverProtocol)];
    [[[mockValidObject stub] andReturn:@"DummyID"] locationServiceIdentifier];

    OSLocationService *service = [[OSLocationService alloc] init];
    XCTAssertNoThrow([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:mockValidObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingIncompatibleSenderToOptionsForSenderReturnsNoOptions {
    OSLocationService *service = [[OSLocationService alloc] init];

    OSLocationServiceUpdateOptions expectedOptions = OSLocationServiceNoUpdates;
    OSLocationServiceUpdateOptions actualOptions = [service optionsForSender:service];
    XCTAssertEqual(expectedOptions, actualOptions, @"Passing invalid object returns some options");
}

- (void)testPassingZeroHeadingFilterUsesCLHeadingFilterNone {
    id mockLocationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[[mockLocationManager stub] andReturn:mockLocationManager] alloc];

    OSLocationService *service = [[OSLocationService alloc] init];
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:dummyIdentifier];
    service.headingFilter = 0;

    OCMVerify([((CLLocationManager *)mockLocationManager)setHeadingFilter:kCLHeadingFilterNone]);
    XCTAssertEqual(service.headingFilter, 0, @"Did not set property");
}

- (void)testPassingHeadingFilterMoreThanZeroSetsHeadingFilter {
    id mockLocationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[[mockLocationManager stub] andReturn:mockLocationManager] alloc];

    OSLocationService *service = [[OSLocationService alloc] init];
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:dummyIdentifier];
    service.headingFilter = 5;

    OCMVerify([((CLLocationManager *)mockLocationManager)setHeadingFilter:5.0f]);
    XCTAssertEqual(service.headingFilter, 5.0f, @"Did not set property");
}

Test(IfTheCalibrationDelegateIsNotSetThenTheCalibrationScreenWillNotBeUsed) {
    OSLocationService *service = [[OSLocationService alloc] init];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beFalsy();
}

- (id<OSLocationServiceCalibrationDelegate>)calibrationDelegateForImportance:(OSLocationServiceCalibrationImportance)importance {
    id<OSLocationServiceCalibrationDelegate> mockDelegate = OCMProtocolMock(@protocol(OSLocationServiceCalibrationDelegate));
    OCMStub([mockDelegate calibrationImportance]).andReturn(importance);
    return mockDelegate;
}

Test(TheServiceCalibrationDelegateCanAffectWhetherToDisplayTheCalibrationScreen) {
    OSLocationService *service = [[OSLocationService alloc] init];
    service.calibrationDelegate = [self calibrationDelegateForImportance:OSLocationServiceCalibrationImportanceNone];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beFalsy();

    service.calibrationDelegate = [self calibrationDelegateForImportance:OSLocationServiceCalibrationImportanceLow];
    [service setValue:@(-1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beTruthy();

    [service setValue:@(OSLocationServiceCalibrationImportanceLow - 1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beFalsy();

    [service setValue:@(OSLocationServiceCalibrationImportanceLow + 1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beTruthy();

    service.calibrationDelegate = [self calibrationDelegateForImportance:OSLocationServiceCalibrationImportanceMedium];
    [service setValue:@(-1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beTruthy();

    [service setValue:@(OSLocationServiceCalibrationImportanceMedium - 1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beFalsy();

    [service setValue:@(OSLocationServiceCalibrationImportanceMedium + 1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beTruthy();

    service.calibrationDelegate = [self calibrationDelegateForImportance:OSLocationServiceCalibrationImportanceHigh];
    [service setValue:@(-1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beTruthy();

    [service setValue:@(OSLocationServiceCalibrationImportanceHigh - 1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beFalsy();

    [service setValue:@(OSLocationServiceCalibrationImportanceHigh + 1) forKey:@"headingAccuracy"];
    expect([service locationManagerShouldDisplayHeadingCalibration:nil]).to.beTruthy();
}

- (void)testThatStartingLocationServicesForTheFirstTimeWithLocationDisabledShowsAlert {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:OSLocationServicesDisabledAlertHasBeenShown];
    [[NSUserDefaults standardUserDefaults] synchronize];

    OSLocationService *service = [[OSLocationService alloc] init];
    id mockLocationService = OCMPartialMock(service);

    id mockLocationManager = OCMClassMock([OSLocationService class]);
    OCMStub([mockLocationManager locationServicesEnabled]).andReturn(NO);
    expect([OSLocationService locationServicesEnabled]).to.beFalsy();

    NSString *dummyIdentifier = @"Dummy";
    OSLocationServiceUpdateOptions options = OSLocationServiceAllOptions;
    [mockLocationService startUpdatingWithFirstDisabledWarningAndOptions:options sender:dummyIdentifier];

    OCMVerify([mockLocationService displayLocationServicesDisabledAlert]);
}

- (void)testNoAlertIsDisplayedWhenLocationServicesAreDisabledOnSubsequentStarts {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:OSLocationServicesDisabledAlertHasBeenShown];
    [[NSUserDefaults standardUserDefaults] synchronize];

    id mockLocationManager = OCMClassMock([OSLocationService class]);
    OCMStub([mockLocationManager locationServicesEnabled]).andReturn(NO);

    expect([OSLocationService locationServicesEnabled]).to.beFalsy();

    OSLocationService *service = [[OSLocationService alloc] init];

    id mockLocationService = OCMPartialMock(service);
    NSString *dummyIdentifier = @"Dummy";
    OSLocationServiceUpdateOptions options = OSLocationServiceAllOptions;
    [mockLocationService startUpdatingWithFirstDisabledWarningAndOptions:options sender:dummyIdentifier];
    [[mockLocationService reject] displayLocationServicesDisabledAlert];
    [mockLocationService verify];
}

- (void)testLocationServicesStopsUpdatesInBackground {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.coreLocationManager = mockLocationManager;
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    OCMVerify([mockLocationManager stopUpdatingLocation]);
    OCMVerify([mockLocationManager stopUpdatingHeading]);
}

- (void)testLocationServicesDoesNotStopUpdatesInBackgroundWhenTrackingUserLocation {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.continueUpdatesInBackground = YES;
    locationService.coreLocationManager = mockLocationManager;
    [[mockLocationManager reject] stopUpdatingLocation];
    [[mockLocationManager reject] stopUpdatingHeading];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)testLocationServicesStartsUpdatesWhenInForeGround {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    OSLocationService *locationService = [[OSLocationService alloc] init];
    locationService.coreLocationManager = mockLocationManager;
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    OCMVerify([mockLocationManager startUpdatingLocation]);
    OCMVerify([mockLocationManager startUpdatingHeading]);
}

@end
