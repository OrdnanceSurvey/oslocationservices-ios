//
//  OSLocationServicePreferences.h
//  OSLocationService
//
//  Created by Jake Skeates on 01/07/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//

typedef NS_ENUM(NSUInteger, OSLocationServiceAuthorizationStatus) {
    OSLocationServiceAuthorizationNotDetermined = 0, //Not yet asked user for permission
    OSLocationServiceAuthorizationRestricted, //User is not able to change privacy settings
    OSLocationServiceAuthorizationDenied, //User has explicitly denied access to location
    OSLocationServiceAuthorizationAllowedAlways, //User has allowed access to location in all scenarios
    OSLocationServiceAuthorizationAllowedWhenInUse, //User has allowed access to location only when app is explicitly in foreground (for iOS8+)
    OSLocationServiceAuthorizationUnknown = 99
};

typedef NS_ENUM(NSUInteger, OSLocationServicePermission) {
    OSLocationServicePermissionWhenInUse,
    OSLocationServicePermissionAlways
};

/*
 *	OSActivityType
 *
 *  Discussion:
 *		Enumerates the different possible activity types. This currently
 *		affects behavior such as the determination of when location updates
 *		may be automatically paused.
 */
typedef NS_ENUM(NSInteger, OSActivityType) {
    OSActivityTypeOther = 1,
    OSActivityTypeAutomotiveNavigation, // for automotive navigation
    OSActivityTypeFitness, // includes any pedestrian activities
    OSActivityTypeOtherNavigation // for other navigation cases (excluding pedestrian navigation), e.g. navigation for boats, trains, or planes
};
