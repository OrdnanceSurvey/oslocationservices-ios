//
//  OSLocationTests.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OSLocation.h"
#import <OSMap/OSMap.h>

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

- (void)testLocationInitialzesWithCorrectInfo
{
    float latitude = 50.938149;
    float longitude = -1.4703144;
    float timeIntervalSince1970 = 15673;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    OSLocation *location = [[OSLocation alloc] initWithCoordinate:coordinate dateTaken:[NSDate dateWithTimeIntervalSince1970:timeIntervalSince1970]];
    
    XCTAssertEqual(location.latitude, latitude, @"Latitude was not equal");
    XCTAssertEqual(location.longitude, longitude, @"Longitude was not equal");
    XCTAssertEqual([location.dateTaken timeIntervalSince1970], timeIntervalSince1970, @"Date was not equal");
}

- (void)testLocationReturnsCorrectGridPoint
{
    //These figures verified as correct externally from frameworks. Should be Explorer House coordinates/grid ref
    float latitude = 50.938149;
    float longitude = -1.4703144;
    float eastings = 437315;
    float northings = 115545;
    
    OSLocation *location = [[OSLocation alloc] initWithLatitude:latitude longitude:longitude];
    OSGridPoint gridPoint = location.gridPoint;
    
    //Rounded because we allow a certain amount of inaccuracy
    XCTAssertEqual(round(gridPoint.easting), eastings, @"Eastings was not correct");
    XCTAssertEqual(round(gridPoint.northing), northings, @"Northings was not correct");
    
}

@end
