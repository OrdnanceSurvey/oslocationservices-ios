// The OpenSpace iOS SDK is protected by (c) Crown copyright – Ordnance Survey 2012.[https://github.com/OrdnanceSurvey]

// All rights reserved (subject to the BSD licence terms as follows):

// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:

// * Redistributions of source code must retain the above copyright notice, this
// 	 list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice, this
// 	 list of conditions and the following disclaimer in the documentation and/or
// 	 other materials provided with the distribution.
// * Neither the name of Ordnance Survey nor the names of its contributors may
// 	 be used to endorse or promote products derived from this software without
// 	 specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE


// The OpenSpace iOS SDK includes the Route-Me library.
// The Route-Me library is copyright (c) 2008-2012, Route-Me Contributors
// All rights reserved (subject to the BSD licence terms as follows):

// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:

// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
// OF SUCH DAMAGE.

// Route-Me depends on the Proj4 Library. [ http://trac.osgeo.org/proj/wiki/WikiStart ]
// Proj4 is copyright (c) 2000, Frank Warmerdam / Gerald Evenden
// Proj4 is subject to the MIT licence as follows:

//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.

// Route-Me depends on the fmdb library. [ https://github.com/ccgus/fmdb ]
// fmdb is copyright (c) 2008 Flying Meat Inc
// fmdb is subject to the MIT licence as follows:

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <UIKit/UIKit.h>

// For CLLocationCoordinate2D
#import <CoreLocation/CoreLocation.h>

// For OSAnnotationViewDragState
#import "OSMap/OSAnnotationView.h"

// For OSGridPoint
#import "OSMap/OSGridPoint.h"

// For OSMapScaleView
#import "OSMap/OSMapScaleView.h"

// Forward decls
@class OSOpenSpaceWebSource;
@class OSUserLocation;
@class OSOverlayView;

@protocol OSAnnotation;
@protocol OSOverlay;
@protocol OSMapViewDelegate;
@protocol OSTileSource;

typedef enum {
   OSUserTrackingModeNone = 0,
   OSUserTrackingModeFollow,
   OSUserTrackingModeFollowWithHeading __attribute__((deprecated("Not supported yet - handled identically to OSUserTrackingModeFollow"))),
} OSUserTrackingMode;

/** 
`OSMapView` provides an interface to Ordnance Survey OpenSpace maps, supporting the same mapping layers as the OpenSpace and OpenSpace Pro JavaScript APIs.

`OSMapView` is intended to provide a drop-in replacement for MapKit's `MKMapView` and has a largely similar API.
The API is as close as can it can be, while maintaintaining differentation with the use of the OS prefix (instead of MK) for all classes.
In general, therefore, OSMapView is adequately documented by the MapKit documentation which cannot be reproduced here for copyright reasons.
There are a few main differences:

* `OSMapView` uses the OSGB36 National Grid map projection.
  Applications which have assumed a Mercator projection may have to take the different projection into account.
* `OSMapView` does not support drawing maps outside the UK.
* `OSMapView` requires an API key and a tile source to be set before using the online data source.
* `OSMapView` supports many more map configurations than can be easily expressed with a single `mapType` property.
* `OSMapView` and `OSOverlayView` do not use power-of-2 zoom levels.
* `OSMapView` cannot be completely initialised from a NIB.
* `OSGridPoint` is in a specified coordinate system: it's is a National Grid reference in metres.
* OSMapViewDelegate does not have map-loading callbacks.

### Tile sources and API keys

`OSMapView` requires either an OS OpenSpace API key or a file containing map tiles in "OSTiles" format.

    id<OSTileSource> tileSource = [OSMapView webTileSourceWithAPIKey:YOUR_API_KEY refererUrl:YOUR_PAGE_URL openSpacePro:false];
    mapView.tileSources = [NSArray arrayWithObject:tileSource];

### Coordinate conversions

`OSGridPoint` represents OSGB36 National Grid easting/northing
(i.e. a "numeric-only" National Grid reference).

`CLLocationCoordinate2D` represents WGS84 latitude/longitude.

OSGB36 latitude/longitude is not currently supported. ETRS89 is not explicitly supported, but is closely approximated by WGS84.

Conversion between `CLLocationCoordinate2D` and `OSGridPoint` is largely handled internally —
applications should not need to perform more conversions than with WGS84-based mapping APIs.

However, applications should be aware of the limitations of these conversions:

* The conversion is approximate. It is usually correct to within 3m compared to OSTN02.
* WGS84 lines of latitude/longitude are not aligned with National Grid.
  A consequence is that `OSCoordinateRegion` and `OSGridRect` represent different shapes, and thus cannot be interconverted accurately.
* The conversions used are subject to change (in particular, accuracy may be improved).

Applications should avoid unnecessary conversions. Coordinates should be stored in their source coordinate system in order to benefit from future accuracy improvements.

### Subclassing notes

`OSMapView` is not designed to be subclassed.

*/
@interface OSMapView : UIView

