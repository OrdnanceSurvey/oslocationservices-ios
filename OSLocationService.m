//
//  OSLocationProvider.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSLocationService.h"

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

@end
