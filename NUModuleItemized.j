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
@import "NUModule.j"

@global CPApp


NUModuleItemizedSeparator = @"NUModuleItemizedSeparator";


@implementation NUModuleItemized : NUModule
{
    @outlet CPTableView     tableViewItems;

    CPArray                 _separatorIndexes @accessors(property=separatorIndexes);

    CPCheckBox              _checkBoxShowName;
    TNTableViewDataSource   _dataSourceModules;

}


#pragma mark -
#pragma mark Initialization

+ (BOOL)isTableBasedModule
{
    return NO;
}

+ (BOOL)automaticContextManagement
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _separatorIndexes = [];

    _dataSourceModules = [[TNTableViewDataSource alloc] init];
    [tableViewItems setIntercellSpacing:CGSizeMakeZero()];
    [tableViewItems setBackgroundColor:NUSkinColorBlack];
    // tableViewItems._DOMElement.style.boxShadow = "inset -5px 0px 10px rgba(0, 0, 0, 0.3)";
    [tableViewItems setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleRegular];
    [tableViewItems setValue:NUSkinColorGreyDark forThemeAttribute:@"selection-color"];

    [_dataSourceModules setTable:tableViewItems];
    [tableViewItems setDataSource:_dataSourceModules];
    [tableViewItems setDelegate:self];
    [tableViewItems setTarget:self];
    [tableViewItems setAction:@selector(changeSelection:)];

    _checkBoxShowName = [[CPCheckBox alloc] initWithFrame:CGRectMake(25, [tableViewItems frameSize].height - 20, 20, 15)]
    [_checkBoxShowName setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
    [tableViewItems addSubview:_checkBoxShowName];
    [_checkBoxShowName setTarget:self];
    [_checkBoxShowName setAction:@selector(changeShowNames:)];
    [_checkBoxShowName setToolTip:@"Show meaning of icons"];

    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-right.png", 25, 25) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-right.png", 25, 25) forThemeAttribute:@"image" inState:CPThemeStateNormal, CPThemeStateHighlighted];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-left.png", 25, 25) forThemeAttribute:@"image" inState:CPThemeStateSelected];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-left.png", 25, 25) forThemeAttribute:@"image" inState:CPThemeStateSelected, CPThemeStateHighlighted];

    [tableView setAllowsEmptySelection:NO];
}

- (CPSet)permittedActionsForObject:(id)anObject
{
    return [CPSet new];
}


#pragma mark -
#pragma mark NUModule API

- (void)moduleDidReload
{
    [super moduleDidReload];

    var tabViewItems = [tabViewContent tabViewItems],
        content = [];

    for (var i = 0, c = [tabViewItems count]; i < c; i++)
        [content addObject:[self _subModuleWithIdentifier:[tabViewItems[i] identifier]]];

    for (var i = 0, c = [_separatorIndexes count]; i < c; i++)
        [content insertObject:NUModuleItemizedSeparator atIndex:_separatorIndexes[i]];

    [_dataSourceModules setContent:content];
    [tableViewItems reloadData];

    [_checkBoxShowName setState:CPOffState];
    [self setItemTableWidth:([content count] > 1 ? 50 : 0)];

    var selectedModule = [[tabViewContent selectedTabViewItem] representedObject];
    [self selectItemizedModule:selectedModule];
}

- (CPResponder)initialFirstResponder
{
    return tableViewItems;
}


#pragma mark -
#pragma mark Utilities

- (void)setItemTableWidth:(int)aWidth
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

- (void)selectItemizedModule:(NUModule)aModule
{
    var indexToSelect = [_dataSourceModules indexOfObject:aModule];

    if (indexToSelect != CPNotFound)
        [tableViewItems selectRowIndexes:[CPIndexSet indexSetWithIndex:indexToSelect] byExtendingSelection:0];
}


#pragma mark -
#pragma mark Actions

- (IBAction)changeSelection:(id)aSender
{
    var index = [tableViewItems selectedRow],
        tabViewItem = [[_dataSourceModules objectAtIndex:index] tabViewItem];

    if ([tabViewContent selectedTabViewItem] != tabViewItem)
        [tabViewContent selectTabViewItem:tabViewItem];
}

- (IBAction)changeShowNames:(id)aSender
{
    if ([_checkBoxShowName state] == CPOnState)
        [self setItemTableWidth:250];
    else
        [self setItemTableWidth:50];
}


#pragma mark -
#pragma mark Delegate

- (int)tableView:(CPTableView)aTableView heightOfRow:(int)aRow
{
    return [_separatorIndexes containsObject:aRow] ? 10 : 50;
}

- (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    var item = [_dataSourceModules objectAtIndex:aRow],
        key  = [item UID],
        view = [aTableView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        if ([_separatorIndexes containsObject:aRow])
            view = [_NUModuleItemizedSeparatorDataView new];
        else
            view = [[[NUDataViewsController defaultController] itemizedModuleInformationDataView] duplicate];

        [view setIdentifier:key];
    }

    return view;
}

- (CPIndexSet)tableView:(CPTableView)aTableView selectionIndexesForProposedSelection:(CPIndexSet)proposedIndexes
{
    if ([_dataSourceModules objectAtIndex:[proposedIndexes firstIndex]] == NUModuleItemizedSeparator)
        return [CPIndexSet new];

    return proposedIndexes;
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    [super tableViewSelectionDidChange:aNotification];

    var character = [[CPApp currentEvent] charactersIgnoringModifiers];

    if (character == CPUpArrowFunctionKey || character == CPDownArrowFunctionKey)
    {
        setTimeout(function(){
            [self changeSelection:[aNotification object]];
        }, 0);
    }
}

@end


@implementation _NUModuleItemizedSeparatorDataView : CPView

+ (id)new
{
    var sep = [[_NUModuleItemizedSeparatorDataView alloc] initWithFrame:CGRectMake(0, 0, 100, 10)],
        line = [[CPView alloc] initWithFrame:CGRectMake(5, 5, 90, 1)];

    [line setBackgroundColor:[CPColor colorWithHexString:@"7C7C7C"]];
    [line setAutoresizingMask:CPViewWidthSizable];
    [sep addSubview:line];

    return sep;
}

- (void)setObjectValue:(id)aValue
{

}

@end
