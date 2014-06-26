//
//  OSLocationTests.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OSLocation.h"

@import CoreLocation;

@interface OSLocationTests : XCTestCase

@end

@implementation OSLocationTests

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

- (void)testLocationReturnsCorrectCoordinate
{
    OSLocation *location = [[OSLocation alloc] initWithLatitude:50.720754f longitude:-3.5016017f];
    CLLocationCoordinate2D actualCoordinate = CLLocationCoordinate2DMake(50.720754f, -3.5016017f);
    CLLocationCoordinate2D testCoordinate = location.coordinate;
    XCTAssertEqual(actualCoordinate.latitude, testCoordinate.latitude, @"Coordinate returned's latitude was not equal");
    XCTAssertEqual(actualCoordinate.longitude, testCoordinate.longitude, @"Coordinate returned's longitude was not equal");
}

@end
