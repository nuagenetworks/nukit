/*
*   Filename:         NUTabViewItemPrototype.j
*   Created:          Tue Jun 25 14:06:43 PDT 2013
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
@import <TNKit/TNTabView.j>

@import "NUSkin.j"
@import "NUUtilities.j"


@implementation NUTabViewItemPrototype : TNTabItemPrototype

+ (float)margin
{
    return 40.0;
}

- (void)setTabViewItem:(CPTabViewItem)anItem
{
    if (!anItem)
        return;

    _cucappID(self._button, anItem._cucappID);

    [super setTabViewItem:anItem];
}

@end



@implementation NUImageTabViewItemPrototype : TNTabItemPrototype
{
    CPImage _image;
    CPImage _imageHighlighted;
    CPImage _imageSelected;
}

#pragma mark -
#pragma mark Class Methods

+ (TNTabItemPrototype)new
{
    return [[self alloc] initWithFrame:CGRectMake(0.0, 0.0, [self size].width, [self size].height)];
}

+ (BOOL)isImage
{
    return YES;
}

+ (CGSize)size
{
    return CGSizeMake(16, 16);
}

+ (float)margin
{
    return 20.0;
}

- (void)prepareTheme
{
    [super prepareTheme];
    [_button setButtonType:CPMomentaryChangeButton];
}

- (void)setTabViewItem:(CPTabViewItem)anItem
{
    if (!anItem)
        return;

    _image = anItem._icon;
    _imageHighlighted = anItem._iconHighlighted;
    _imageSelected = anItem._iconSelected;

    [_button setToolTip:anItem._tooltip]
    [_button setValue:_image forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_button setValue:_imageHighlighted forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    _cucappID(_button, anItem._cucappID);

    _tabViewItem = anItem;
}

- (BOOL)setThemeState:(ThemeState)aThemeState
{
    if (aThemeState && aThemeState.isa && [aThemeState isKindOfClass:CPArray])
        aThemeState = CPThemeState.apply(null, aThemeState);

    if (aThemeState.hasThemeState(TNTabItemPrototypeThemeStateSelected))
        [_button setValue:_imageSelected forThemeAttribute:@"image" inState:CPThemeStateNormal];

    [_button setThemeState:aThemeState];

    return YES;
}

/*! used to unset theme state of subviews
    @param aThemeState the theme state
*/
- (BOOL)unsetThemeState:(ThemeState)aThemeState
{
    if (aThemeState && aThemeState.isa && [aThemeState isKindOfClass:CPArray])
        aThemeState = CPThemeState.apply(null, aThemeState);

    if (aThemeState.hasThemeState(TNTabItemPrototypeThemeStateSelected))
        [_button setValue:_image forThemeAttribute:@"image" inState:CPThemeStateNormal];

    [_button unsetThemeState:aThemeState];

    return YES;
}

@end
