//
//  OSServiceRelationshipManager.h
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSLocationServiceOptions.h"

@class OSServiceRelationshipManager;

@protocol OSServiceRelationshipManagerDelegate <NSObject>

@optional
- (void)relationshipManagerDidChangeRelationships:(OSServiceRelationshipManager *)manager;

@end

@interface OSServiceRelationshipManager : NSObject

@property (weak, nonatomic) id<OSServiceRelationshipManagerDelegate> delegate;


/** @name Managing Options */

/**
*  Add Options to an object. If the object hasn't been previously seen, it will be added. Raises an exception if a nil object is passsed.
*
*  @param options The Options to add
*  @param object  The object the Options relate to
*
*  @return The combined Options the passed object is now running with, after the add
*/
- (OSLocationServiceUpdateOptions)addOptions:(OSLocationServiceUpdateOptions)options forObject:(id)object;

/**
 *  Remove Options from an object. If the object has no Options left, it will be removed. Raises an exception if a nil object is passed.
 *
 *  @param options The Options to add
 *  @param object  The object the Options relate to
 *
 *  @return The combined Options the passed object is now running with, after the add
 */
- (OSLocationServiceUpdateOptions)removeOptions:(OSLocationServiceUpdateOptions)options forObject:(id)object;

/**
 *  The current Options for an object
 *
 *  @param object The object to look up
 *
 *  @return The options the object is watching. If the object hasn't been previously seen, OSLocationServiceNoUpdates is returned.
 */
- (OSLocationServiceUpdateOptions)optionsForObject:(id)object;

/**
 *  The sum of all Options that all tracked objects want.
 *
 *  @return Options that all objects want in total.
 */
- (OSLocationServiceUpdateOptions)cumulativeOptions;

@end
