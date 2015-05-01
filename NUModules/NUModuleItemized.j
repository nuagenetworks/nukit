/*
*   Filename:         NUModuleItemized.j
*   Created:          Tue Oct 14 20:11:03 PDT 2014
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
@import "NUOutlineViewDataSource.j"
@import "NUItemizedModuleDataView.j"
@import "NUModuleItem.j"
@import "NUModule.j"

@class NUKit

@global CPApp


@implementation NUModuleItemized : NUModule
{
    @outlet CPOutlineView   tableViewItems;

    CPArray                 _separatorIndexes @accessors(property=separatorIndexes);

    CPCheckBox              _checkBoxShowName;
    CPString                _itemsVisibilitySaveKey;
    NUOutlineViewDataSource _dataSourceModules;
    CPView                  _viewItemGroup;
}


#pragma mark -
#pragma mark Class Methods

+ (BOOL)isTableBasedModule
{
    return NO;
}

+ (BOOL)automaticContextManagement
{
    return NO;
}

+ (CPNumber)defaultExpandState
{
    return CPOffState;
}

+ (CPColor)backgroundColor
{
    return NUSkinColorBlack;
}

+ (CPColor)groupingViewBackgroundColor
{
    return [NUSkinColorWhite colorWithAlphaComponent:0.1];
}

+ (CPColor)groupingViewHeaderBackgroundColor
{
    return [NUSkinColorWhite colorWithAlphaComponent:0.1];
}

+ (CPColor)selectionColor
{
    return NUSkinColorGreyDark;
}

+ (CPColor)itemBorderColor
{
    return NUSkinColorWhite;
}

+ (CPColor)itemTextColor
{
    return NUSkinColorWhite;
}

+ (CPColor)itemSelectedTextColor
{
    return NUSkinColorBlackDarker;
}

+ (CPColor)separatorColor
{
    return [CPColor colorWithHexString:@"7C7C7C"];
}


#pragma mark -
#pragma mark Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];

    _separatorIndexes = [];

    _dataSourceModules = [[NUOutlineViewDataSource alloc] init];
    [_dataSourceModules setTable:tableViewItems];

    [tableViewItems setIntercellSpacing:CGSizeMakeZero()];
    [tableViewItems setBackgroundColor:[[self class] backgroundColor]];
    [tableViewItems setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleRegular];
    [tableViewItems setValue:[[self class] selectionColor] forThemeAttribute:@"selection-color"];
    [tableViewItems setDataSource:_dataSourceModules];
    [tableViewItems setDelegate:self];
    [tableViewItems setTarget:self];
    [tableViewItems setAction:@selector(_changeSelection:)];
    [tableViewItems setAllowsEmptySelection:NO];
    [tableViewItems setIndentationPerLevel:0];

    var button = [CPButton buttonWithTitle:nil];
    [button setEnabled:NO];
    [button setHidden:YES];
    [tableViewItems setDisclosureControlPrototype:button];


    _viewItemGroup = [[CPView alloc] initWithFrame:CGRectMakeZero(0, 0, 50, 100)];
    [_viewItemGroup setBackgroundColor:[[self class] groupingViewBackgroundColor]];
    [_viewItemGroup setAutoresizingMask:CPViewWidthSizable];
    var headerView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [headerView setAutoresizingMask:CPViewWidthSizable];
    [headerView setBackgroundColor:[[self class] groupingViewHeaderBackgroundColor]];
    [_viewItemGroup addSubview:headerView];


    _checkBoxShowName = [[CPCheckBox alloc] initWithFrame:CGRectMake(25, [tableViewItems frameSize].height - 20, 20, 15)]
    [_checkBoxShowName setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
    [tableViewItems addSubview:_checkBoxShowName];
    [_checkBoxShowName setTarget:self];
    [_checkBoxShowName setAction:@selector(_updateItemTableVisibility:)];
    [_checkBoxShowName setToolTip:@"Show meaning of icons"];

    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-right.png", 25, 25, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-right.png", 25, 25, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateNormal, CPThemeStateHighlighted];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-left.png", 25, 25, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateSelected];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-left.png", 25, 25, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateSelected, CPThemeStateHighlighted];


    _itemsVisibilitySaveKey = "NUKitItemizedModuleExpandState_" + [[self class] moduleIdentifier] + @"_" + [[[self parentModule] class] moduleIdentifier];
    [[CPUserDefaults standardUserDefaults] registerDefaults:@{_itemsVisibilitySaveKey: [[self class] defaultExpandState]}];
}


#pragma mark -
#pragma mark NUModule API

- (void)moduleDidShow
{
    [super moduleDidShow];

    var tabViewItems = [tabViewContent tabViewItems],
        content      = [self _generateModuleItemFromInfo:[self moduleItemizedCurrentItems]];

    [_dataSourceModules setContent:content];
    [tableViewItems reloadData];

    var savedDtate = [[CPUserDefaults standardUserDefaults] objectForKey:_itemsVisibilitySaveKey];
    [_checkBoxShowName setState:savedDtate];
    [self _updateItemTableVisibility:self];
}

- (void)moduleDidReload
{
    [super moduleDidReload];

    [self _showItemTable:([_dataSourceModules count] > 0)];
    [self _selectItemizedModule:[[tabViewContent selectedTabViewItem] representedObject]];
}

- (CPSet)permittedActionsForObject:(id)anObject
{
    return [CPSet new];
}

- (CPResponder)initialFirstResponder
{
    return tableViewItems;
}


#pragma mark -
#pragma mark NUModuleItemized API

- (CPArray)moduleItemizedCurrentItems
{
    return [];
}


#pragma mark -
#pragma mark Utilities

- (void)_showItemTable:(BOOL)shouldShow
{
    if (shouldShow)
    {
        [self _updateItemTableVisibility:self];
    }
    else
    {
        [_checkBoxShowName setState:CPOffState];
        [self _setItemTableWidth:0];
    }
}

- (void)_expandItemTable:(BOOL)shouldExpand
{
    if (shouldExpand)
        [self _setItemTableWidth:250];
    else
        [self _setItemTableWidth:50];
}

- (void)_setItemTableWidth:(int)aWidth
{
    var scrollView   = [tableViewItems enclosingScrollView],
        mainFrame    = [[self view] bounds],
        tabViewFrame = [tabViewContent frame],
        tableFrame   = CGRectMake(0, 0, aWidth, mainFrame.size.height);

    tabViewFrame.size.width = mainFrame.size.width - aWidth;
    tabViewFrame.origin.x = aWidth;

    [scrollView setFrame:tableFrame];
    [tabViewContent setFrame:tabViewFrame];
}

- (void)_selectItemizedModule:(NUModule)aModule
{
    var indexToSelect = [tableViewItems rowForItem:[self _moduleItemForModule:aModule]];

    if (indexToSelect != CPNotFound)
        [tableViewItems selectRowIndexes:[CPIndexSet indexSetWithIndex:indexToSelect] byExtendingSelection:0];
}

- (NUModuleItem)_moduleItemForModule:(NUModule)aModule
{
    return [_dataSourceModules objectMatchingPredicate:[CPPredicate predicateWithFormat:@"module.UID == %@", [aModule UID]]];
}

- (CPArray)_generateModuleItemFromInfo:(id)someInfos
{
    var module = someInfos["module"],
        ret = [];

    for (var i = 0, c = [someInfos count]; i < c; i++)
    {
        var module = someInfos[i]["module"];

        if (module)
        {
            var moduleItem   = [NUModuleItem moduleItemWithModule:module],
                childrenInfo = someInfos[i]["children"];

            [ret addObject:moduleItem];

            if (childrenInfo)
                [moduleItem setChildren:[self _generateModuleItemFromInfo:childrenInfo]];
        }
        else
        {
            [ret addObject:[NUModuleItem moduleItemSeparator]];
        }
    }

    return ret;
}

- (void)_showGroupingView:(BOOL)shouldShow forItem:(NUModuleItem)aModuleItem
{
    if (!shouldShow)
    {
        [_viewItemGroup removeFromSuperview];
        return;
    }

    var frame = [tableViewItems rectOfRow:[tableViewItems rowForItem:aModuleItem]],
        childrenCount = [[aModuleItem children] count];

    frame.size.width = [tableViewItems frameSize].width;
    frame.size.height += childrenCount * 50;
    [_viewItemGroup setFrame:frame];
    [tableViewItems addSubview:_viewItemGroup positioned:CPWindowBelow relativeTo:nil];
}


#pragma mark -
#pragma mark Actions

- (IBAction)_changeSelection:(id)aSender
{
    var index       = [tableViewItems selectedRow],
        moduleItem  = [tableViewItems itemAtRow:index],
        tabViewItem = [[moduleItem module] tabViewItem];

    if ([tabViewContent selectedTabViewItem] == tabViewItem)
        return

    var conditionRootLevel = [tableViewItems levelForItem:moduleItem] == 0,
        previousItem       = [self _moduleItemForModule:[[tabViewContent selectedTabViewItem] representedObject]];

    if (conditionRootLevel)
    {
        [tableViewItems collapseAll];
        [self _showGroupingView:NO forItem:nil];
    }

    [tabViewContent selectTabViewItem:tabViewItem];

    if (conditionRootLevel && [[moduleItem children] count])
    {
        [tableViewItems expandItem:moduleItem];
        [self _showGroupingView:YES forItem:moduleItem];
    }
}

- (IBAction)_updateItemTableVisibility:(id)aSender
{
    [[CPUserDefaults standardUserDefaults] setObject:[_checkBoxShowName state] forKey:_itemsVisibilitySaveKey];
    [self _expandItemTable:([_checkBoxShowName state] == CPOnState)]
}


#pragma mark -
#pragma mark Delegate

- (int)outlineView:(CPOutlineView)anOutlineView heightOfRowByItem:(id)anItem
{
    return [anItem isSeparator] ? 10 : 50;
}

- (CPView)outlineView:(CPOutlineView)anOutlineView viewForTableColumn:(CPTableColumn)aColumn item:(id)anItem
{
    var key  = [anItem UID],
        view = [anOutlineView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        if ([anItem isSeparator])
            view = [_NUModuleItemizedSeparatorDataView newWithColor:[[self class] separatorColor]];
        else
        {
            view = [[[NUKit kit] registeredDataViewWithIdentifier:@"itemizedModuleDataView"] duplicate];
            [view setIconBorderColor:[[self class] itemBorderColor]];
            [view setTextColor:[[self class] itemTextColor]];
            [view setSelectedTextColor:[[self class] itemSelectedTextColor]];
        }

        [view setIdentifier:key];
    }

    return view;
}

- (CPIndexSet)outlineView:(CPOutlineView)anOutlineView selectionIndexesForProposedSelection:(CPIndexSet)proposedIndexes
{
    if ([[tableViewItems itemAtRow:[proposedIndexes firstIndex]] isSeparator])
        return [CPIndexSet new];

    return proposedIndexes;
}

- (void)outlineViewSelectionDidChange:(CPNotification)aNotification
{
    var character = [[CPApp currentEvent] charactersIgnoringModifiers];

    if (character == CPUpArrowFunctionKey || character == CPDownArrowFunctionKey)
    {
        setTimeout(function(){
            [self _changeSelection:[aNotification object]];
        }, 0);
    }
}

- (BOOL)outlineView:(CPOutlineView)anOutlineView shouldCollapseItem:(id)anItem
{
    return YES;
}

@end