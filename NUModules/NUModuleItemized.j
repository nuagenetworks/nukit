/*
* Copyright (c) 2016, Alcatel-Lucent Inc
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the copyright holder nor the names of its contributors
*       may be used to endorse or promote products derived from this software without
*       specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

@import <Foundation/Foundation.j>
@import "NUOutlineViewDataSource.j"
@import "NUItemizedModuleDataView.j"
@import "NUModuleItem.j"
@import "NUModule.j"

@class NUKit

@global CPApp

/*! NUModuleItemized is a module that won't be managing any entity.
    It's used to display a list of submodules in a vertical tool bar.
*/
@implementation NUModuleItemized : NUModule
{
    @outlet CPOutlineView   tableViewItems;
    @outlet CPView          viewControlsContainer;

    CPCheckBox              _checkBoxShowName;
    CPString                _itemsVisibilitySaveKey;
    CPView                  _viewItemGroup;
    NUOutlineViewDataSource _dataSourceModules;
    NUModule                _lastExpandedRootModule;
    CPDictionary            _moduleItemsCache;
}


#pragma mark -
#pragma mark Class Methods

/*! @ignore
*/
+ (BOOL)isTableBasedModule
{
    return NO;
}

/*! @ignore
*/
+ (BOOL)automaticContextManagement
{
    return NO;
}

/*! @ignore
*/
+ (CPNumber)defaultExpandState
{
    return CPOffState;
}

/*! Overrides this to change the color of the bar
*/
+ (CPColor)backgroundColor
{
    return NUSkinColorBlack;
}

/*! Overrides this to change the color of the grouping highlight
*/
+ (CPColor)groupingViewBackgroundColor
{
    return [NUSkinColorWhite colorWithAlphaComponent:0.15];
}

/*! Overrides this to change the color of the header of grouping view background color
*/
+ (CPColor)groupingViewHeaderBackgroundColor
{
    return [NUSkinColorWhite colorWithAlphaComponent:0.05];
}

/*! Overrides this to change the selection color
*/
+ (CPColor)selectionColor
{
    return [CPColor colorWithHexString:@"A6A6A6"];
}

/*! Overrides this to change the item border color
*/
+ (CPColor)itemBorderColor
{
    return NUSkinColorWhite;
}

/*! Overrides this to change the item text color
*/
+ (CPColor)itemTextColor
{
    return NUSkinColorWhite;
}

/*! Overrides this to change the item text color when selected
*/
+ (CPColor)itemSelectedTextColor
{
    return NUSkinColorWhite;
}

/*! Overrides this to change the separator color.
*/
+ (CPColor)separatorColor
{
    return [CPColor colorWithHexString:@"7C7C7C"];
}


#pragma mark -
#pragma mark Initialization

/*! @ignore
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    _moduleItemsCache = @{};

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
    [tableViewItems setAllowsMultipleSelection:NO];
    [tableViewItems setIndentationPerLevel:0];
    [tableViewItems setAutoresizingMask:CPViewHeightSizable];

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

    [viewControlsContainer setBackgroundColor:[[self class] backgroundColor]];

    _checkBoxShowName = [[CPCheckBox alloc] initWithFrame:CGRectMake(25, 4, 20, 15)]
    [_checkBoxShowName setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
    [viewControlsContainer addSubview:_checkBoxShowName];
    [_checkBoxShowName setTarget:self];
    [_checkBoxShowName setAction:@selector(_updateItemTableVisibility:)];
    [_checkBoxShowName setToolTip:@"Show meaning of icons"];

    [[self view] addSubview:viewControlsContainer];

    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-right.png", 25, 25, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-right.png", 25, 25, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateNormal, CPThemeStateHighlighted];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-left.png", 25, 25, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateSelected];
    [_checkBoxShowName setValue:CPImageInBundle(@"arrow-thin-left.png", 25, 25, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateSelected, CPThemeStateHighlighted];


    _itemsVisibilitySaveKey = "NUKitItemizedModuleExpandState_" + [[self class] moduleIdentifier] + @"_" + [[[self parentModule] class] moduleIdentifier];
    [[CPUserDefaults standardUserDefaults] registerDefaults:@{_itemsVisibilitySaveKey: [[self class] defaultExpandState]}];
}


#pragma mark -
#pragma mark NUModule API

/*! @ignore
*/
- (void)moduleDidSetSubModules:(CPArray)someModules
{
    for (var i = 0, c = [someModules count]; i < c; i++)
    {
        var module     = someModules[i],
            moduleItem = [NUModuleItem moduleItemWithModule:module];

        [_moduleItemsCache setObject:moduleItem forKey:[module UID]];
    }
}

