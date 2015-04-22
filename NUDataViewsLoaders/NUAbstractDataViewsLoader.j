/*
*   Filename:         NUAbstractDataViewsLoader.j
*   Created:          Mon Apr 20 18:58:33 PDT 2015
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
@import <AppKit/CPViewController.j>
@import <AppKit/CPPopover.j>

@class NUKit


@implementation NUAbstractDataViewsLoader : CPViewController

- (void)viewDidLoad
{
    var ivars = self.isa.ivar_list;

    for (var i = [ivars count] - 1; i >= 0; i--)
    {
        var ivarName = ivars[i].name;
        [[NUKit kit] registerDataView:[self valueForKey:ivarName] withIdentifier:ivarName];
    }
}

- (void)load
{
    [self view];
}

@end
