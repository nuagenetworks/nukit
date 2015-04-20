/*
*   Filename:         NUTemplatableObjectDataView.j
*   Created:          Wed Apr 16 11:32:18 PDT 2014
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
@import <NUKit/NUAbstractDataView.j>


@implementation NUTemplatableObjectDataView : NUAbstractDataView
{
    @outlet CPImageView     imageViewIcon;
    @outlet CPView          viewTemplate;

    BOOL                    _fixedBackgroundColor    @accessors(property=fixedBackgroundColor);
}


#pragma mark -
#pragma mark Data View Protocol

- (void)bindDataView
{
    [super bindDataView];

    if (imageViewIcon)
        [imageViewIcon setImage:[self objectValueisTemplate] ? [self templateIcon] : [self instanceIcon]]

    [self _updateBackground];
}

- (void)_updateBackground
{
    if ([self objectValueIsFromTemplate])
    {
        [viewTemplate setHidden:NO];
        if (![self hasThemeState:CPThemeStateSelectedDataView] && !_fixedBackgroundColor)
            [self setBackgroundColor:NUSkinColorGreyLight];
    }
    else
    {
        [viewTemplate setHidden:YES];

        if (!_fixedBackgroundColor)
            [self setBackgroundColor:nil];
    }
}

- (void)resetBackgroundColor
{
    [self _updateBackground];
}

- (BOOL)objectValueIsFromTemplate
{
    return [_objectValue isFromTemplate];
}

- (BOOL)objectValueisTemplate
{
    return [_objectValue isTemplate];
}

- (CPImage)templateIcon
{
    return nil;
}

- (CPImage)instanceIcon
{
    return nil;
}


#pragma mark -
#pragma mark Overrides

- (BOOL)setThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if ([self hasThemeState:aThemeState])
        return;

    [super setThemeState:aThemeState];

    if (aThemeState.hasThemeState(CPThemeStateSelectedDataView))
        [self setBackgroundColor:nil];
}

- (BOOL)unsetThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if (![self hasThemeState:aThemeState])
        return;

    [super unsetThemeState:aThemeState];

    if (aThemeState.hasThemeState(CPThemeStateSelectedDataView))
        [self _updateBackground];
}


#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        imageViewIcon         = [aCoder decodeObjectForKey:@"imageViewIcon"];
        viewTemplate          = [aCoder decodeObjectForKey:@"viewTemplate"];
        _fixedBackgroundColor = [aCoder decodeBoolForKey:@"_fixedBackgroundColor"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeBool:_fixedBackgroundColor forKey:@"_fixedBackgroundColor"];
    [aCoder encodeObject:imageViewIcon forKey:@"imageViewIcon"];
    [aCoder encodeObject:viewTemplate forKey:@"viewTemplate"];
}

@end
