/*
*   Filename:         NUDataTransferController.j
*   Created:          Tue Oct  9 11:48:52 PDT 2012
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
*
* Copyright (c) 2011-2012 Alcatel, Alcatel-Lucent, Inc. All Rights Reserved.
*
* This source code contains confidential information which is proprietary to Alcatel.
* No part of its contents may be used, copied, disclosed or conveyed to any party
* in any manner whatsoever without prior written permission from Alcatel.
*
* Alcatel-Lucent is a trademark of Alcatel-Lucent, Inc.
*
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
