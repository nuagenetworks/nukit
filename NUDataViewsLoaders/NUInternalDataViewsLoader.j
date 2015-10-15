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
@import "NUGenealogyDataView.j"
@import "NUItemizedModuleDataView.j"
@import "NULibraryItemDataView.j"
@import "NUMessageDataView.j"
@import "NUNetworkTextFieldDataView.j"


@implementation NUInternalDataViewsLoader : NUAbstractDataViewsLoader
{
    @outlet CPPopover                   popoverConfirmation         @accessors(readonly);
    @outlet CPView                      viewInvalidInput            @accessors(readonly);
    @outlet NUCategoryDataView          categoryDataView            @accessors(readonly);
    @outlet NUGenealogyDataView         genealogyDataView           @accessors(readonly);
    @outlet NUItemizedModuleDataView    itemizedModuleDataView      @accessors(readonly);
    @outlet NULibraryItemDataView       libraryItemDataView         @accessors(readonly);
    @outlet NUMessageDataView           messageDataView             @accessors(readonly);
    @outlet NUNetworkTextFieldDataView  networkTextFieldDataView    @accessors(readonly);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [popoverConfirmation setAppearance:CPPopoverAppearanceHUD];
    [[[[popoverConfirmation contentViewController] view] subviewWithTag:@"confirm"] setBGColor:@"red"];
    [viewInvalidInput setBackgroundColor:NUSkinColorOrange];
}

@end