/*! @ignore
*/
- (void)moduleDidShow
{
    [super moduleDidShow];

    var tabViewItems = [tabViewContent tabViewItems],
        content      = [self _generateCurrentModuleItemsFromInfo:[self moduleItemizedCurrentItems]];

    [_dataSourceModules setContent:content];
    [tableViewItems reloadData];

    [_checkBoxShowName setState:[[CPUserDefaults standardUserDefaults] objectForKey:_itemsVisibilitySaveKey]];
    [self _updateItemTableVisibility:self];
    [self _showItemTable:([_dataSourceModules count] > 1)];

    if (_lastExpandedRootModule)
        [tableViewItems expandItem:[self _moduleItemForModule:_lastExpandedRootModule]];
    else
        [tableViewItems expandItem:[content firstObject]];
}

/*! @ignore
*/
- (void)moduleDidReload
{
    [super moduleDidReload];

    [self _selectItemizedModule:[[tabViewContent selectedTabViewItem] representedObject]];
}

/*! @ignore
*/
- (CPSet)permittedActionsForObject:(id)anObject
{
    return [CPSet new];
}

/*! @ignore
*/
- (CPResponder)initialFirstResponder
{
    return tableViewItems;
}

/*! @ignore
*/
- (CPArray)currentActiveSubModules
{
    var items   = [_dataSourceModules flattenedContent],
        modules = [];

    for (var i = 0, c = [items count]; i < c; i++)
    {
        if ([items[i] isSeparator])
            continue;

        [modules addObject:[items[i] module]];
    }

    return modules;
}

/*! @ignore
*/
- (void)moduleDidChangeVisibleSubmodule
{
    [tableViewItems setNextKeyView:[[self visibleSubModule] initialFirstResponder]];
}


#pragma mark -
#pragma mark NUModuleItemized API

/*! @ignore
*/
- (CPArray)moduleItemizedCurrentItems
{
    return [];
}


#pragma mark -
#pragma mark Utilities

/*! @ignore
*/
- (void)_showItemTable:(BOOL)shouldShow
{
    if (shouldShow)
        [self _updateItemTableVisibility:self];
    else
        [self _setItemTableWidth:0];
}

/*! @ignore
*/
- (void)_expandItemTable:(BOOL)shouldExpand
{
    [self _setItemTableWidth:shouldExpand ? 250 : 50];
    [tableViewItems setIndentationPerLevel:shouldExpand ? 10 : 0];
}

/*! @ignore
*/
- (void)_setItemTableWidth:(int)aWidth
{
    var scrollView   = [tableViewItems enclosingScrollView],
        mainFrame    = [[self view] bounds],
        tabViewFrame = [tabViewContent frame],
        tableFrame   = CGRectMake(0, 0, aWidth, mainFrame.size.height - [viewControlsContainer frameSize].height);

    tabViewFrame.size.width = mainFrame.size.width - aWidth;
    tabViewFrame.origin.x = aWidth;

    [scrollView setFrame:tableFrame];
    [tabViewContent setFrame:tabViewFrame];

    var frame = [viewControlsContainer frame];
    frame.size.width = aWidth;
    [viewControlsContainer setFrame:frame];
}

