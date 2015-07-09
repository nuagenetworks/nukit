/*
*   Filename:         NUModuleSingleObjectShower.j
*   Created:          Wed Apr 16 17:07:21 PDT 2014
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
@import "NUModule.j"

@class NUKit

@global CPApp


@implementation NUModuleSingleObjectShower : NUModule
{
    @outlet CPView      viewContainer;
    @outlet CPButton    buttonOpenInspector;

    CPView              _currentDataView;
    CPView              _targetView;
}


#pragma mark -
#pragma mark Initialization

+ (id)new
{
    var obj = [[self alloc] initWithCibName:@"SingleObjectShower" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]];

    [obj view];

    return obj;
}

+ (CPString)moduleName
{
    return @"No Name";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [buttonOpenInspector setBordered:NO];
    [buttonOpenInspector setButtonType:CPMomentaryChangeButton];
    [buttonOpenInspector setValue:CPImageInBundle("button-view.png", 16.0, 16.0, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [buttonOpenInspector setValue:CPImageInBundle("button-view-pressed.png", 16.0, 16.0, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    _cucappID(buttonOpenInspector, @"button-open-inspector");
}


#pragma mark -
#pragma mark Configuration

- (void)showObject:(id)anObject dataView:(CPView)aDataView view:(id)aView title:(CPString)aTitle
{
    // load view if needed;
    [self view];

    _currentDataView = aDataView;
    _targetView      = aView;

    [_currentDataView setFrameOrigin:CGPointMakeZero()];
    [viewContainer setSubviews:[]];
    [self setModuleTitle:aTitle];
    [anObject fetchAndCallSelector:@selector(_didFetchObject:connection:) ofObject:self];
}

- (void)_didFetchObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (![NURESTConnection handleResponseForConnection:aConnection postErrorMessage:YES])
        return;

    [self setCurrentParent:anObject];
    [_currentDataView setObjectValue:_currentParent];

    var size = [_currentDataView frameSize];
    size.height += 32;

    [viewContainer addSubview:_currentDataView];

    [self setModulePopoverBaseSize:size];
    [self showOnView:_targetView forParentObject:_currentParent];
}


#pragma mark -
#pragma mark Overrides

- (IBAction)openInspector:(id)aSender
{
    [[NUKit kit] openInspectorForObject:_currentParent];
}

- (void)_didReceivePush:(CPNotification)aNotification
{
    var JSONObject = [aNotification userInfo],
        events     = JSONObject.events;

    if (events.length <= 0)
        return;

    for (var i = 0, c = events.length; i < c; i++)
    {
        var eventType  = events[i].type,
            entityType = events[i].entityType,
            entityJSON = events[i].entities[0];

        if (entityJSON.ID != [_currentParent ID])
            break;

        switch (eventType)
        {
            case NUPushEventTypeUpdate:
                [_currentParent objectFromJSON:entityJSON];
                break;

            case NUPushEventTypeRevoke:
            case NUPushEventTypeDelete:
                [_modulePopover close];
                break;
        }
    }
}

@end
