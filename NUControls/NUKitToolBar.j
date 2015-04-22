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
    @outlet CPView          viewSeparator;
    @outlet CPButton        buttonDCConfig;
    @outlet CPButton        buttonLogout;
    @outlet CPButton        buttonSystemMonitoring;
    @outlet CPButton        buttonUserConfig;
    @outlet CPButton        buttonVSPConfiguration;
    @outlet CPView          viewIconContainer;
    @outlet NUStackView     stackViewButtons;

    CPButton                _buttonLogout;
    CPArray                 _buttons;
    CPView                  _viewIcon;
}


#pragma mark -
#pragma mark Class Methods

+ (void)defaultToolBar
{
    return NUKitToolBarDefault;
}


#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        [self _init];

/*        _viewIcon = [[NUDataViewsRegistry dataViewForName:@"enterpriseIconView"] duplicate];
        [_viewIcon setFrame:[viewIconContainer bounds]];
        [_viewIcon setAutoresizingMask:CPViewWidthSizable];
        [viewIconContainer addSubview:_viewIcon];
*/    }
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

    viewSeparator = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 1, 32)];
    [viewSeparator setBackgroundColor:NUSkinColorGrey];

    NUKitToolBarDefault = self;
}

- (void)awakeFromCib
{
    [stackViewButtons setMode:NUStackViewModeHorizontal];
    [stackViewButtons setMargin:CGInsetMake(0, 5, 0, 5)];
    [self setBackgroundColor:NUSkinColorGreyLight];

    [self setNeedsLayout];
}

- (void)addButton:(CPButton)aButton
{
    [_buttons addObject:aButton];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    var buttonsList = [_buttons copy];

    [buttonsList addObject:viewSeparator];
    [buttonsList addObject:_buttonLogout];

    [stackViewButtons setSubviews:buttonsList];

    var frame          = [self frame],
        stackViewFrame = CGRectMakeCopy([stackViewButtons frame]);

    stackViewFrame.origin.x = frame.size.width - stackViewFrame.size.width - 5;
    [stackViewButtons setFrame:stackViewFrame];
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


#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        stackViewButtons  = [aCoder decodeObjectForKey:@"stackViewButtons"];
        viewIconContainer = [aCoder decodeObjectForKey:@"viewIconContainer"];

        [self _init];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:stackViewButtons forKey:@"stackViewButtons"];
    [aCoder encodeObject:viewIconContainer forKey:@"viewIconContainer"];
}

@end
