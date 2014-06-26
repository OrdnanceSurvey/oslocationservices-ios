//
//  OSServiceRelationshipManagerTests.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OSServiceRelationshipManager.h"

@interface OSServiceRelationshipManagerTests : XCTestCase

@end

@implementation OSServiceRelationshipManagerTests

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

- (void)testAddingNewObjectWithOptions {
    OSServiceRelationshipManager *relationshipManager = [[OSServiceRelationshipManager alloc] init];
    
    //We need to use a dummy object as XCTestCase doesn't conform to NSCopy or NSCoding
    NSString *dummyObject1 = @"Dummy1";
    OSLocationServiceUpdateOptions passedOptions1 = OSLocationServiceLocationUpdates;
    
    [relationshipManager addOptions:passedOptions1 forObject:dummyObject1];
    OSLocationServiceUpdateOptions returnedOptions1 = [relationshipManager optionsForObject:dummyObject1];
    
    XCTAssertEqual(passedOptions1, returnedOptions1, @"Passed Options were not returned");
    
    NSString *dummyObject2 = @"Dummy2";
    OSLocationServiceUpdateOptions passedOptions2 = OSLocationServiceAllOptions;
    
    [relationshipManager addOptions:passedOptions2 forObject:dummyObject2];
    OSLocationServiceUpdateOptions returnedOptions2 = [relationshipManager optionsForObject:dummyObject2];
    
    XCTAssertEqual(passedOptions2, returnedOptions2, @"Passed Options were not returned");
    
    //Test for dummy1 again to be sure
    OSLocationServiceUpdateOptions returnedOptions3 = [relationshipManager optionsForObject:dummyObject1];
    
    XCTAssertEqual(passedOptions1, returnedOptions3, @"Passed Options were not returned");
}

- (void)testRemovingExistingObjectWithOptionsAndWithStartedOptions {
    OSServiceRelationshipManager *relationshipManager = [[OSServiceRelationshipManager alloc] init];
    
    //We need to use a dummy object as XCTestCase doesn't conform to NSCopy or NSCoding
    NSString *dummyObject1 = @"Dummy1";
    OSLocationServiceUpdateOptions passedOptions1 = OSLocationServiceLocationUpdates;
    
    [relationshipManager addOptions:passedOptions1 forObject:dummyObject1];
    
    OSLocationServiceUpdateOptions remainingOptions = [relationshipManager removeOptions:OSLocationServiceLocationUpdates forObject:dummyObject1];
    OSLocationServiceUpdateOptions expectedRemaining = OSLocationServiceNoUpdates;
    XCTAssertEqual(remainingOptions, expectedRemaining, @"Remaining Options were not correct");
}

- (void)testRemovingExistingObjectWithOptionsAndWithUnstartedOptions {
    OSServiceRelationshipManager *relationshipManager = [[OSServiceRelationshipManager alloc] init];
    
    //We need to use a dummy object as XCTestCase doesn't conform to NSCopy or NSCoding
    NSString *dummyObject1 = @"Dummy1";
    OSLocationServiceUpdateOptions passedOptions1 = OSLocationServiceLocationUpdates;
    
    [relationshipManager addOptions:passedOptions1 forObject:dummyObject1];
    
    OSLocationServiceUpdateOptions optionsToBeRemoved = OSLocationServiceHeadingUpdates;
    
    OSLocationServiceUpdateOptions remainingOptions = [relationshipManager removeOptions:optionsToBeRemoved forObject:dummyObject1];
    OSLocationServiceUpdateOptions expectedRemaining = OSLocationServiceLocationUpdates;
    XCTAssertEqual(remainingOptions, expectedRemaining, @"Remaining Options were not correct");
}

- (void)testRemovingNonExistingObjectWithOptions {
    OSServiceRelationshipManager *relationshipManager = [[OSServiceRelationshipManager alloc] init];
    
    //Relationship Manager is empty
    
    NSString *dummyObject1 = @"Dummy1";
    
    OSLocationServiceUpdateOptions remainingOptions = [relationshipManager removeOptions:OSLocationServiceLocationUpdates forObject:dummyObject1];
    OSLocationServiceUpdateOptions expectedOptions = OSLocationServiceNoUpdates;
    XCTAssertEqual(remainingOptions, expectedOptions, @"Remaining Options were available");
}

- (void)testAddingOptionsToExisitngObject {
    OSServiceRelationshipManager *relationshipManager = [[OSServiceRelationshipManager alloc] init];
    
    NSString *dummyObject1 = @"Dummy1";
    
    OSLocationServiceUpdateOptions initialOptions = OSLocationServiceHeadingUpdates;
    OSLocationServiceUpdateOptions additionalOptions = OSLocationServiceLocationUpdates;
    
    [relationshipManager addOptions:initialOptions forObject:dummyObject1];
    
    XCTAssertEqual(initialOptions, [relationshipManager optionsForObject:dummyObject1], @"Options were not committed successfully");
    
    [relationshipManager addOptions:additionalOptions forObject:dummyObject1];
    
    OSLocationServiceUpdateOptions expectedOptions = OSLocationServiceLocationUpdates | OSLocationServiceHeadingUpdates;
    OSLocationServiceUpdateOptions actualOptions = [relationshipManager optionsForObject:dummyObject1];
    
    XCTAssertEqual(expectedOptions, actualOptions, @"New Options were not added properly");
}

- (void)testRemovingOptionsFromExistingObject {
    OSServiceRelationshipManager *relationshipManager = [[OSServiceRelationshipManager alloc] init];
    
    NSString *dummyObject1 = @"Dummy1";
    
    OSLocationServiceUpdateOptions initialOptions = OSLocationServiceHeadingUpdates | OSLocationServiceLocationUpdates;
    OSLocationServiceUpdateOptions optionsToBeRemoved = OSLocationServiceLocationUpdates;
    
    [relationshipManager addOptions:initialOptions forObject:dummyObject1];
    
    XCTAssertEqual(initialOptions, [relationshipManager optionsForObject:dummyObject1], @"Options were not committed successfully");
    
    [relationshipManager removeOptions:optionsToBeRemoved forObject:dummyObject1];
    
    OSLocationServiceUpdateOptions expectedOptions = OSLocationServiceHeadingUpdates;
    OSLocationServiceUpdateOptions actualOptions = [relationshipManager optionsForObject:dummyObject1];
    
    XCTAssertEqual(expectedOptions, actualOptions, @"Options were not removed properly");
}

@end
