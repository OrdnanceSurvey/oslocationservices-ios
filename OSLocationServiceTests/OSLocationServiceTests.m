//
//  OSLocationServiceTests.m
//  OSLocationServiceTests
//
//  Created by Layla Gordon on 10/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

@import MIQTestingFramework;
#import "OSLocationService.h"
#import "OSCoreLocationManager.h"
#import "OSLocationServiceObserverProtocol.h"
#import "OSServiceRelationshipManager.h"

@import CoreLocation;

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

- (void)testAddingLocationOptionTurnsOnCoreLocation {
    id mockLocationManager = OCMClassMock([CLLocationManager class]);
    OCMStub([mockLocationManager alloc]).andReturn(mockLocationManager);

    OSLocationService *service = [[OSLocationService alloc] init];
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceLocationUpdates sender:dummyIdentifier];

    OCMVerify([mockLocationManager startUpdatingLocation]);
}

- (void)testAddingHeadingOptionTurnsOnCoreLocationHeading {
    id mockLocationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[[mockLocationManager stub] andReturn:mockLocationManager] alloc];

    [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];

    OSLocationService *service = [OSLocationService defaultService];
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:dummyIdentifier];

    OCMVerify([mockLocationManager startUpdatingHeading]);
}

- (void)testStopUpdateForObjectRemovesAllOptions {
    OSLocationService *service = [OSLocationService defaultService];
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceHeadingUpdates | OSLocationServiceLocationUpdates sender:dummyIdentifier];

    [service stopUpdatesForSender:dummyIdentifier];

    OSLocationServiceUpdateOptions expectedOptions = OSLocationServiceNoUpdates;
    OSLocationServiceUpdateOptions actualOptions = [service optionsForSender:dummyIdentifier];
    XCTAssertEqual(expectedOptions, actualOptions, @"All Options were not removed properly");
}

- (void)testStopUpdatesForCertainOptionsOnlyTurnsOffThoseOptions {
    [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];

    OSLocationService *service = [OSLocationService defaultService];
    NSString *dummyIdentifier = @"Dummy";
    OSLocationServiceUpdateOptions startingOptions = OSLocationServiceHeadingUpdates | OSLocationServiceLocationUpdates;
    [service startUpdatingWithOptions:startingOptions sender:dummyIdentifier];

    OSLocationServiceUpdateOptions optionsToRemove = OSLocationServiceLocationUpdates;
    [service stopUpdatesForOptions:optionsToRemove sender:dummyIdentifier];

    OSLocationServiceUpdateOptions expectedReaminingOptions = OSLocationServiceHeadingUpdates;
    OSLocationServiceUpdateOptions actualRemainingOptions = [service optionsForSender:dummyIdentifier];

    XCTAssertEqual(expectedReaminingOptions, actualRemainingOptions, @"Selected Options were not removed properly");
}

- (void)testPassingIncompatibleSenderToStartThrowsException {
    NSObject *nonCopyingObject = [[NSObject alloc] init];

    OSLocationService *service = [OSLocationService defaultService];
    XCTAssertThrows([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:nonCopyingObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingNilSenderToStartThrowsException {
    NSObject *nonCopyingObject = nil;

    OSLocationService *service = [OSLocationService defaultService];
    XCTAssertThrows([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:nonCopyingObject], @"Nil object doesn't throw exception");
}

- (void)testPassingCompatibleSenderToStartThatImplementsNSCopyingDoesntThrowException {
    NSString *validObject = @"Valid"; //NSString conforms to NSCopying

    OSLocationService *service = [OSLocationService defaultService];
    XCTAssertNoThrow([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:validObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingCompatibleSenderToStartThatImplementsLocationServiceProtocolDoesntThrowException {
    id mockValidObject = [OCMockObject mockForProtocol:@protocol(OSLocationServiceObserverProtocol)];
    [[[mockValidObject stub] andReturn:@"DummyID"] locationServiceIdentifier];

    OSLocationService *service = [OSLocationService defaultService];
    XCTAssertNoThrow([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:mockValidObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingIncompatibleSenderToOptionsForSenderReturnsNoOptions {
    OSLocationService *service = [OSLocationService defaultService];

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

@end