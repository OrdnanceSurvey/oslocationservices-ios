//
//  OSLocationService.m
//  OSLocationService
//
//  Created by Layla Gordon on 10/06/2014.
//  Copyright (c) 2014 Ordnance Survey. All rights reserved.
//


//kCLLocationAccuracyBestForNavigation  highest + sensor data
//*     kCLLocationAccuracyBest               highest
//*     kCLLocationAccuracyNearestTenMeters   10 meters
//*     kCLLocationAccuracyHundredMeters      100 meters
//*     kCLLocationAccuracyKilometer          1000 meters
//*     kCLLocationAccuracyThreeKilometers    3000 meters
//

#import "OSLocationService.h"
#import <CoreLocation/CoreLocation.h>

@interface OSLocationService()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;


@end


@implementation OSLocationService

// Self
static OSLocationService *sharedServiceProviderInstance = nil;


+ (OSLocationService *) shared
{
    @synchronized(self)
    {
        if (sharedServiceProviderInstance == NULL)
        {
            sharedServiceProviderInstance = [[self alloc] init];
        }
    }
    return(sharedServiceProviderInstance);
}

//startUpdatingHeading
-(BOOL) startUpdatingHeading
{
    
    if([CLLocationManager headingAvailable])
    {
        _locationManager.headingFilter = kCLHeadingFilterNone;
        
        //start the location manager
        
        [_locationManager startUpdatingHeading];
        _locationManager.delegate = self;
        return YES;
        
    }
    else
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_SERVICES_ERROR object:nil];
        return NO;
    }
    
    return NO;
}


/**
 stopUpdatingHeading
 */

-(BOOL) stopUpdatingHeading
{
    if(_locationManager)
    {
        [_locationManager stopUpdatingHeading];
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        return YES;
    }
    return NO;
    
}

-(id) init
{
    self = [super init];
    if (self)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _currentGridReferencePosition = nil;
        _curaltitude = 0.0;
    }
    return self;
}

//startAllServices
-(BOOL) startAllServicesWithAccuracy:(CLLocationAccuracy) accuracyValue
{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    NSLog(@"ENABLED%d", ([CLLocationManager locationServicesEnabled]));
    
    
    
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager headingAvailable])
    {
        
        //_locationManager.headingFilter = kCLHeadingFilterNone;
        //_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        //distance filter not set
        
        
        [_locationManager setHeadingFilter:kCLHeadingFilterNone];
        [_locationManager setDesiredAccuracy:accuracyValue];
        
        //start the location manager
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
        return YES;
        
    }
    else if ([deviceType rangeOfString:@"iPhone"].location==NSNotFound)
    {
        NSLog(@"IPODDDDDD");
        UIAlertView *noCompassDeviceAlert = [[UIAlertView alloc] initWithTitle:@"InCompatible Device" message:@"This Device is not compatible with Compass" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [noCompassDeviceAlert show];
        
        
        return YES;
    }
    
    else if (![CLLocationManager locationServicesEnabled]){
        //call the delegate that location service is enabled
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_SERVICES_ERROR object:nil];
        return NO;
    }
    return NO;
    
}


//stopAllServices
-(BOOL) stopAllServices
{
    //dissmiss all calibration
    if(_locationManager)
    {
        [_locationManager dismissHeadingCalibrationDisplay];
        //stop the location manager
        [_locationManager stopUpdatingHeading];
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        return YES;
    }
    
    return NO;
    
}

/**
 stopUpdatingLocation
 */

-(BOOL) stopUpdatingLocation
{
    if(_locationManager)
    {
        [_locationManager stopUpdatingHeading];
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        return YES;
    }
    return NO;
}