/*! @ignore
*/
- (void)_selectItemizedModule:(NUModule)aModule
{
    var indexToSelect = [tableViewItems rowForItem:[self _moduleItemForModule:aModule]];

    if (indexToSelect != CPNotFound)
        [tableViewItems selectRowIndexes:[CPIndexSet indexSetWithIndex:indexToSelect] byExtendingSelection:0];
}

/*! @ignore
*/
- (NUModuleItem)_moduleItemForModule:(NUModule)aModule
{
    return [_moduleItemsCache objectForKey:[aModule UID]];
}

/*! @ignore
*/
- (CPArray)_generateCurrentModuleItemsFromInfo:(id)someInfos
{
    var ret = [];

    for (var i = 0, c = [someInfos count]; i < c; i++)
    {
        var module = someInfos[i]["module"];

        if (module)
        {
            var moduleItem   = [self _moduleItemForModule:module],
                childrenInfo = someInfos[i]["children"];

            [ret addObject:moduleItem];

            if (childrenInfo)
                [moduleItem setChildren:[self _generateCurrentModuleItemsFromInfo:childrenInfo]];
        }
        else
        {
            [ret addObject:[NUModuleItem moduleItemSeparator]];
        }
    }

    return ret;
}

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_continueTableViewItemsSelectionChange:(CPIndexSet)selectionIndexes
{
    _overrideShouldHide = YES;
    [tableViewItems selectRowIndexes:selectionIndexes byExtendingSelection:NO];
    [self _changeSelection:self];
}


#pragma mark -
#pragma mark Actions

/*! @ignore
*/
- (@action)_changeSelection:(id)aSender
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
        _lastExpandedRootModule = nil;
        [tableViewItems collapseAll];
        [self _showGroupingView:NO forItem:nil];
    }

    [tabViewContent selectTabViewItem:tabViewItem];

    if (conditionRootLevel && [[moduleItem children] count])
    {
        _lastExpandedRootModule = [moduleItem module];
        [tableViewItems expandItem:moduleItem];
        [self _showGroupingView:YES forItem:moduleItem];
    }
}

/*! @ignore
*/
- (@action)_updateItemTableVisibility:(id)aSender
{
    [[CPUserDefaults standardUserDefaults] setObject:[_checkBoxShowName state] forKey:_itemsVisibilitySaveKey];
    [self _expandItemTable:([_checkBoxShowName state] == CPOnState)]
}


#pragma mark -
#pragma mark Delegate

/*! @ignore
*/
- (int)outlineView:(CPOutlineView)anOutlineView heightOfRowByItem:(id)anItem
{
    return [anItem isSeparator] ? 10 : 50;
}

/*! @ignore
*/
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

/*! @ignore
*/
- (CPIndexSet)outlineView:(CPOutlineView)anOutlineView selectionIndexesForProposedSelection:(CPIndexSet)proposedIndexes
{
    if ([[tableViewItems itemAtRow:[proposedIndexes firstIndex]] isSeparator])
        return [CPIndexSet new];

    if (![[self visibleSubModule] shouldHide] && !_overrideShouldHide)
    {
        [self _showPendingChangeWithDiscardSelector:@selector(_continueTableViewItemsSelectionChange:) nextSelection:proposedIndexes];
        return [CPIndexSet new];
    }

    return proposedIndexes;
}

/*! @ignore
*/
- (void)outlineViewSelectionDidChange:(CPNotification)aNotification
{
    var character = [[CPApp currentEvent] charactersIgnoringModifiers];

    if (character == CPUpArrowFunctionKey || character == CPDownArrowFunctionKey)
    {
        [[CPRunLoop mainRunLoop] performBlock:function()
        {
            [self _changeSelection:[aNotification object]];
            [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
        } argument:nil order:0 modes:[CPDefaultRunLoopMode]];
    }
}

/*! @ignore
*/
- (BOOL)outlineView:(CPOutlineView)anOutlineView shouldCollapseItem:(id)anItem
{
    return YES;
}

@end
