/*
*   Filename:         CPTheme+Setters.j
*   Created:          Fri Jun 28 11:37:56 PDT 2013
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

@import <AppKit/CPTheme.j>


@implementation CPTheme (Setters)

- (id)setValue:(id)aValue forAttributeWithName:(CPString)aName forClass:(id)aClass
{
    return [self setValue:aValue forAttributeWithName:aName inState:CPThemeStateNormal forClass:aClass];
}

- (id)setValue:(id)aValue forAttributeWithName:(CPString)aName inState:(CPThemeState)aState forClass:(id)aClass
{
    var attribute = [self attributeWithName:aName forClass:aClass];

    if (!attribute)
        return nil;

    [attribute setValue:aValue forState:aState];
}

@end