#pragma mark
#pragma mark - CoreLocation


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	
    // Convert Degree to Radian
    
    NSNumber * oldRad =  [ NSNumber numberWithFloat:manager.heading.magneticHeading];
	NSNumber * newRad =  [ NSNumber numberWithFloat:newHeading.magneticHeading];
    
    NSDictionary*  userInfo = [NSDictionary dictionaryWithObjectsAndKeys:oldRad, @"oldValue",newRad,@"newValue",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DIRECTION_NEEDS_CHANGE object:nil userInfo:userInfo];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return _locationManagerShouldDisplayHeadingCalibration;
}


- (void)dismissTheHeadingCalibrationDisplay
{
    [_locationManager dismissHeadingCalibrationDisplay];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError: %@", error);
    
    //ignore the unknown errors
    if(error.code == kCLErrorLocationUnknown)
        return;
    
    if(error.code == kCLErrorDenied)
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_SERVICES_ERROR object:nil];
    
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //  NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //  NSString *documentsDirectory = [documentPaths objectAtIndex:0];
    //  NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:@"tracklog.txt"];
    
    
    [self setCurrentLatLongPosition: [locations lastObject]];
    float alt = [[self currentLatLongPosition] altitude];
    // NSString *stralt = [NSString stringWithFormat:@"%f", alt];
    
    
    /*for (CLLocation *location in locations) {
     NSString *locationlogentry;
     
     locationlogentry = [NSString stringWithFormat:@"%@%@%@%s%f\n", [location description], @
     ",altitide, ",stralt, ",vertical accuracy,", [location verticalAccuracy]];
     NSLog(@"locationlogentry %@",locationlogentry);
     
     NSFileHandle *myHandle = [NSFileHandle fileHandleForUpdatingAtPath:documentTXTPath ];
     
     
     if(myHandle == nil) {
     [locationlogentry writeToFile:documentTXTPath atomically:YES encoding:NSUTF8StringEncoding error:nil] ;
     } else {
     [myHandle seekToEndOfFile];
     [myHandle writeData:  [locationlogentry dataUsingEncoding:NSUTF8StringEncoding]];
     [myHandle closeFile];
     }
     }
     */
    if ([self currentLatLongPosition] != nil)
    {
        //update display
        NSLog(@"currentlatlongposition %f", [self currentLatLongPosition].coordinate.latitude);
        NSString* gps = [self getGridPointRefference:[self currentLatLongPosition].coordinate];
        //if (gps == nil)
        //{
        
        //   return;
        
        // }
        NSLog(@"Vertical Accuracy : %lf",[[self currentLatLongPosition] verticalAccuracy]);
        NSLog(@"Horizontal Accuracy : %lf",[[self currentLatLongPosition] horizontalAccuracy]);
        
        // [currentLocation coordinate].latitude;
        // [currentLocation coordinate].longitude;
        
        
        if ([[self currentLatLongPosition] verticalAccuracy] >= 0 && alt <= 50000.9)
        {
            
            NSLog(@"Altitude = %lf",alt);
            
            // alt = truncf(alt* 100) / 100;
            
            // NSLog(@"Altitude truncated= %lf",alt);
            
            
            
        }
        else
        {
            alt= 0;
        }
        
        
        if ([_currentGridReferencePosition isEqualToString:@""] || ![_currentGridReferencePosition isEqualToString:gps])
        {
            _currentGridReferencePosition = gps;
            [self updateAndNotifyGridReffChange:[self currentLatLongPosition].horizontalAccuracy andDesiredAccuracy:manager.desiredAccuracy];
        }
        if (!(_curaltitude == alt))
        {
            _curaltitude = alt;
            [self updateAndNotifyGridReffChange:[self currentLatLongPosition].horizontalAccuracy andDesiredAccuracy:manager.desiredAccuracy];
        }
        
    }
}

