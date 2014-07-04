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

#import <Foundation/Foundation.h>

#import "OSGridPoint.h"

typedef unsigned OSGeocodeType;

enum {
    OSGeocodeTypeGazetteer     = 1<<0,
    OSGeocodeTypePostcode      = 1<<1,
    OSGeocodeTypeGridReference = 1<<2,
    OSGeocodeTypeRoad          = 1<<3,
    OSGeocodeTypeOnlineGazetteer = 1<<4,
    OSGeocodeTypeOnlinePostcode  = 1<<5,

    OSGeocodeTypeCombined = OSGeocodeTypeGazetteer | OSGeocodeTypePostcode | OSGeocodeTypeGridReference,
    OSGeocodeTypeCombined2 = OSGeocodeTypeCombined | OSGeocodeTypeRoad
};

typedef void(^OSGeocoderCompletionHandler)(NSArray *placemarks, NSError *error);

extern NSString * const OSGeocoderErrorDomain;

enum {
  OSGeocoderErrorCancelled = 1,
  OSGeocoderErrorNoResults,

  OSGeocoderErrorNetwork,
};

/**
 OSGeocoder provides an interface to lookup positions based on place names, postcodes, grid references, roads, or any 
 combination thereof.
 
 It operates on either/both an offline database which is provided with the SDK or Ordnance Survey online services

 OSGeocoder is not thread-safe, and is not reentrant. It must only be called from a single thread, and only one geocoding 
 operation can be run at any one time. Clients should use cancelGeocode to cancel online searches, and not issue requests 
 while isGeocoding returns YES.
 
 
 The search always returns a (possibly empty) array of objects derived from OSPlacemark objects. Any matching roads are 
 returned as OSRoad objects.
 
 A search of type OSGeocodeTypeOnlinePostcode or OSGeocodeTypeOnlineGazetteer will use the appropriate Ordnance Survey 
 online service to fetch results. 

 A search of type OSGeocodeTypeGazetteer will return matching place names. These will be ordered by the type of place; 
 Cities will be returned before Towns, and Towns before other features.
 
 A search of type OSGeocodeTypeGridReference will treat the search term as an OS Grid Reference. It will return up to one 
 result. A valid search term consists of two letters as per the [OS National Grid Square convention][https://www.ordnancesurvey.co.uk/oswebsite/gps/information/coordinatesystemsinfo/guidetonationalgrid/page9.html] 
 followed by 0,2,4,6,8 or 10 digits. Invalid search terms (not matching this format, or containing invalid letter 
 sequences) will return no results.
 
 A search of type OSGeocodeTypeRoad will return roads matching the search term. If none are found, then the search term 
 will be split into a road and a location.  If a comma is present in the search term, the split will be made there, 
 otherwise the split is carried out automatically. The search will then return roads near matching locations.
 
 OSGeocoder allows searches to be carried out with a range. The behaviour of this range varies.
 
 A search over multiple types (for example Gazetteer and Road) will search for entries of the specified types that
 match the search string. These results will be ordered by result type.
 
 The range field is honoured for searches of type OSGeocodeTypeGazetteer and OSGeocodeTypeRoad, but ignored for all 
 other types of search. A search combining multiple types will honour the range field where it can, but will apply the 
 range individually to each result set, so a combined search with a range of
        (NSRange){0,100} 
 may return 100 gazetteer entries AND 100 roads.
 */

@interface OSGeocoder : NSObject


/**
 Initialise the Geocoder in offline only mode 
 */
-(id)initWithDatabase:(NSString*)path;

/**
Initialise the OSGeocoder

* If both `path` and `apiKey` are nil, then results will only be returned for `OSGeocodeTypeGridReference`
* If `path` is nil, searches for offline types `OSGeocodeTypeGazetteer`, `OSGeocodeTypePostCode`, and `OSGeocodeTypeRoad` will return no results.
* If `apiKey` is nil, searches for online types `OSGeocodeTypeOnlineGazetteer` and `OSGeocodeTypeOnlinePostCode` will return no results.
 
 @param path location of a database file to use.
 @param apiKey key for online searches.
 @param openSpacePro indicates if online searches should be made against the pro service
 */
-(id)initWithDatabase:(NSString*)path apiKey:(NSString*)key openSpacePro:(bool)pro;


/**
    @param type   type of search to execute
    @param rect  limiting rectangle for search. To search the entire area, specify either OSGridRectNull or OSNationalGridBounds. This parameter is ignored for online searches
    @param range  specifies number (and offset) of results to return. This will be applied individually to each 
        type of search, so a range of {0,100} may return more than 100 results on combined gazetteer/road searches. 
        The range is ignored for postcode and grid reference searches.
 To return ALL results, set range to 
    {NSNotFound, 0}
    @param completionHandler  block to call with the results.
 
    Callbacks for offline searches will be made synchronously, while callbacks for online searches will be made asynchronously on the caller thread. A search which comprises both offline 
    and online types may results in up to two callbacks, one synchronous, and one asynchronous.
 
    If no results are found, completionHandler will be called once (even for combiend offline/online searches) with a non-nil error indicating the problem. 
 
    The completionHandler MUST NOT start a search before returning if the error is OSGeocoderErrorCancelled. 
 */
-(void)geocodeString:(NSString*)s type:(OSGeocodeType)type inBoundingRect:(OSGridRect)rect withRange:(NSRange)range completionHandler:(OSGeocoderCompletionHandler)completionHandler;


/**
 Cancel an existing geocoding operation
 */
-(void)cancelGeocode;

/**
 Indicates whether a geocoding operation is in progress.
*/
@property (nonatomic, assign, readonly, getter=isGeocoding) bool geocoding;
@end


