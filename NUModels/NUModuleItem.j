/*
*   Filename:         NUModuleItem.j
*   Created:          Fri May  1 13:03:19 PDT 2015
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

@class NUModule


@implementation NUModuleItem : CPObject
{
    NUModule    _module     @accessors(property=module);
    CPArray     _children   @accessors(property=children);
    BOOL        _separator  @accessors(getter=isSeparator, setter=setSeperator:);
}

+ (NUModuleItem)moduleItemSeparator
{
    var item = [NUModuleItem new];
    [item setSeperator:YES];
    return item;
}

+ (NUModuleItem)moduleItemWithModule:(NUModule)aModule
{
    var item = [NUModuleItem new];
    [item setModule:aModule];
    return item;
}

- (id)init
{
    if (self = [super init])
    {
        _children = [];
    }
    return self;
}

@end