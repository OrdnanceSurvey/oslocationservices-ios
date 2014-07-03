//
//  OSLocationServiceTests.m
//  OSLocationServiceTests
//
//  Created by Layla Gordon on 10/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OSLocationService.h"
#import "OSCoreLocationManager.h"
#import "OSLocationServiceObserverProtocol.h"
#import "OSServiceRelationshipManager.h"

@import CoreLocation;

@interface OSLocationServiceTests : XCTestCase

@end

@implementation OSLocationServiceTests

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

- (id)mockCoreLocationManagerAllowLocation:(BOOL)allowLocation allowHeading:(BOOL)allowHeading
{
    id mockCoreLocationManager = [OCMockObject niceMockForClass:[OSCoreLocationManager class]];
    [[[[mockCoreLocationManager stub] classMethod] andReturnValue:OCMOCK_VALUE(allowLocation)] locationUpdatesAvailable];
    [[[[mockCoreLocationManager stub] classMethod] andReturnValue:OCMOCK_VALUE(allowHeading)] headingUpdatesAvailable];
    
    return mockCoreLocationManager;
}

- (void)testAddingLocationOptionTurnsOnCoreLocation
{
    id mockLocationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[[mockLocationManager stub] andReturn:mockLocationManager] alloc];
    
    id mockCoreLocationManager = [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];
        
    OSLocationService *service = [[OSLocationService alloc] init];
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceLocationUpdates sender:dummyIdentifier];
    
    OCMVerify([mockLocationManager startUpdatingLocation]);
}

- (void)testAddingHeadingOptionTurnsOnCoreLocationHeading
{
    id mockLocationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[[mockLocationManager stub] andReturn:mockLocationManager] alloc];
    
    id mockCoreLocationManager = [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];
    
    OSLocationService *service = [OSLocationService defaultService];
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:dummyIdentifier];
    
    OCMVerify([mockLocationManager startUpdatingHeading]);
}

- (void)testStopUpdateForObjectRemovesAllOptions
{
    OSLocationService *service = [OSLocationService defaultService];
    NSString *dummyIdentifier = @"Dummy";
    [service startUpdatingWithOptions:OSLocationServiceHeadingUpdates | OSLocationServiceLocationUpdates sender:dummyIdentifier];
    
    [service stopUpdatesForSender:dummyIdentifier];
    
    OSLocationServiceUpdateOptions expectedOptions = OSLocationServiceNoUpdates;
    OSLocationServiceUpdateOptions actualOptions = [service optionsForSender:dummyIdentifier];
    XCTAssertEqual(expectedOptions, actualOptions, @"All Options were not removed properly");
}

- (void)testStopUpdatesForCertainOptionsOnlyTurnsOffThoseOptions
{
    id mockCoreLocationManager = [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];
    
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

- (void)testPassingIncompatibleSenderToStartThrowsException
{
    id mockCoreLocationManager = [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];
    NSObject *nonCopyingObject = [[NSObject alloc] init];
    
    OSLocationService *service = [OSLocationService defaultService];
    XCTAssertThrows([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:nonCopyingObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingCompatibleSenderToStartThatImplementsNSCopyingDoesntThrowException
{
    id mockCoreLocationManager = [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];
    NSString *validObject = @"Valid"; //NSString conforms to NSCopying
    
    OSLocationService *service = [OSLocationService defaultService];
    XCTAssertNoThrow([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:validObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingCompatibleSenderToStartThatImplementsLocationServiceProtocolDoesntThrowException
{
    id mockCoreLocationManager = [self mockCoreLocationManagerAllowLocation:YES allowHeading:YES];
    id mockValidObject = [OCMockObject mockForProtocol:@protocol(OSLocationServiceObserverProtocol)];
    [[[mockValidObject stub] andReturn:@"DummyID"] locationServiceIdentifier];
    
    OSLocationService *service = [OSLocationService defaultService];
    XCTAssertNoThrow([service startUpdatingWithOptions:OSLocationServiceHeadingUpdates sender:mockValidObject], @"Invalid object doesn't throw exception");
}

- (void)testPassingIncompatibleSenderToOptionsForSenderReturnsNoOptions
{
    NSObject *invalidObject = [[NSObject alloc] init];
    OSLocationService *service = [OSLocationService defaultService];
    
    OSLocationServiceUpdateOptions expectedOptions = OSLocationServiceNoUpdates;
    OSLocationServiceUpdateOptions actualOptions = [service optionsForSender:service];
    XCTAssertEqual(expectedOptions, actualOptions, @"Passing invalid object returns some options");
}




@end