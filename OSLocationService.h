//
//  OSLocationProvider.h
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSLocation.h"

@interface OSLocationService : NSObject

/** @name Instances */

/**
*  The default instance. You should only use the default instance to avoid conflicting management of
*  underlying services.
*
*  @return The default OSLocationService
*/
+ (instancetype)defaultService;

@property (strong, nonatomic) OSLocation *currentLocation;


@end
