//
//  ViewController.m
//  OSLocationTestHost
//
//  Created by David Haynes (C) on 15/12/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) OSLocationService *locationService;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _locationService = [[OSLocationService alloc] init];
    _locationService.delegate = self;
    [_locationService startUpdatingWithOptions:OSLocationServiceAllOptions permissionLevel:OSLocationServicePermissionWhenInUse sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - OSLocationServiceObserverProtocol
- (NSString *)locationServiceIdentifier {
    return @"OSLocationServiceIdentifier";
}

#pragma mark - OSLocationServiceDelegate
- (void)locationService:(OSLocationService *)service didUpdateLocations:(NSArray *)locations {
    OSLocation *location = [locations firstObject];
    NSLog(@"location: %@", location);
}

- (void)locationService:(OSLocationService *)service didUpdateHeading:(OSLocationDirection)heading {
    NSLog(@"heading: %f", heading);
}

@end
