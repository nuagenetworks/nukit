/*
*   Filename:         NUCategory.j
*   Created:          Tue Oct  9 11:50:34 PDT 2012
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


@implementation NUCategory : CPObject
{
    BOOL        _dataSourceFilterShouldIgnore   @accessors(getter=dataSourceFilterShouldIgnore);
    CPArray     _children                       @accessors(property=children);
    CPString    _name                           @accessors(property=name);
}

+ (id)categoryWithName:(CPString)aName
{
    return [[NUCategory alloc] initWithName:aName];
}

- (id)initWithName:(CPString)aName
{
    if (self = [super init])
    {
        _name = aName;
        _children = [];
        _dataSourceFilterShouldIgnore = YES;
    }

    return self;
}

- (CPString)description
{
    return _name;
}

- (id)valueForUndefinedKey:(CPString)aKey
{
    return nil;
}

- (void)sortUsingDescriptors:(CPArray)someDescriptors
{
    [_children sortUsingDescriptors:someDescriptors];
}

@end
