/*
* Copyright (c) 2016, Alcatel-Lucent Inc
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the copyright holder nor the names of its contributors
*       may be used to endorse or promote products derived from this software without
*       specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

@import <Foundation/Foundation.j>
@import <AppKit/CPView.j>
@import <AppKit/CPViewAnimation.j>

@import "NUSkin.j"


var NUDataTransferControllerSingleton = nil;


/*! NUDataTransferController provide API to show a loading spinner
    on any view.
*/
@implementation NUDataTransferController : CPObject
{
    @outlet CPView      fetchingViewPrototype;

    CPDictionary        _timerRegistry;
    CPViewAnimation     _animFadeOut;
}

/*! Gets the default NUDataTransferController
*/
+ (NUDataTransferControllerSingleton)defaultDataTransferController
{
    if (!NUDataTransferControllerSingleton)
        [[NUDataTransferController alloc] init];

    return NUDataTransferControllerSingleton;
}

/*! Initialize the NUDataTransferController
*/
- (id)init
{
    if (NUDataTransferControllerSingleton != nil)
        return NUDataTransferControllerSingleton;

    if (self = [super init])
    {
        [fetchingViewPrototype setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];

        NUDataTransferControllerSingleton = self;
        _timerRegistry = @{};
    }

    return self;
}

/*! Show a loading view on the given view
*/
- (void)showFetchingViewOnView:(CPView)aView
{
    [self showFetchingViewOnView:aView zoom:1];
}

/*! Show a loading view on the given view, with a zoom factor.
*/
- (void)showFetchingViewOnView:(CPView)aView zoom:(int)aZoomFactor
{
    [self hideFetchingViewFromView:aView];

    var timer = [CPTimer scheduledTimerWithTimeInterval:0.4
                                                 target:self
                                               selector:@selector(_performShowFetchingView:)
                                               userInfo:[aView, aZoomFactor]
                                                repeats:NO];

    [_timerRegistry setObject:timer forKey:[aView UID]];

}

/*! @ignore
*/
- (void)_performShowFetchingView:(CPTimer)aTimer
{
    var view       = [fetchingViewPrototype duplicate],
        targetView = [aTimer userInfo][0],
        zoom       = [aTimer userInfo][1],
        size       = [view frameSize],
        frame      = CGRectMakeCopy([targetView frame]),
        adjust     = zoom == 1 ? 0 : 1;

    [view subviews][0]._DOMElement.className = "three-quarters";

    frame.origin.x    = frame.size.width / 2 - (size.width * zoom / 2 + adjust);
    frame.origin.y    = frame.size.height / 2 - (size.height * zoom / 2 + adjust);
    frame.size        = size;

    [view setFrame:frame];
    [view setScaleSize:CGSizeMake(zoom, zoom)];

    [targetView addSubview:view positioned:CPWindowAbove relativeTo:nil];

    [_timerRegistry removeObjectForKey:[targetView UID]];

    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

/*! Removes the loading view from the given view
*/
- (void)hideFetchingViewFromView:(CPView)aView
{
    if ([_timerRegistry containsKey:[aView UID]])
    {
        [[_timerRegistry objectForKey:[aView UID]] invalidate];
        [_timerRegistry removeObjectForKey:[aView UID]];
    }

    [[aView subviewWithTag:@"fetcherImageProto"] removeFromSuperview];
}

@end
