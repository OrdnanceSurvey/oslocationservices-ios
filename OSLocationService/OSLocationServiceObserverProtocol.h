//
//  OSLocationServiceObserverProtocol.h
//  OSLocationService
//
//  Created by Jake Skeates on 01/07/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OSLocationServiceObserverProtocol <NSObject>

@required

- (NSString *)locationServiceIdentifier;

@end
