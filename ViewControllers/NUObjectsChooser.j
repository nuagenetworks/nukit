/*
*   Filename:         NUObjectsChooser.j
*   Created:          Tue Oct  9 11:54:27 PDT 2012
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
@import <TNKit/TNTableViewDataSource.j>
@import "NUModule.j"
@import "NUAdvancedFilteringViewController.j"


@implementation NUObjectsChooser : NUModule
{
    @outlet CPButton        buttonSelect;
    @outlet CPPopUpButton   buttonAdditionalInfo;

    BOOL                    _hidesDataViewsControls     @accessors(property=hidesDataViewsControls);
    CPArray                 _ignoredObjects             @accessors(property=ignoredObjects);
    CPArray                 _searchableKeyPaths         @accessors(property=searchableKeyPaths);
    CPPredicate             _displayFilter              @accessors(property=displayFilter);
    id                      _userInfo                   @accessors(property=userInfo);
}


#pragma mark -
#pragma mark Initialization

+ (BOOL)automaticSelectionSaving
{
    return NO;
}

+ (BOOL)commitFetchedObjects
{
    return NO;
}


/*! @ignore
    Initialize the table view
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    _hidesDataViewsControls = YES;

    [fieldModuleTitle setTextColor:NUSkinColorWhite];
    [[fieldModuleTitle superview] setBackgroundColor:NUSkinColorBlack];

    _ignoredObjects = [CPArray array];
    [_dataSource setSearchableKeyPaths:_searchableKeyPaths || []];
    [tableView setDoubleAction:@selector(selectCurrentObjects:)];

    _cucappID(tableView, [self className]);
    _cucappID(buttonSelect, @"add_objects");

    [buttonSelect setThemeState:CPThemeStateDefault];
    [buttonSelect setEnabled:NO];

    [buttonAdditionalInfo setHidden:YES];

    [self view]._DOMElement.style.borderRadius = "5px";
}

- (CPArray)configureContextualMenu
{
    return nil;
}


#pragma mark -
#pragma mark Configuration

- (void)setAdditionalInfoItems:(CPArray)someItems
{
    [buttonAdditionalInfo removeAllItems];

    if (!someItems || ![someItems count])
    {
        [buttonAdditionalInfo setHidden:YES];
        return;
    }

    [buttonAdditionalInfo setHidden:NO];
    for (var i = [someItems count] - 1; i >= 0; i--)
        [buttonAdditionalInfo addItem:someItems[i]];
}

- (CPMenuItem)selectedAdditionalInfo
{
    return [buttonAdditionalInfo selectedItem];
}

- (void)setAllowsMultipleSelection:(BOOL)isMultipleSelections
{
    [tableView setAllowsMultipleSelection:isMultipleSelections];
}


#pragma mark -
#pragma mark NUObjectsChooser API

- (void)configureFetcherKeyPath:(CPString)aKeyPath forClass:(Class)aClass
{
    if (![self containsContextWithIdentifier:[aClass RESTName]])
    {
        var context = [[NUModuleContext alloc] initWithName:[aClass RESTName] identifier:[aClass RESTName]];
        [context setFetcherKeyPath:aKeyPath];
        [self registerContext:context forClass:aClass];
    }

    [self setCurrentContextWithIdentifier:[aClass RESTName]];
}

- (void)fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didFetchContent:(CPArray)someContents
{
    [someContents removeObjectsInArray:_ignoredObjects];

    if (_displayFilter)
        someContents = [someContents filteredArrayUsingPredicate:_displayFilter];

    [super fetcher:aFetcher ofObject:anObject didFetchContent:someContents];
}


#pragma mark -
#pragma mark Actions

- (IBAction)selectCurrentObjects:(id)aSender
{
    if ([tableView numberOfSelectedRows] == 0)
        return;

    var selectedObjects = [self currentSelectedObjects];

    if (_delegate && [_delegate respondsToSelector:@selector(didObjectChooser:selectObjects:)])
        [_delegate didObjectChooser:self selectObjects:selectedObjects];

    if (filterField)
        [filterField setStringValue:@""];
}


#pragma mark -
#pragma mark Delegates

- (void)moduleDidSelectObjects:(CPArray)someObject
{
    [super moduleDidSelectObjects:someObject];
    [buttonSelect setEnabled:[someObject count] >= 1];
}

- (void)didShowGettingStartedView:(BOOL)didShow
{
    [buttonSelect setHidden:didShow];
}


#pragma mark -
#pragma mark Overrides

- (void)setCurrentParent:(NUVSDObject)aParent
{
    // we create a copy, so we won't be discarding the real parent objects when we close the popover
    [super setCurrentParent:[aParent duplicate]];
}

- (void)popoverWillShow:(CPPopover)aPopover
{
    [super popoverWillShow:aPopover];
    [buttonSelect setEnabled:NO];
}

- (void)popoverDidClose:(CPPopover)aPopover
{
    [super popoverDidClose:aPopover];

    if ([[self currentSelectedObjects] count])
        return;

    if (_delegate && [_delegate respondsToSelector:@selector(didObjectChooserCancelSelection:)])
        [_delegate didObjectChooserCancelSelection:self];
}


@end