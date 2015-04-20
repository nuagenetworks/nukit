/*
*   Filename:         NUValidation.j
*   Created:          Mon Oct 28 16:55:13 PDT 2013
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


@implementation NUValidation : CPObject
{
    CPDictionary    _descriptions   @accessors(getter=descriptions);
    CPDictionary    _errors         @accessors(getter=errors);
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        _errors         = @{};
        _descriptions   = @{};
    }

    return self;
}


#pragma mark -
#pragma mark Validation State

- (void)flush
{
    _errors = @{};
    _descriptions = @{};
}

- (BOOL)success
{
    return ![[_errors allKeys] count];
}


#pragma mark -
#pragma mark Error Management

- (void)setErrorTitle:(CPString)aTitle description:(CPString)aDescription forProperty:(CPString)aPropertyName
{
    [_errors setObject:aTitle forKey:aPropertyName];
    [_descriptions setObject:aDescription || @"" forKey:aPropertyName];
}

- (void)setErrorTitle:(CPString)aTitle forProperty:(CPString)aPropertyName
{
    [self setErrorTitle:aTitle description:nil forProperty:aPropertyName];
}

- (void)removeErrorForProperty:(CPString)aProperty
{
    if ([_errors containsKey:aProperty])
        [_errors removeObjectForKey:aProperty];

    if ([_descriptions containsKey:aProperty])
        [_descriptions removeObjectForKey:aProperty];
}

@end
