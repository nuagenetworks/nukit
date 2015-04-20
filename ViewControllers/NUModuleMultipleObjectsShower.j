/*
*   Filename:         NUModuleMultipleObjectsShower.j
*   Created:          Fri Mar 14 14:53:38 PDT 2014
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

@import "NUModule.j"


@implementation NUModuleMultipleObjectsShower : NUModule
{
    CGSize  _defaultSize;
}


#pragma mark -
#pragma mark Initialization

+ (CPString)moduleName
{
    return @"No Name";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _defaultSize = [[self view] frameSize];
}


#pragma mark -
#pragma mark Configuration

- (void)configureWithParentObject:(NUVSDObject)aParent childrenClass:(Class)aChildrenClass fetcherKeyPath:(CPString)aFetcherKeyPath dataView:(CPView)aDataView title:(CPString)aTitle contentSize:(CGSize)aSize
{
    // load view is needed
    [self view];

    if (![_contextRegistry containsKey:aChildrenClass])
    {
        var context = [[NUModuleContext alloc] initWithName:aTitle identifier:[aChildrenClass RESTName]];
        [context setFetcherKeyPath:aFetcherKeyPath];
        [self registerContext:context forClass:aChildrenClass];
    }

    [[self dataViews] setObject:[aDataView duplicate] forKey:aChildrenClass];

    [self setModuleTitle:aTitle];

    [self setModulePopoverBaseSize:aSize || _defaultSize];
}

- (CPSet)permittedActionsForObject:(id)anObject
{
    var permissions = [CPSet new];

    [permissions addObject:NUModuleActionInspect];

    return permissions;
}


#pragma mark -
#pragma mark Overrides

- (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    return [[self _dataViewForObject:[_dataSource objectAtIndex:aRow]] duplicate];
}

@end
