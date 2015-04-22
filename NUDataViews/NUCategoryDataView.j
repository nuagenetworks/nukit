/*
*   Filename:         NUCategoryDataView.j
*   Created:          Tue Oct  9 11:55:04 PDT 2012
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
@import <AppKit/CPBox.j>

@import "NUAbstractDataView.j"


@implementation NUCategoryDataView : NUAbstractDataView
{
    @outlet CPTextField     fieldName;
    @outlet CPBox           lineSeparator;
}

#pragma mark -
#pragma mark Data View Protocol

- (void)setObjectValue:(id)aCategory
{
    if (aCategory)
        [fieldName setStringValue:[[aCategory name] uppercaseString]];
}


#pragma mark -
#pragma mark Overrides

- (void)drawRect:(CGRect)aRect
{
}

- (BOOL)setThemeState:(ThemeState)aState
{
}

- (BOOL)unsetThemeState:(ThemeState)aState
{
}


#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldName = [aCoder decodeObjectForKey:@"fieldName"];
        lineSeparator = [aCoder decodeObjectForKey:@"lineSeparator"];

        [fieldName setValue:NUSkinColorBlack forThemeAttribute:@"text-color"];
        [lineSeparator setBorderColor:NUSkinColorGreyLight];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldName forKey:@"fieldName"];
    [aCoder encodeObject:lineSeparator forKey:@"lineSeparator"];
}

@end
