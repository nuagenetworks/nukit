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

@implementation NUDataTransferController : CPObject
{
    @outlet CPView      fetchingViewPrototype;

    CPDictionary        _timerRegistry;
    CPViewAnimation     _animFadeOut;
}

+ (NUDataTransferControllerSingleton)defaultDataTransferController
{
    if (!NUDataTransferControllerSingleton)
        [[NUDataTransferController alloc] init];

    return NUDataTransferControllerSingleton;
}

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

- (void)showFetchingViewOnView:(CPView)aView
{
    [self showFetchingViewOnView:aView zoom:1];
}

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

- (void)hideFetchingViewFromView:(CPView)aView
{
    if ([_timerRegistry containsKey:[aView UID]])
    {
        [[_timerRegistry objectForKey:[aView UID]] invalidate];
        [_timerRegistry removeObjectForKey:[aView UID]];
    }

    [[aView subviewWithTag:@"fetcherImageProto"] removeFromSuperview];
}

- (void)showApplicationLogging
{
    var loadingElement = document.createElement("div");
    loadingElement.id = "temp-loading";
    loadingElement.style.color = [NUSkinColorWhite cssString];
    loadingElement.style.position = @"absolute";
    loadingElement.style.top = @"50%";
    loadingElement.style.width = @"100%";
    loadingElement.style.height = @"100px";
    loadingElement.style.textAlign = "center";
    loadingElement.style.zIndex = "-1000";
    loadingElement.style.fontFamily = "Arial";
    loadingElement.style.WebkitAnimationName = "scaleIn";
    loadingElement.style.WebkitAnimationDuration = "1s";
    loadingElement.style.WebkitBackfaceVisibility = "hidden";
    loadingElement.style.animationName = "scaleIn";
    loadingElement.style.animationDuration = "1s";
    loadingElement.style.backfaceVisibility = "hidden";
    loadingElement.style.MozAnimationName = "scaleIn";
    loadingElement.style.MozAnimationDuration = "1s";
    loadingElement.style.MozBackfaceVisibility = "hidden";
    loadingElement.style.textShadow = "none";
    loadingElement.style.backgroundImage = "url(Resources/icon-happy.png)";
    loadingElement.style.backgroundRepeat = "no-repeat";
    loadingElement.style.backgroundPosition = "center center";

    document.getElementById("cappuccino-body").appendChild(loadingElement);
}

- (void)hideApplicationLogging
{
    var loadingElement = document.getElementById("temp-loading");
    if (loadingElement)
        document.getElementById("cappuccino-body").removeChild(loadingElement);
}

@end