-(void) updateAndNotifyGridReffChange:(CLLocationAccuracy) horizontalAccuracy andDesiredAccuracy:(CLLocationAccuracy) desiredAccuracy
{
    NSString * grid;
    NSString * easting;
    NSString * northing;
    //NSString * altitude;
    double lat;
    double longi;
    
    
    NSArray *subStrings = [_currentGridReferencePosition componentsSeparatedByString:@" "];
    if ([subStrings count] == 1) {
        return;
    }
    
    grid     =    [subStrings objectAtIndex:0];
    easting  =    [subStrings objectAtIndex:1];
    northing =    [subStrings objectAtIndex:2];
    
    //     formatter = [[NSNumberFormatter alloc] init];
    
    lat = [self currentLatLongPosition].coordinate.latitude;
    longi = [self currentLatLongPosition].coordinate.longitude;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if (grid != nil) {
        [userInfo setObject:grid forKey:@"grid"];
    }
    else {
        [userInfo setObject:@"nil" forKey:@"grid"];
    }
    
    if (easting != nil) {
        [userInfo setObject:easting forKey:@"easting"];
    }
    else
    {
        [userInfo setObject:@"---" forKey:@"easting"];
    }
    
    if (northing != nil) {
        
        [userInfo setObject:northing forKey:@"northing"];
    }
    else
    {
        [userInfo setObject:@"---" forKey:@"northing"];
    }
    if (_curaltitude != 0) {
        [userInfo setObject:[NSNumber numberWithDouble:_curaltitude] forKey:@"altitude"];
    }
    if (lat != 0) {
        [userInfo setObject:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
    }
    if (longi != 0) {
        [userInfo setObject:[NSNumber numberWithDouble:longi] forKey:@"longitude"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GRID_REFF_CHANGE object:nil userInfo:userInfo];
    //}
    // else
    // {
    //     grid     =    @"---";
    //     easting  =    @"---";
    //     northing =    @"---";
    //     NSDictionary*  userInfo = [NSDictionary dictionaryWithObjectsAndKeys:grid, @"grid",easting,@"easting",northing,@"northing",nil];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GRID_REFF_CHANGE object:nil userInfo:userInfo];
    
    // }
}


-(NSString*) getGridPointRefference:(CLLocationCoordinate2D)coordinate
{
    //update display
    //CLLocationCoordinate2D co;
    //co.latitude = 22.28468100;
    //co.longitude = 114.15817700;
    OSGridPoint gp = OSGridPointForCoordinate(coordinate);
    NSString * gridRef = NSStringFromOSGridPoint(gp, 3);
    
    //test if point is within GB
    if( !OSGridPointIsWithinBounds(gp) )
    {
        return nil;
    }
    return gridRef;
}

- (BOOL) isInUSA {
    
    if ([self currentLatLongPosition] == nil)
        return true;
    
    else if(([self currentLatLongPosition].coordinate.latitude > 18.0) &&
            ([self currentLatLongPosition].coordinate.latitude < 85.0) &&
            ([self currentLatLongPosition].coordinate.longitude > -170.0) &&
            ([self currentLatLongPosition].coordinate.longitude < -50.0)) {
        return true;
    }
    else
    {
        return false;
    }
}

@end


//startAllServices
/*-(BOOL) startAllServices
 {
 
 return [self startAllServicesWithAccuracy:kCLLocationAccuracyBest];
 
 
 
 
 }
 */

//startUpdatingLocation
/*- (BOOL)startUpdatingLocationWithAccuracy:(CLLocationAccuracy)accuracy
 {
 
 if([CLLocationManager locationServicesEnabled])
 {
 _locationManager.desiredAccuracy = accuracy;
 
 //start the location manager
 [_locationManager startUpdatingLocation];
 
 
 
 
 return YES;
 }
 else
 {
 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_SERVICES_ERROR object:nil];
 return NO;
 }
 
 return NO;
 }
 */

/*-(BOOL) isIpod
 {
 NSString *deviceType = [UIDevice currentDevice].model;
 if([deviceType rangeOfString:@"iPhone"].location==NSNotFound)
 {
 NSLog(@"an iPod");
 return TRUE;
 
 }
 else
 return FALSE;
 
 }
 */

