/*
*   Filename:         NUKitToolBar.j
*   Created:          Mon Apr  7 15:49:22 PDT 2014
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
@import <AppKit/CPControl.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPBox.j>
@import "NUSkin.j"
@import "NUStackView.j"

var NUKitToolBarDefault;

@implementation NUKitToolBar : CPControl
{
    @outlet CPImageView     imageApplicationIcon;
    @outlet CPTextField     fieldApplicationName;
    @outlet NUStackView     stackViewButtons;

    CPView                  _viewSeparator;
    CPButton                _buttonLogout;
    CPArray                 _buttons;
    CPView                  _viewIcon;
    id                      _applicationNameBoundObject;
    CPString                _applicationNameBoundKeyPath;
    id                      _applicationIconBoundObject;
    CPString                _applicationIconBoundKeyPath;

}


#pragma mark -
#pragma mark Class Methods

+ (id)defaultToolBar
{
    return NUKitToolBarDefault;
}


#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
        [self _init];

    return self;
}

- (void)_init
{
    _buttons = [];

    _buttonLogout = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [_buttonLogout setBordered:NO];
    [_buttonLogout setButtonType:CPMomentaryChangeButton];
    [_buttonLogout setValue:CPImageInBundle(@"toolbar-logout.png", 32.0, 32.0) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_buttonLogout setValue:CPImageInBundle(@"toolbar-logout-pressed.png", 32.0, 32.0) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    [_buttonLogout setToolTip:@"Log out from the application"];
    [_buttonLogout setTarget:[NUKit kit]];
    [_buttonLogout setAction:@selector(performLogout)];
    _cucappID(_buttonLogout, @"button-toolbar-logout");

    _viewSeparator = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 1, 32)];
    [_viewSeparator setBackgroundColor:NUSkinColorGrey];

    NUKitToolBarDefault = self;
}

- (void)awakeFromCib
{
    [stackViewButtons setMode:NUStackViewModeHorizontal];
    [stackViewButtons setMargin:CGInsetMake(0, 5, 0, 5)];
    [self setBackgroundColor:NUSkinColorGreyLight];

    [fieldApplicationName setStringValue:[[NUKit kit] companyName]];
    [imageApplicationIcon setImage:[[NUKit kit] companyLogo]];

    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Utilities

- (void)setAdvancedItemsHidden:(BOOL)shouldHide
{
/*    [boxSeparator setHidden:shouldHide];*/
}

- (void)setCurrentEnterprise:(id)anEnterprise
{
    [_viewIcon setObjectValue:anEnterprise];
}

- (void)registerButton:(CPButton)aButton
{
    [_buttons addObject:aButton];
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Application Name and Icon Management

- (void)bindApplicationNameToObject:(id)anObject withKeyPath:(CPString)aKeyPath
{
    [fieldApplicationName unbind:CPValueBinding];

    _applicationNameBoundObject = anObject;
    _applicationNameBoundKeyPath = aKeyPath;

    if (anObject)
        [fieldApplicationName bind:CPValueBinding toObject:anObject withKeyPath:aKeyPath options:nil];
    else
        [fieldApplicationName setStringValue:[[NUKit kit] companyName]];
}

- (void)bindApplicationIconToObject:(id)anObject withKeyPath:(CPString)aKeyPath
{
    [imageApplicationIcon unbind:CPValueBinding];

    _applicationIconBoundObject = anObject;
    _applicationIconBoundKeyPath = aKeyPath;

    if (anObject)
        [imageApplicationIcon bind:CPValueBinding toObject:anObject withKeyPath:aKeyPath options:nil];
    else
        [imageApplicationIcon setImage:[[NUKit kit] companyLogo]];
}

- (void)setTemporaryApplicationName:(CPString)aName
{
    [fieldApplicationName unbind:CPValueBinding];
    [fieldApplicationName setStringValue:aName];
}

- (void)setTemporaryApplicationIcon:(CPString)anIcon
{
    [imageApplicationIcon unbind:CPValueBinding];
    [imageApplicationIcon setImage:anIcon];
}

- (void)resetTemporaryApplicationName
{
    [self bindApplicationNameToObject:_applicationNameBoundObject withKeyPath:_applicationNameBoundKeyPath];
}

- (void)resetTemporaryApplicationIcon
{
    [self bindApplicationIconToObject:_applicationIconBoundObject withKeyPath:_applicationIconBoundKeyPath];
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    var buttonsList = [_buttons copy];

    [buttonsList addObject:_viewSeparator];
    [buttonsList addObject:_buttonLogout];

    [stackViewButtons setSubviews:buttonsList];

    var frame          = [self frame],
        stackViewFrame = CGRectMakeCopy([stackViewButtons frame]);

    stackViewFrame.origin.x = frame.size.width - stackViewFrame.size.width - 5;
    [stackViewButtons setFrame:stackViewFrame];
}


#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldApplicationName = [aCoder decodeObjectForKey:@"fieldApplicationName"];
        imageApplicationIcon = [aCoder decodeObjectForKey:@"imageApplicationIcon"];
        stackViewButtons     = [aCoder decodeObjectForKey:@"stackViewButtons"];

        [self _init];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldApplicationName forKey:@"fieldApplicationName"];
    [aCoder encodeObject:imageApplicationIcon forKey:@"imageApplicationIcon"];
    [aCoder encodeObject:stackViewButtons forKey:@"stackViewButtons"];
}

@end
