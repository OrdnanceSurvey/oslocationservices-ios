//
//  OSLocationProvider.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSLocationService.h"
#import "OSServiceRelationshipManager.h"

@interface OSLocationService ()

@property (strong, nonatomic) OSServiceRelationshipManager *relationshipManager;


@end

@implementation OSLocationService

+ (instancetype)defaultService
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _relationshipManager = [[OSServiceRelationshipManager alloc] init];
    }
    return self;
}

#pragma mark - Starting updates

- (OSLocationServiceUpdateOptions)startUpdatingWithOptions:(OSLocationServiceUpdateOptions)updateOptions sender:(id)sender
{
    return OSLocationServiceNoUpdates;
}

#pragma mark - Stopping updates

- (void)stopUpdatesForOptions:(OSLocationServiceUpdateOptions)options sender:(id)sender
{
    
}

- (void)stopUpdatesForSender:(id)sender
{
    [self stopUpdatesForOptions:OSLocationServiceAllOptions sender:sender];
}


@end
