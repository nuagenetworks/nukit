/*
*   Filename:         NUKit.j
*   Created:          Mon Apr 20 16:05:31 PDT 2015
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          VSD - Nuage - Data Center Service Delivery - IPD
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

@import "NUAssociators.j"
@import "NUControls.j"
@import "NUDataSources.j"
@import "NUDataViews.j"
@import "NUModels.j"
@import "NUModules.j"
@import "NURESTFetchers.j"
@import "NUSkins.j"
@import "NUTransformers.j"
@import "NUUtils.j"
@import "NUWindowControllers.j"


var NUKitLoginWindowController,
    NUKitServerFaultWindowController,
    NUKitMessagesWindowController,
    NUKitRESTUserClass,
    NUKitExternalWindows = [],
    NUKitLockedPopover,
    NUKitLockedPopoverView,
    NUKitCopyright;


NUKitUserLoggedOutNotification = @"NUKitUserLoggedOutNotification";


@implementation NUKit : CPObject

+ (CPBundle)bundle
{
    return [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"];
}

+ (void)setCopyright:(CPString)aCopyright
{
    NUKitCopyright = aCopyright;
}

+ (CPSrting)copyright
{
    return NUKitCopyright;
}

+ (void)loadFrameworkDataViews
{
    [[[NUInternalDataViewsLoader alloc] initWithCibName:@"DataViews" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]] load];
}

+ (void)setDefaultRESTUserClass:(Class)aClass
{
    NUKitRESTUserClass = aClass
}

+ (id)defaultRESTUser
{
    return [NUKitRESTUserClass defaultUser];
}

+ (NULoginWindowController)defaultLoginWindowController
{
    if (!NUKitLoginWindowController)
        NUKitLoginWindowController = [NULoginWindowController new];

    return NUKitLoginWindowController;
}

+ (NUServerFaultWindowController)defaultServerFaultWindowController
{
    if (!NUKitServerFaultWindowController)
        NUKitServerFaultWindowController = [NUServerFaultWindowController new];

    return NUKitServerFaultWindowController;
}

+ (NUMessagesWindowController)defaultMessagesWindowController
{
    if (!NUKitMessagesWindowController)
        NUKitMessagesWindowController = [NUMessagesWindowController new];

    return NUKitMessagesWindowController;
}

+ (void)registerExternalWindow:(CPPlatformWindow)aWindow
{
    if (![NUKitExternalWindows containsObject:aWindow])
        [NUKitExternalWindows addObject:aWindow];
}

+ (void)unregisterExternalWindow:(CPPlatformWindow)aWindow
{
    if ([NUKitExternalWindows containsObject:aWindow])
        [NUKitExternalWindows removeObject:aWindow];
}

+ (void)closeExternalWindows
{
    var windows = [NUKitExternalWindows copy];

    for (var i = [windows count] - 1; i >= 0; i--)
        [windows[i] orderOut:nil];

/*    [NUInspectorWindowController flushInspectorRegistry];*/
}

- (void)lockCurrentPopover
{
    if (!NUKitLockedPopover)
    {
        NUKitLockedPopover = [[CPView alloc] init];
        [NUKitLockedPopover setBackgroundColor:NUSkinColorWhite];
        [NUKitLockedPopover setAlphaValue:0.5];
        [NUKitLockedPopover setInAnimation:@"fadeInHalf" duration:0.5];
        [NUKitLockedPopover setOutAnimation:@"fadeOutHalf" duration:0.5];
    }

    var latestWindow = [[CPApp windows] lastObject];

    if ([latestWindow className] == _CPPopoverWindow)
    {
        NUKitLockedPopover = latestWindow._delegate;

        if ([NUKitLockedPopover behavior] == CPPopoverBehaviorTransient)
        {
            [NUKitLockedPopover setBehavior:CPPopoverBehaviorApplicationDefined];

            var contentView = [[NUKitLockedPopover contentViewController] view];
            [NUKitLockedPopover setFrame:[contentView bounds]];

            [contentView addSubview:NUKitLockedPopover];
        }
        else
            NUKitLockedPopover = nil;
    }
}

- (void)unlockCurrentPopover
{
    if (NUKitLockedPopover)
    {
        [NUKitLockedPopover removeFromSuperview];
        [NUKitLockedPopover setBehavior:CPPopoverBehaviorTransient];
    }
}

+ (void)sendLogOutNotification
{
    [[CPNotificationCenter defaultCenter] postNotificationName:NUKitUserLoggedOutNotification object:self];
}
@end
