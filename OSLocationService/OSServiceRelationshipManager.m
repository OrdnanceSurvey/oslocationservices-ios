//
//  OSServiceRelationshipManager.m
//  OSLocationService
//
//  Created by Jake Skeates on 26/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

#import "OSServiceRelationshipManager.h"

@interface OSServiceRelationshipManager ()

@property (strong, nonatomic) NSMutableDictionary *relationshipDictionary;

@end

@implementation OSServiceRelationshipManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.relationshipDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}

- (OSLocationServiceUpdateOptions)addOptions:(OSLocationServiceUpdateOptions)options forObject:(id)object
{
    if (object == nil) {
        NSException *exception = [NSException exceptionWithName:@"OSServiceRelationshipManagerNilObjectException" reason:@"Cannot pass a nil object to addOptions:forObject:" userInfo:nil];
        [exception raise];
    }
    
    OSLocationServiceUpdateOptions oldOptions = [self optionsForObject:object];
    OSLocationServiceUpdateOptions newOptions = oldOptions | options;
    [self.relationshipDictionary setObject:@(newOptions) forKey:object];
    [self notifyDelegateOfChanges];
    
    return newOptions;
}

- (OSLocationServiceUpdateOptions)removeOptions:(OSLocationServiceUpdateOptions)options forObject:(id)object
{
    if (object == nil) {
        NSException *exception = [NSException exceptionWithName:@"OSServiceRelationshipManagerNilObjectException" reason:@"Cannot pass a nil object to removeOptions:forObject:" userInfo:nil];
        [exception raise];
    }
    
    OSLocationServiceUpdateOptions currentOptions = [self optionsForObject:object];
    
    if (currentOptions == OSLocationServiceNoUpdates) {
        return OSLocationServiceNoUpdates;
    } else {
        
        /* A material nonimplication operation: http://en.wikipedia.org/wiki/Material_nonimplication
         We use it to deduct the given Options from the current Options */
        OSLocationServiceUpdateOptions newOptions = (currentOptions & (~options));
        
        if (newOptions == OSLocationServiceNoUpdates) {
            [self.relationshipDictionary removeObjectForKey:object];
        } else {
            [self.relationshipDictionary setObject:@(newOptions) forKey:object];
        }
        
        [self notifyDelegateOfChanges];
        
        return newOptions;
    }
    
//    return OSLocationServiceNoUpdates;
}

- (OSLocationServiceUpdateOptions)optionsForObject:(id)object
{
    if ([self.relationshipDictionary objectForKey:object] == nil) {
        return OSLocationServiceNoUpdates;
    } else {
        NSNumber *number = [self.relationshipDictionary objectForKey:object];
        OSLocationServiceUpdateOptions options = [number integerValue];
        return options;
    }
//    return OSLocationServiceNoUpdates; //You should never reach here!
}

- (OSLocationServiceUpdateOptions)cumulativeOptions
{
    NSEnumerator *keys = [self.relationshipDictionary keyEnumerator];
    OSLocationServiceUpdateOptions cumulativeOptions = OSLocationServiceNoUpdates;
    
    for (NSObject *key in keys) {
        OSLocationServiceUpdateOptions optionsForThisKey = [self optionsForObject:key];
        cumulativeOptions = cumulativeOptions | optionsForThisKey;
    }
    
    return cumulativeOptions;
}

- (void)notifyDelegateOfChanges
{
    if ([self.delegate respondsToSelector:@selector(relationshipManagerDidChangeRelationships:)]) {
        [self.delegate relationshipManagerDidChangeRelationships:self];
    }
}

- (NSString *)whatDoesITStandFor
{
    return @"Internet Things";
}

@end
