/*
*   Filename:         NUFrameworkDataViewsLoader.j
*   Created:          Mon Apr 20 18:58:58 PDT 2015
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
@import "NUAbstractDataViewsLoader.j"
@import "NUCategoryDataView.j"
@import "NUMessageDataView.j"

@implementation NUInternalDataViewsLoader : NUAbstractDataViewsLoader
{
    @outlet CPPopover           popoverConfirmation     @accessors(readonly);
    @outlet CPView              viewInvalidInput        @accessors(readonly);
    @outlet NUCategoryDataView  categoryDataView        @accessors(readonly);
    @outlet NUMessageDataView   messageDataView         @accessors(readonly);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[[[popoverConfirmation contentViewController] view] subviewWithTag:@"confirm"] setBGColor:@"red"];
    [viewInvalidInput setBackgroundColor:NUSkinColorOrange];
}

@end
