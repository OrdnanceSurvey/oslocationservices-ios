// The Ordnance Survey iOS SDK is protected by © Crown copyright – Ordnance
// Survey 2012. It is subject to licensing terms granted by Ordnance Survey, the
// national mapping agency of Great Britain.
//
// The Ordnance Survey iOS SDK includes the Route-Me library. The Route-Me
// library is copyright (c) 2008-2012, Route-Me Contributors All rights reserved
// (subject to the BSD licence terms as follows):
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer. * Redistributions in binary
//   form must reproduce the above copyright notice, this list of conditions and
//   the following disclaimer in the documentation and/or other materials provided
//   with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// Route-Me depends on the Proj4 Library. [ http://trac.osgeo.org/proj/wiki/WikiStart ]
// Proj4 is copyright (c) 2000, Frank
// Warmerdam / Gerald Evenden Proj4 is subject to the MIT licence as follows:
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <UIKit/UIKit.h>

#import "OSMap/OSGridPoint.h"

@protocol OSOverlay;

/**
 `OSOverlayView` provides the visual representation associated with an OSOverlay.
 
 Subclasses are expected to implement drawGridRect:zoomScale:inContext, but concrete implementations are provided for each of the provided concrete OSOverlay objects.
 */
@interface OSOverlayView : UIView

@property (nonatomic, strong, readonly) id<OSOverlay> overlay;

-(id)initWithOverlay:(id<OSOverlay>)overlay;

/**
    Convert a point in the view's coordinate space into a map point
 
    @param point The point in the view's coordinate space to convert
 */
-(OSGridPoint)gridPointForPoint:(CGPoint)point;

/**
 Convert a rect in the view's coordinate space into a map rect
 
 @param rect The rectangle in the view's coordinate space to convert
 */
-(OSGridRect)gridRectForRect:(CGRect)rect;

/**
 Convert a point on the map to a point in the view's coordinate space 
 
 @param point The point on the map to convert
 */
-(CGPoint)pointForGridPoint:(OSGridPoint)gridPoint;

/**
 Convert a rectangle on the map to a point in the view's coordinate space
 
 @param gridRect The rectangle on the map to convert
 */
-(CGRect)rectForGridRect:(OSGridRect)gridRect;

/**
    @param gridRect area to render
    @param zoomScale measured in metres per pixel
    @param content to render in
 
    The default implementation of this method does nothing. Subclasses should provide their own implementation, which should be thread-safe. Failure to only draw the area requested by gridRect and thereby render outside that rectangle may lead to performance problems.
 */
-(void)drawGridRect:(OSGridRect)gridRect zoomScale:(float)zoomScale inContext:(CGContextRef)context;
-(void)setNeedsDisplayInGridRect:(OSGridRect)gridRect;
@end
