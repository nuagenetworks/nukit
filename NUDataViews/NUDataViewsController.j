/*
*   Filename:         NUDataViewsController.j
*   Created:          Tue Oct  9 11:54:33 PDT 2012
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
@import <AppKit/CPViewController.j>
@import <AppKit/CPPopover.j>

var NUDataViewsControllerDataViewsRegistry = @{};

@implementation NUDataViewsController : CPViewController
{
}

#pragma mark -
#pragma mark Class Methods

+ (void)registerDataView:(NUAsbtractDataView)aDataView forClass:(Class)aClass
{
    [self registerDataView:aDataView forClass:aClass variant:nil];
}

+ (void)registerDataView:(NUAsbtractDataView)aDataView forName:(CPString)aName
{
    if (![NUDataViewsControllerDataViewsRegistry containsKey:aName])
        [NUDataViewsControllerDataViewsRegistry setObject:aDataView forKey:aName];
}

+ (void)dataViewForName:(CPString)aName
{
    return [NUDataViewsControllerDataViewsRegistry objectForKey:aName];
}

@end
