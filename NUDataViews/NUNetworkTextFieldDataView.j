/*
*   Filename:         NUNetworkTextFieldDataView.j
*   Created:          Mon Sep 28 11:49:34 PDT 2015
*   Author:           Alexandre Wilhelm <alexandre.wilhelm@alcatel-lucent.com>
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

@import "NUAbstractDataView.j"
@import "NUNetworkTextField.j"

@implementation NUNetworkTextFieldDataView : NUAbstractDataView
{
    @outlet NUNetworkTextField  fieldNetwork;

    BOOL _isObservedFirstResponder;
}


#pragma mark -
#pragma mark Data View Protocol

- (void)bindDataView
{
    [super bindDataView];
    [fieldNetwork bind:CPValueBinding toObject:_objectValue withKeyPath:@"self" options:nil];
}

- (void)setObjectValue:(id)anObjectValue
{
    if (!anObjectValue)
        [fieldNetwork setObjectValue:nil];

    [super setObjectValue:anObjectValue]
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Mouse event

- (void)_startObservingFirstResponderForWindow:(CPWindow)aWindow
{
    _isObservedFirstResponder = YES;
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_firstResponderDidChange:) name:_CPWindowDidChangeFirstResponderNotification object:aWindow];
}

- (void)_stopObservingFirstResponderForWindow:(CPWindow)aWindow
{
    _isObservedFirstResponder = NO;
    [[CPNotificationCenter defaultCenter] removeObserver:self name:_CPWindowDidChangeFirstResponderNotification object:aWindow];
}

- (void)viewWillMoveToWindow:(CPWindow)aWindow
{
    [self _stopObservingFirstResponderForWindow:[self window]];
}

- (void)_firstResponderDidChange:(CPNotification)aNotification
{
    [self setNeedsLayout];

    if ([fieldNetwork isFirstResponder])
        return;

    [fieldNetwork setBezeled:NO];
    [fieldNetwork setEnabled:NO];
    [fieldNetwork setSelectable:NO];
    [fieldNetwork setEditable:NO];
}

- (void)mouseDown:(CPEvent)anEvent
{
    var window = [self window];

    if (!_isObservedFirstResponder)
        [self _startObservingFirstResponderForWindow:window];

    if ([anEvent clickCount] == 2 && ![fieldNetwork isFirstResponder])
    {
        [fieldNetwork setSelectable:YES];
        [fieldNetwork setBezeled:YES];
        [fieldNetwork setEnabled:YES];
        [fieldNetwork setEditable:YES];
        fieldNetwork._doubleClick = YES;
        [window makeFirstResponder:fieldNetwork];
        return;
    }

    [super mouseDown:anEvent];
}


#pragma mark -
#pragma mark Override

- (void)layoutSubviews
{
    if ([fieldNetwork isFirstResponder])
    {
        [fieldNetwork setFrameOrigin:CGPointMake(-1, -1)];
    }
    else
    {
        var inset = [fieldNetwork valueForThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];

        if ([fieldNetwork _showPlaceHolder])
            [fieldNetwork setFrameOrigin:CGPointMake(inset.left - 1, inset.top)];
        else
            [fieldNetwork setFrameOrigin:CGPointMake(inset.left - 1, -1)];
    }

    if (![fieldNetwork isFirstResponder] && [self hasThemeState:CPThemeStateSelectedDataView])
    {
        [fieldNetwork setTextColor:[CPColor whiteColor]];
        [fieldNetwork setTextColorSeparator:[CPColor whiteColor]];
    }
    else
    {
        [fieldNetwork setTextColor:[CPColor blackColor]];
        [fieldNetwork setTextColorSeparator:[CPColor blackColor]];
    }
}

#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldNetwork = [aCoder decodeObjectForKey:@"fieldNetwork"];
        [fieldNetwork setMask:NO];
        [fieldNetwork setBezeled:NO];
        [fieldNetwork setEnabled:NO];
        [fieldNetwork setSelectable:NO];
        [fieldNetwork setEditable:NO];
        fieldNetwork._isTableViewNetworktextField = YES;
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldNetwork forKey:@"fieldNetwork"];
}

@end