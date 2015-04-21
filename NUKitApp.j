/*
*   Filename:         NUKitApp.j
*   Created:          Mon Apr 20 21:39:49 PDT 2015
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
@import @"NUServerFaultWindowController.j"
@import @"NULoginWindowController.j"
@import @"NUMessagesWindowController.j"

NUKitUserLoggedOutNotification = @"NUKitUserLoggedOutNotification";

var NUKitDefaultKit;

@implementation NUKit : CPObject
{
    CPBundle                        _bundle                         @accessors(getter=bundle);
    CPString                        _copyright                      @accessors(property=copyright);
    id                              _RESTUser                       @accessors(property=RESTUser);
    NULoginWindowController         _loginWindowController          @accessors(getter=loginWindowController);
    NUMessagesWindowController      _messagesWindowController       @accessors(getter=messagesWindowController);
    NUServerFaultWindowController   _serverFaultWindowController    @accessors(getter=serverFaultWindowController);

    CPArray                         _externalWindows;
    CPPopover                       _lockedPopover;
    CPView                          _lockedPopoverView;
}

+ (NUKit)kit
{
    if (!NUKitDefaultKit)
        NUKitDefaultKit = [NUKit new];

    return NUKitDefaultKit;
}

- (id)init
{
    if (self = [super init])
    {
        _bundle                      = [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]
        _externalWindows             = [];
        _loginWindowController       = [NULoginWindowController new];
        _messagesWindowController    = [NUMessagesWindowController new];
        _serverFaultWindowController = [NUServerFaultWindowController new];

        _lockedPopover = [[CPView alloc] init];
        [_lockedPopover setBackgroundColor:NUSkinColorWhite];
        [_lockedPopover setAlphaValue:0.5];
        [_lockedPopover setInAnimation:@"fadeInHalf" duration:0.5];
        [_lockedPopover setOutAnimation:@"fadeOutHalf" duration:0.5];
    }

    return self;
}

#pragma mark -
#pragma mark Helpers

- (void)sendLogOutNotification
{
    [[CPNotificationCenter defaultCenter] postNotificationName:NUKitUserLoggedOutNotification object:self];
}

- (void)loadFrameworkDataViews
{
    [[[NUInternalDataViewsLoader alloc] initWithCibName:@"DataViews" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]] load];
}


#pragma mark -
#pragma mark External Platform Windows Mamagement

- (void)registerExternalWindow:(CPPlatformWindow)aWindow
{
    if (![_externalWindows containsObject:aWindow])
        [_externalWindows addObject:aWindow];
}

- (void)unregisterExternalWindow:(CPPlatformWindow)aWindow
{
    if ([_externalWindows containsObject:aWindow])
        [_externalWindows removeObject:aWindow];
}

- (void)closeExternalWindows
{
    var windows = [_externalWindows copy];

    for (var i = [windows count] - 1; i >= 0; i--)
        [windows[i] orderOut:nil];

/*    [NUInspectorWindowController flushInspectorRegistry];*/
}


#pragma mark -
#pragma mark Popover Locking

- (void)lockCurrentPopover
{
    var latestWindow = [[CPApp windows] lastObject];

    if ([latestWindow className] == _CPPopoverWindow)
    {
        _lockedPopover = latestWindow._delegate;

        if ([_lockedPopover behavior] == CPPopoverBehaviorTransient)
        {
            [_lockedPopover setBehavior:CPPopoverBehaviorApplicationDefined];

            var contentView = [[_lockedPopover contentViewController] view];
            [_lockedPopover setFrame:[contentView bounds]];

            [contentView addSubview:_lockedPopover];
        }
        else
            _lockedPopover = nil;
    }
}

- (void)unlockCurrentPopover
{
    if (_lockedPopover)
    {
        [_lockedPopover removeFromSuperview];
        [_lockedPopover setBehavior:CPPopoverBehaviorTransient];
    }
}

@end
