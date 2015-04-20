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

var NUDataViewsControllerDefault,
    NUDataViewsControllerDataViewsRegistry = @{};

@implementation NUDataViewsController : CPViewController
{
    @outlet CPPopover popoverConfirmation   @accessors(readonly);
    @outlet CPView    viewInvalidInput      @accessors(readonly);
}

#pragma mark -
#pragma mark Class Methods

+ (NUDataViewsController)defaultController
{
    if (!NUDataViewsControllerDefault)
         NUDataViewsControllerDefault = [NUDataViewsController new];

    return NUDataViewsControllerDefault;
}

- (void)registerDataView:(NUAsbtractDataView)aDataView forClass:(Class)aClass
{
    [self registerDataView:aDataView forClass:aClass variant:nil];
}

- (void)registerDataView:(NUAsbtractDataView)aDataView forClass:(Class)aClass variant:(CPString)aVariant
{
    var key = aVariant ? aClass.name + "-" + aVariant : aClass.name;

    if (![NUDataViewsControllerDataViewsRegistry containsKey:key])
        [NUDataViewsControllerDataViewsRegistry setObject:aDataView forKey:key];
}

- (void)dataViewForClass:(Class)aClass
{
    return [self dataViewForClass:aClass variant:nil];
}

- (void)dataViewForClass:(Class)aClass variant:(CPString)aVariant
{
    return [NUDataViewsControllerDataViewsRegistry objectForKey:aVariant ? aClass.name + "-" + aVariant : aClass.name];
}

- (void)awakeFromCib
{
    [[[[popoverConfirmation contentViewController] view] subviewWithTag:@"confirm"] setBGColor:@"red"];
    [viewInvalidInput setBackgroundColor:NUSkinColorOrange];
}



@end
