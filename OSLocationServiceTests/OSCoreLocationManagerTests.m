//
//  OSCoreLocationManagerTests.m
//  OSLocationService
//
//  Created by Jake Skeates on 03/07/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <XCTest/XCTest.h>
@import MIQTestingFramework;
#import "OSCoreLocationManager.h"

@import CoreLocation;

@interface OSCoreLocationManagerTests : XCTestCase

@end

@implementation OSCoreLocationManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLocationUpdatesAvailableWhenAuthoirzationStatusIsNotDetermined
{
    id partialMock = [OCMockObject niceMockForClass:[OSCoreLocationManager class]];
    [[[[partialMock stub] classMethod] andReturnValue:OCMOCK_VALUE(OSLocationServiceAuthorizationNotDetermined)] authorizationStatus];
    
    XCTAssert([OSCoreLocationManager locationUpdatesAvailable], @"Location updates should be available");
}

- (void)testLocationUpdatesNotAvailableWhenAuthoirzationStatusIsRestricted
{
    id partialMock = [OCMockObject niceMockForClass:[OSCoreLocationManager class]];
    [[[[partialMock stub] classMethod] andReturnValue:OCMOCK_VALUE(OSLocationServiceAuthorizationRestricted)] authorizationStatus];
    
    XCTAssertFalse([OSCoreLocationManager locationUpdatesAvailable], @"Location updates should not be available");
}

- (void)testLocationUpdatesNotAvailableWhenAuthoirzationStatusIsDenied
{
    id partialMock = [OCMockObject niceMockForClass:[OSCoreLocationManager class]];
    [[[[partialMock stub] classMethod] andReturnValue:OCMOCK_VALUE(OSLocationServiceAuthorizationDenied)] authorizationStatus];
    
    XCTAssertFalse([OSCoreLocationManager locationUpdatesAvailable], @"Location updates should not be available");
}

- (void)testLocationUpdatesAvailableWhenAuthoirzationStatusIsAllowedAlways
{
    id partialMock = [OCMockObject niceMockForClass:[OSCoreLocationManager class]];
    [[[[partialMock stub] classMethod] andReturnValue:OCMOCK_VALUE(OSLocationServiceAuthorizationAllowedAlways)] authorizationStatus];
    
    XCTAssert([OSCoreLocationManager locationUpdatesAvailable], @"Location updates should be available");
}

- (void)testLocationUpdatesAvailableWhenAuthoirzationStatusIsAllowedWhenInUse
{
    id partialMock = [OCMockObject niceMockForClass:[OSCoreLocationManager class]];
    [[[[partialMock stub] classMethod] andReturnValue:OCMOCK_VALUE(OSLocationServiceAuthorizationAllowedWhenInUse)] authorizationStatus];
    
    XCTAssert([OSCoreLocationManager locationUpdatesAvailable], @"Location updates should be available");
}

- (void)testOSAuthorizationServiceStatusIsNotDeterminedForCLAuthorizationStatusNotDetermined
{
    CLAuthorizationStatus passedAuthStatus = kCLAuthorizationStatusNotDetermined;
    OSLocationServiceAuthorizationStatus expected = OSLocationServiceAuthorizationNotDetermined;
    OSLocationServiceAuthorizationStatus actual = [OSCoreLocationManager OSAuthorizationStatusFromCLAuthorizationStatus:passedAuthStatus];
    XCTAssertEqual(expected, actual, @"Conversion not correct");
}

- (void)testOSAuthorizationServiceStatusIsRestrictedForCLAuthorizationStatusRestricted
{
    CLAuthorizationStatus passedAuthStatus = kCLAuthorizationStatusRestricted;
    OSLocationServiceAuthorizationStatus expected = OSLocationServiceAuthorizationRestricted;
    OSLocationServiceAuthorizationStatus actual = [OSCoreLocationManager OSAuthorizationStatusFromCLAuthorizationStatus:passedAuthStatus];
    XCTAssertEqual(expected, actual, @"Conversion not correct");
}

- (void)testOSAuthorizationServiceStatusIsDeniedForCLAuthorizationStatusDenied
{
    CLAuthorizationStatus passedAuthStatus = kCLAuthorizationStatusDenied;
    OSLocationServiceAuthorizationStatus expected = OSLocationServiceAuthorizationDenied;
    OSLocationServiceAuthorizationStatus actual = [OSCoreLocationManager OSAuthorizationStatusFromCLAuthorizationStatus:passedAuthStatus];
    XCTAssertEqual(expected, actual, @"Conversion not correct");
}

- (void)testOSAuthorizationServiceStatusIsAllowedAlwaysForCLAuthorizationStatusAuthorized
{
    CLAuthorizationStatus passedAuthStatus = kCLAuthorizationStatusAuthorized;
    OSLocationServiceAuthorizationStatus expected = OSLocationServiceAuthorizationAllowedAlways;
    OSLocationServiceAuthorizationStatus actual = [OSCoreLocationManager OSAuthorizationStatusFromCLAuthorizationStatus:passedAuthStatus];
    XCTAssertEqual(expected, actual, @"Conversion not correct");
}

- (void)testOSAuthorizationServiceStatusIsUnknownForStrangeValueAsCLAuthorizationStatus
{
    NSInteger passedAuthStatus = 7254;
    OSLocationServiceAuthorizationStatus expected = OSLocationServiceAuthorizationUnknown;
    OSLocationServiceAuthorizationStatus actual = [OSCoreLocationManager OSAuthorizationStatusFromCLAuthorizationStatus:passedAuthStatus];
    XCTAssertEqual(expected, actual, @"Conversion not correct");
}

@end