@property (nonatomic, weak) id<OSMapViewDelegate> delegate;

/// @name Creating and using tile sources
@property (nonatomic, copy) NSArray * tileSources;

/// @name Map scale view that gets automatically resized as the zoom changes, but does not pan
@property (nonatomic, assign) OSMapScaleView* mapScaleView;

/// @name Managing scrolling and zooming
@property (nonatomic, assign) BOOL zoomEnabled;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) OSGridRect visibleGridRect;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) OSCoordinateRegion region;

/// @name Current zoom level
@property (nonatomic, readonly) float metresPerPixel;

/// @name User location
@property (nonatomic, assign) bool showsUserLocation;
@property (nonatomic, assign) OSUserTrackingMode userTrackingMode;
@property (nonatomic, strong, readonly) OSUserLocation * userLocation;
@property (nonatomic, assign, readonly, getter=isUserLocationVisible) bool userLocationVisible;

/// @name Managing annotations
@property (nonatomic, readonly) NSArray *annotations;
@property (nonatomic, copy) NSArray *selectedAnnotations;
@property (nonatomic, readonly) CGRect annotationVisibleRect;

/// @name Managing overlays
@property (nonatomic, copy, readonly) NSArray *overlays;

/// @name Managing scrolling and zooming

-(void)setVisibleGridRect:(OSGridRect)visibleGridRect animated:(BOOL)animated;
-(void)setVisibleGridRect:(OSGridRect)visibleGridRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated;
-(void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
-(void)setRegion:(OSCoordinateRegion)region animated:(BOOL)animated;

- (OSGridRect)gridRectThatFits:(OSGridRect)gridRect;
- (OSGridRect)gridRectThatFits:(OSGridRect)gridRect edgePadding:(UIEdgeInsets)insets;
- (OSCoordinateRegion)regionThatFits:(OSCoordinateRegion)region;


/// ---------------------------------
/// @name Managing maps
/// ---------------------------------

/// Sets the products to display by product code.
/// @param mapProductCodes The array of product codes. Does not need to be sorted.
-(void)setMapProductCodes:(NSArray*)mapProductCodes;

/// @name User location

-(void)setUserTrackingMode:(OSUserTrackingMode)userTrackingMode animated:(BOOL)animated;

/// ---------------------------------
/// @name Managing annotations
/// ---------------------------------

// Annotations are models used to annotate coordinates on the map.
// Implement mapView:viewForAnnotation: on OSMapViewDelegate to return the annotation view for each annotation.
- (void)addAnnotation:(id <OSAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id <OSAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

- (NSSet*)annotationsInGridRect:(OSGridRect)gridRect;

- (OSAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;

// We currently only handle selecting one annotation at a time...
- (void)selectAnnotation:(id < OSAnnotation >)annotation animated:(BOOL)animated;
- (void)deselectAnnotation:(id < OSAnnotation >)annotation animated:(BOOL)animated;
- (OSAnnotationView*)viewForAnnotation:(id<OSAnnotation>)annotation;

/// ---------------------------------
/// @name Managing overlays
/// ---------------------------------

- (void)addOverlay:(id<OSOverlay>)overlay;
- (void)addOverlays:(NSArray *)overlays;
- (void)removeOverlay:(id<OSOverlay>)overlay;
- (void)removeOverlays:(NSArray *)overlays;
- (void)insertOverlay:(id<OSOverlay>)overlay atIndex:(NSUInteger)index;
- (void)exchangeOverlayAtIndex:(NSUInteger)index1 withOverlayAtIndex:(NSUInteger)index2;
- (void)insertOverlay:(id<OSOverlay>)overlay aboveOverlay:(id <OSOverlay>)overlay2;
- (void)insertOverlay:(id<OSOverlay>)overlay belowOverlay:(id <OSOverlay>)overlay2;
- (OSOverlayView *)viewForOverlay:(id<OSOverlay>)overlay;

/// ---------------------------------
/// @name Converting between coordinate systems
/// ---------------------------------


- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;

-(CGPoint)convertGridPoint:(OSGridPoint)gp toPointToView:(UIView *)view;
-(OSGridPoint)convertPoint:(CGPoint)point toGridPointFromView:(UIView *)view;
-(CGRect)convertRegion:(OSCoordinateRegion)region toRectToView:(UIView*)view;

@end

@interface OSMapView(TileSources)

/// @name Creating and using tile sources

/** Creates a tile source which loads images off the OpenSpace or OpenSpace Pro tile servers.

@param apiKey    Your OpenSpace or OpenSpace Pro API key

@param isPro    `true` if the API key is an OpenSpace Pro API key, `false` otherwise.
*/
+(id<OSTileSource>)webTileSourceWithAPIKey:(NSString*)apiKey openSpacePro:(bool)isPro;

/**
Creates a tile source which loads tiles from a local SQLite database.

The file should be in the "OSTiles" format and have extension `.ostiles`.

@param fileURL  The URL of the file to load. Must be a file URL.

@return  The tile source, or `nil` if an error occurs.
*/
+(id<OSTileSource>)localTileSourceWithFileURL:(NSURL*)fileURL;

/**
Calls +localTileSourceWithFileURL: on all files in a directory and returns an array of the non-nil results.
*/
+(NSArray*)localTileSourcesInDirectoryAtURL:(NSURL*)directoryURL;

@end

@interface OSMapView(ProductCodes)

/// @name Managing maps

/**
** The default OpenSpace map stack, taken from
** http://www.ordnancesurvey.co.uk/oswebsite/support/web-services/about-os-openspace-layers-and-services.html
**
** Does not include VectorMap District.
*/
+(NSArray*)defaultMapStackProductCodes;

/**
** The complete OpenSpace (free) map stack, taken from
** http://www.ordnancesurvey.co.uk/oswebsite/support/web-services/about-os-openspace-layers-and-services.html
**
** Identical to +defaultFreeMapStack plus VectorMap District.
*/
+(NSArray*)completeFreeMapStackProductCodes;

/**
** The OpenSpace Pro zoom map stack.
*/
+(NSArray*)zoomMapStackProductCodes;

@end

@interface OSMapView(Version)

/// @name Versioning

/// Returns the current SDK version number as a string, e.g. "1.0".
+(NSString*)SDKVersion;

@end

/**
`OSMapViewDelegate` does not currently support "map loading" callbacks:

    - (void)mapViewWillStartLoadingMap:(OSMapView *)mapView;
    - (void)mapViewDidFinishLoadingMap:(OSMapView *)mapView;
    - (void)mapViewDidFailLoadingMap:(OSMapView *)mapView withError:(NSError *)error;
*/
@protocol OSMapViewDelegate <NSObject>
@optional
- (OSAnnotationView *)mapView:(OSMapView *)mapView viewForAnnotation:(id <OSAnnotation>)annotation;
- (void)mapView:(OSMapView *)mapView didAddAnnotationViews:(NSArray *)views;
- (void)mapView:(OSMapView *)mapView annotationView:(OSAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
- (void)mapView:(OSMapView *)mapView didSelectAnnotationView:(OSAnnotationView*)view;
- (void)mapView:(OSMapView *)mapView didDeselectAnnotationView:(OSAnnotationView*)view;
- (void)mapView:(OSMapView *)mapView annotationView:(OSAnnotationView *)annotationView didChangeDragState:(OSAnnotationViewDragState)newState fromOldState:(OSAnnotationViewDragState)oldState;

- (OSOverlayView *)mapView:(OSMapView *)mapView viewForOverlay:(id <OSOverlay>)overlay;
- (void)mapView:(OSMapView *)mapView didAddOverlayViews:(NSArray *)views;

- (void)mapView:(OSMapView *)map regionWillChangeAnimated:(BOOL)animated;

/** Notification of intermediate changes to position/scale. This function is called before annotations/overlays
    are updated, to allow the application to make any necessary changes.
    
    IMPORTANT this function is called often, in the main thread. The application should ensure that it has an 
    efficient implementation. Any computationally expensive work should be done in a separate thread.
 */
- (void)mapView:(OSMapView *)map regionChangeAnimated:(BOOL)animated;
- (void)mapView:(OSMapView *)map regionDidChangeAnimated:(BOOL)animated;

- (void)mapViewWillStartLocatingUser:(OSMapView *)mapView;
- (void)mapViewDidStopLocatingUser:(OSMapView *)mapView;
- (void)mapView:(OSMapView *)mapView didUpdateUserLocation:(OSUserLocation *)userLocation;
- (void)mapView:(OSMapView *)mapView didFailToLocateUserWithError:(NSError*)error;
- (void)mapView:(OSMapView *)mapView didChangeUserTrackingMode:(OSUserTrackingMode)mode animated:(BOOL)animated;

// Unsupported callbacks:
//- (void)mapViewWillStartLoadingMap:(OSMapView *)mapView __attribute__((deprecated("Not supported yet - OSMapView does not call this method")));
//- (void)mapViewDidFinishLoadingMap:(OSMapView *)mapView __attribute__((deprecated("Not supported yet - OSMapView does not call this method")));
//- (void)mapViewDidFailLoadingMap:(OSMapView *)mapView withError:(NSError *)error __attribute__((deprecated("Not supported yet - OSMapView does not call this method")));

@end
