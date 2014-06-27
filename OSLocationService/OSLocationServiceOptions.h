//
//  OSLocationServiceOptions.h
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, OSLocationServiceUpdateOptions) {
    OSLocationServiceNoUpdates = 0,
    OSLocationServiceLocationUpdates = 1 << 0,
    OSLocationServiceHeadingUpdates = 1 << 1,
    OSLocationServiceAllOptions = OSLocationServiceLocationUpdates | OSLocationServiceHeadingUpdates
};
