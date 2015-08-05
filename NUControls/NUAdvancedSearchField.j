/*
*   Filename:         NUAdvancedSearchField.j
*   Created:          Tue Oct  8 11:48:12 PDT 2013
*   Author:           Alexandre Wilhelm <alexandre.wilhelm@alcatel-lucent.com>
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
@import <AppKit/CPSearchField.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPTableColumn.j>
@import <AppKit/CPScrollView.j>
@import <AppKit/CPScroller.j>
@import <AppKit/CPPanel.j>

@class _NUAdvancedSearchFieldPanel

@global CPTableColumnAutoresizingMask
@global CPBorderlessWindowMask
@global CPApp
@global CPViewFrameDidChangeNotification

var NUAdvancedSearchFieldDataSource_searchField_groupDataViewForObjectValue_        = 1 << 1,
    NUAdvancedSearchFieldDataSource_searchField_dataViewForObjectValue_             = 1 << 2,
    NUAdvancedSearchFieldDataSource_searchField_matchingItemsForString_             = 1 << 3,
    NUAdvancedSearchFieldDataSource_searchField_heightOfViewForObjectValue_         = 1 << 4,
    NUAdvancedSearchFieldDataSource_searchField_heightOfGroupViewForObjectValue_    = 1 << 5,
    NUAdvancedSearchFieldDelegate_didSelectItem_                                    = 1 << 6,
    NUAdvancedSearchFieldDelegate_searchFieldDidClosePanel_                         = 1 << 7;


@protocol NUAdvancedSearchFieldDelegate <CPObject>

@optional
- (void)searchField:(NUAdvancedSearchField)aSearchField didSelectItem:(id)anItem;
- (void)searchFieldDidClosePanel:(NUAdvancedSearchField)aSearchField;

@end

@protocol NUAdvancedSearchFieldDataSource <CPObject>

@optional
- (CPDictionary)searchField:(NUAdvancedSearchField)aSearchField matchingItemsForString:(CPString)aStringValue;
- (CPView)searchField:(NUAdvancedSearchField)aSearchField groupDataViewForObjectValue:(id)anObjectValue;
- (CPView)searchField:(NUAdvancedSearchField)aSearchField dataViewForObjectValue:(id)anObjectValue;
- (float)searchField:(NUAdvancedSearchField)aSearchField heightOfViewForObjectValue:(id)anObjectValue;
- (float)searchField:(NUAdvancedSearchField)aSearchField heightOfGroupViewForObjectValue:(id)anObjectValue;

@end


var _BEZEL_INSET_BOTTOM = 1.0,
    _BEZEL_INSET_LEFT = 0.0;

@implementation NUAdvancedSearchField : CPSearchField
{
    BOOL                                        _allowsVerticalResizing     @accessors(property=allowsVerticalResizing);
    CGSize                                      _panelSize                  @accessors(property=panelSize);
    CPMutableDictionary                         _content                    @accessors(property=content);
    id <NUAdvancedSearchFieldDataSource>        _searchFieldDataSource      @accessors(property=dataSource);
    id <NUAdvancedSearchFieldDelegate>          _searchFieldDelegate        @accessors(property=delegate);

    CPMutableArray                              _currentHiglightedItems;
    CPScrollView                                _scrollView;
    CPTableColumn                               _tableColumn;
    CPTableView                                 _tableView;
    int                                         _numberOfItems;
    int                                         _totalHeightTableView;
    unsigned                                    _implementedSearchFieldDataSourceMethods;
    unsigned                                    _implementedSearchFieldDelegateMethods;
    _NUAdvancedSearchFieldPanel                         _panel;
}


#pragma mark -
#pragma mark Init methods

- (void)_initSearchValues
{
    _currentHiglightedItems = [];
    _content = @{};
    _numberOfItems = 0;
}

- (void)_init
{
    [super _init];
    [self _initSearchValues];

    [self setTarget:self];
    [self setAction:@selector(_searchFieldAction:)];

    var frame = CGRectMake(0, 0, 200, 200);

    [self _makeTableView];
    [self _makeScrollViewWithFrame:frame];

    _tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"SearchFieldContent"];
    [_tableColumn setWidth:CGRectGetWidth(frame) - [CPScroller scrollerWidth]];
    [_tableColumn setResizingMask:CPTableColumnAutoresizingMask];
    [_tableView addTableColumn:_tableColumn];

    [_scrollView setDocumentView:_tableView];

    // This has to be done after setDocumentView so that the table knows which scroll view to update
    [_tableView setHeaderView:nil];

    [self _makePanelWithFrame:frame];

    [[_panel contentView] addSubview:_scrollView];
    [_panel setInitialFirstResponder:_tableView];

    [_scrollView scrollToBeginningOfDocument:nil];

    // We gonna change this size anyway
    _panelSize = CGSizeMake(200, 200);
    _allowsVerticalResizing = YES;

    [self setPostsFrameChangedNotifications:YES];
}

- (void)_makeTableView
{
    _tableView = [[CPTableView alloc] initWithFrame:CGRectMakeZero()];

    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setUsesAlternatingRowBackgroundColors:NO];
    [_tableView setAllowsMultipleSelection:NO];
    [_tableView setDoubleAction:@selector(_doubleClickTableView:)];
    [_tableView setTarget:self];
}

- (void)_makeScrollViewWithFrame:(CGRect)aFrame
{
    _scrollView = [[CPScrollView alloc] initWithFrame:aFrame];

    [_scrollView setBorderType:CPLineBorder];
    [_scrollView setAutohidesScrollers:NO];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:NO];
    [_scrollView setLineScroll:[_tableView rowHeight]];
    [_scrollView setVerticalPageScroll:0.0];
}

- (void)_makePanelWithFrame:(CGRect)aFrame
{
    _panel = [[_NUAdvancedSearchFieldPanel alloc] initWithContentRect:aFrame styleMask:CPBorderlessWindowMask];

    [_panel setTitle:@""];
    [_panel setFloatingPanel:YES];
    [_panel setBecomesKeyOnlyIfNeeded:YES];
    [_panel setLevel:CPPopUpMenuWindowLevel];
    [_panel setHasShadow:YES];
    [_panel setShadowStyle:CPMenuWindowShadowStyle];
    [_panel setDelegate:self];
}


#pragma mark -
#pragma mark DataSource and delegate

- (void)setDataSource:(id <NUAdvancedSearchFieldDataSource>)aDataSource
{
    _searchFieldDataSource = aDataSource;
    _implementedSearchFieldDataSourceMethods = 0;

    if ([_searchFieldDataSource respondsToSelector:@selector(searchField:groupDataViewForObjectValue:)])
        _implementedSearchFieldDataSourceMethods |= NUAdvancedSearchFieldDataSource_searchField_groupDataViewForObjectValue_;

    if ([_searchFieldDataSource respondsToSelector:@selector(searchField:dataViewForObjectValue:)])
        _implementedSearchFieldDataSourceMethods |= NUAdvancedSearchFieldDataSource_searchField_dataViewForObjectValue_;

    if ([_searchFieldDataSource respondsToSelector:@selector(searchField:matchingItemsForString:)])
        _implementedSearchFieldDataSourceMethods |= NUAdvancedSearchFieldDataSource_searchField_matchingItemsForString_;

    if ([_searchFieldDataSource respondsToSelector:@selector(searchField:heightOfViewForObjectValue:)])
        _implementedSearchFieldDataSourceMethods |= NUAdvancedSearchFieldDataSource_searchField_heightOfViewForObjectValue_;

    if ([_searchFieldDataSource respondsToSelector:@selector(searchField:heightOfGroupViewForObjectValue:)])
        _implementedSearchFieldDataSourceMethods |= NUAdvancedSearchFieldDataSource_searchField_heightOfGroupViewForObjectValue_;
}

- (void)setDelegate:(id <NUAdvancedSearchFieldDelegate>)aDelegate
{
    _searchFieldDelegate = aDelegate
    _implementedSearchFieldDelegateMethods = 0;

    if ([_searchFieldDelegate respondsToSelector:@selector(searchField:didSelectItem:)])
        _implementedSearchFieldDelegateMethods |= NUAdvancedSearchFieldDelegate_didSelectItem_;

    if ([_searchFieldDelegate respondsToSelector:@selector(searchFieldDidClosePanel:)])
        _implementedSearchFieldDelegateMethods |= NUAdvancedSearchFieldDelegate_searchFieldDidClosePanel_;
}


#pragma mark -
#pragma mark Overrides

/*! Overide the stringValue, if @"" we close the panel
*/
- (void)setStringValue:(CPString)aStringValue
{
    [super setStringValue:aStringValue];

    if (aStringValue === @"")
    {
         [self closePanel];
         [self _updateCancelButtonVisibility];
    }
}


#pragma mark -
#pragma mark Panel methods

/*! Pop up the panel
    Her we also modify the size of the panel depending on the size of the tableView
*/
- (void)showPanel
{
    [self _calculateNumberOfItems];

    _totalHeightTableView = 0;
    [_tableView reloadData];

    var frameSearchFieldInBase = [[self superview] convertRectToBase:[self frame]],
        frame = CGRectMakeZero();

    if (!_allowsVerticalResizing)
    {
        [_scrollView setFrameSize:_panelSize];
    }
    else
    {
        var height = _totalHeightTableView + [CPScroller scrollerWidth] + [_tableView intercellSpacing].height * ([self numberOfRowsInTableView:_tableView] - 2),
            searchFieldWindow = [self window],
            heightToBottom = [searchFieldWindow frame].size.height - CGRectGetMaxY(frameSearchFieldInBase);

        if (height > heightToBottom)
            height = heightToBottom;

        [_scrollView setFrameSize:CGSizeMake(_panelSize.width, height)];
    }

    frame.origin.x = frameSearchFieldInBase.origin.x + _BEZEL_INSET_LEFT;
    frame.origin.y = CGRectGetMaxY(frameSearchFieldInBase) - _BEZEL_INSET_BOTTOM;
    frame.size = CGSizeMakeCopy([_scrollView frameSize]);
    [_tableColumn setWidth:CGRectGetWidth(frame) - [CPScroller scrollerWidth]];

    [_panel setFrame:frame];

    if (![_panel isVisible])
        [_panel orderFront:nil];
}

/*! Simulate a click on the selected item and close the panel and set the stringValue of the searchField to @""
*/
- (void)clickAndClose
{
    [self _selectItemClicked];
    [self setStringValue:@""];
}

/*! Close the panel
*/
- (void)closePanel
{
    [self _initSearchValues];
    [_panel orderOut:nil];
    [self _searchFieldDidClosePanel];
}


#pragma mark -
#pragma mark Datasource utilities

/*! Calculate the number of items of the tableView (groups + items)
*/
- (void)_calculateNumberOfItems
{
    _numberOfItems = 0;

    var keys = [_content allKeys];

    for (var i = [keys count] - 1; i >= 0; i--)
    {
        var key = keys[i];

        _numberOfItems++;
        _numberOfItems += [[_content objectForKey:key] count];
    }
}

/*! Return the objectValue of the given index
*/
- (id)_objectValueForIndex:(int)anIndex
{
    var keys = [_content allKeys],
        index = 0;

    for (var i = [keys count] - 1; i >= 0; i--)
    {
        var key = keys[i],
            items = [_content objectForKey:key];

        if (index == anIndex)
            return key;

        index++;

        for (var j = [items count] - 1; j >= 0; j--)
        {
            if (index == anIndex)
                return items[j];

            index++;

        }
    }
}

/*! Return a boolean to know is the given row is a group or not
*/
- (BOOL)_isGroupRow:(int)aRowIndex
{
    var keys = [_content allKeys],
        index = 0;

    for (var i = [keys count] - 1; i >= 0; i--)
    {
        var key = keys[i];

        if (index == aRowIndex)
            return YES;

        index++;
        index += [[_content objectForKey:key] count];
    }

    return NO;
}


#pragma mark -
#pragma mark Key event

- (void)insertNewline:(id)sender
{
    if ([self isVisible] && [_tableView selectedRow] != CPNotFound)
        [self clickAndClose];
}

- (void)cancelOperation:(id)sender
{
    if ([self isVisible])
        [self setStringValue:@""];
}

- (void)moveDown:(id)sender
{
    if ([self isVisible])
        [self selectNextItem];
    else
        [self _searchFieldAction:self];
}

- (void)moveUp:(id)sender
{
    if ([self isVisible])
        [self selectPreviousItem];
    else
        [self _searchFieldAction:self];
}

#pragma mark -
#pragma mark Utilities

/*!
    Returns whether the list is currently visible.
*/
- (BOOL)isVisible
{
    return [_panel isVisible];
}


#pragma mark -
#pragma mark Manipulating the Selection

/*!
    Select the next item in the list if there one. If there is currently no selected item,
    the first item is selected. Returns YES if the selection changed.
*/
- (BOOL)selectNextItem
{
    if (![_tableView isEnabled])
        return NO;

    var row = [_tableView selectedRow];

    if (row < (_numberOfItems - 1))
    {
        row++;

        while ([self _isGroupRow:row] && row <= _numberOfItems - 1)
            row++;

        if (row == _numberOfItems)
            return [self selectRow:[_tableView selectedRow]];

        return [self selectRow:row];
    }
    else
    {
        return NO;
    }
}

/*!
    Select the previous item in the list. If there is currently no selected item,
    nothing happens. Returns YES if the selection changed.
*/
- (BOOL)selectPreviousItem
{
    if (![_tableView isEnabled])
        return NO;

    var row = [_tableView selectedRow];

    if (row > 0)
    {
        row--;

        while ([self _isGroupRow:row] && row > 0)
            row--;

        if (row == 0)
            return [self selectRow:[_tableView selectedRow]];

        return [self selectRow:row];
    }
    else
    {
         return NO;
    }
}


/*!
    Selects a row and scrolls it to be visible. Returns YES if the selection actually changed.
*/
- (BOOL)selectRow:(int)row
{
    if (row === [_tableView selectedRow])
        return NO;

    var validRow = (row >= 0 && row < [self numberOfRowsInTableView:_tableView]),
        indexes = validRow ? [CPIndexSet indexSetWithIndex:row] : [CPIndexSet indexSet];

    [_tableView selectRowIndexes:indexes byExtendingSelection:NO];

    if (validRow)
    {
        [_tableView scrollRowToVisible:row];
        return YES;
    }
    else
        return NO;
}

/*! Select the item clicked
*/
- (void)_selectItemClicked
{
    var objectValue = [self _objectValueForIndex:[_tableView selectedRow]];
    [self _didSelectItem:objectValue];
}


#pragma mark -
#pragma mark Scroll methods

/*!
    Scroll the list down one page.
*/
- (void)scrollPageDown:(id)sender
{
    if ([self isVisible])
        [_scrollView scrollPageDown:sender];
}

/*!
    Scroll the list up one page.
*/
- (void)scrollPageUp:(id)sender
{
    if ([self isVisible])
        [_scrollView scrollPageUp:sender];
}

/*!
    Scroll to the top of the list.
*/
- (void)scrollToBeginningOfDocument:(id)sender
{
    [_scrollView scrollToBeginningOfDocument:sender];
}

/*!
    Scroll to the bottom of the list.
*/
- (void)scrollToEndOfDocument:(id)sender
{
    [_scrollView scrollToEndOfDocument:sender];
}

- (void)scrollItemAtIndexToTop:(int)row
{
    var rect = [_tableView rectOfRow:row];
    [[_tableView superview] scrollToPoint:rect.origin];
}


#pragma mark -
#pragma mark Action

/*! Called when doubleClick on the tableView.
    This close the panel
*/
- (void)_doubleClickTableView:(id)sender
{
    [self clickAndClose];
}

/*! Action of the searchField, here we gonna close or open the panel
*/
- (void)_searchFieldAction:(id)sender
{
    var objectValue = [sender objectValue];

    // If the searchField is empty or a canvasView wasn't given we close the panel
    if (!objectValue || objectValue === @"")
    {
        [self closePanel];
        return;
    }

    [self _initSearchValues];

    [self setContent:[self _matchingItemsForString:objectValue]]
}

- (void)setContent:(CPMutableDictionary)someContents
{
    [self setContent:someContents showPanel:YES];
}

- (void)setContent:(CPMutableDictionary)someContents showPanel:(BOOL)shouldShowPanel
{
    _content = someContents;

    if (!shouldShowPanel)
        return;

    if ([_content count])
        [self showPanel]
    else
        [self closePanel];
}


#pragma mark -
#pragma mark Notification frame

/*! Notification frameDidChangeNotification
    This is needed when the frames searchField change, the panel will follow the searchField
*/
- (void)frameDidChangeNotification:(CPNotification)aNotification
{
    if ([self isVisible])
    {
        var frameSearchFieldInBase = [[self superview] convertRectToBase:[self frame]],
            frame = [_panel frame];

        frame.origin.x = frameSearchFieldInBase.origin.x + _BEZEL_INSET_LEFT;

        [_panel setFrame:frame];
    }
}


#pragma mark -
#pragma mark Override

- (void)viewWillMoveToSuperview:(CPView)aView
{
    [super viewWillMoveToSuperview:aView];

    [[CPNotificationCenter defaultCenter] removeObserver:self name:CPViewFrameDidChangeNotification object:nil];

    if (aView)
        [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChangeNotification:) name:CPViewFrameDidChangeNotification object:nil];
}

@end


@implementation NUAdvancedSearchField (TableViewDataSource)

/*! DataSource numberOfRowsInTableView
*/
- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    return _numberOfItems;
}

/*! DataSource objectValueForTableColumn
*/
- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    return [self _objectValueForIndex:aRowIndex];
}

/*! DataSource viewForTableColumn
    This method is going to check if we need a groupView or a dataView and call the appropriate datasource of the searchField
*/
- (id)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    var objectValue = [self _objectValueForIndex:aRowIndex];

    if ([self _isGroupRow:aRowIndex])
        return [self _groupDataViewForObjectValue:objectValue];

    return [self _dataViewForObjectValue:objectValue];
}

@end

@implementation NUAdvancedSearchField (TableViewDelegate)

/*! Delegate shouldSelectRow.
*/
- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
    return ![self _isGroupRow:rowIndex];
}

/*! tableViewSelectionDidChange delegate.
    When selecting a item, we center the treeView on this item.
    If autoSelectObjectValue is set, this is going to select the item as well
*/
- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    var selectedRow = [_tableView selectedRow],
        objectValue = [self _objectValueForIndex:selectedRow];

    [self _didSelectItem:objectValue];
}

/*! Return a boolean to know if the row is a group or not
    @param aRowIndex
    @return aBoolean
*/
- (BOOL)tableView:(CPTableView)aTableView isGroupRow:(int)aRowIndex
{
    return [self _isGroupRow:aRowIndex];
}

/*! Delegate heightOfRow of the tableView
    This method will check if we need the height of a groupView or a dataView.
    This also calculate the total size of the tableView to fit well the panel.
    @param row
    @return the size of the row
*/
- (float)tableView:(CPTableView)tableView heightOfRow:(int)row
{
    var objectValue = [self _objectValueForIndex:row],
        height = [self _isGroupRow:row] ? [self _heightOfGroupViewForObjectValue:objectValue] : [self _heightOfViewForObjectValue:objectValue];

    _totalHeightTableView += height;

    return height;
}

@end


@implementation NUAdvancedSearchField (NUAdvancedSearchFieldDataSource)

/*! _groupDictForItems dataSource
    @param items, the items for the tableView
    @return a dict. By default return @{@"Items", items}
*/
- (CPDictionary)_matchingItemsForString:(CPString)aStringValue
{
    if (!(_implementedSearchFieldDataSourceMethods & NUAdvancedSearchFieldDataSource_searchField_matchingItemsForString_))
        return @{};

    return [_searchFieldDataSource searchField:self matchingItemsForString:aStringValue];
}

/*! _groupDataViewForObjectValuedo dataSource
    @param anObjectValue, the objectValue of the view
    @return a view. By default return a CPTextField
*/
- (CPView)_groupDataViewForObjectValue:(id)anObjectValue
{
    if (!(_implementedSearchFieldDataSourceMethods & NUAdvancedSearchFieldDataSource_searchField_groupDataViewForObjectValue_))
        return [CPTextField labelWithTitle:anObjectValue];

    return [_searchFieldDataSource searchField:self groupDataViewForObjectValue:anObjectValue];
}

/*! _dataViewForObjectValue dataSource
    @param anObjectValue, the objectValue of the view
    @return a view. By default return a CPTextField
*/
- (CPView)_dataViewForObjectValue:(id)anObjectValue
{
    if (!(_implementedSearchFieldDataSourceMethods & NUAdvancedSearchFieldDataSource_searchField_dataViewForObjectValue_))
        return [CPTextField labelWithTitle:anObjectValue];

    return [_searchFieldDataSource searchField:self dataViewForObjectValue:anObjectValue];
}

/*! _heightOfViewForObjectValue dataSource
    @param anObjectValue, the objectValue of the View
    @return the height of the groupView. By default 30
*/
- (float)_heightOfViewForObjectValue:(id)anObjectValue
{
    if (!(_implementedSearchFieldDataSourceMethods & NUAdvancedSearchFieldDataSource_searchField_heightOfViewForObjectValue_))
        return 30;

    return [_searchFieldDataSource searchField:self heightOfViewForObjectValue:anObjectValue];
}

/*! _heightOfGroupViewForObjectValue dataSource
    @param anObjectValue, the objectValue of the groupView
    @return the height of the groupView. By default 30
*/
- (float)_heightOfGroupViewForObjectValue:(id)anObjectValue
{
    if (!(_implementedSearchFieldDataSourceMethods & NUAdvancedSearchFieldDataSource_searchField_heightOfGroupViewForObjectValue_))
        return 30;

    return [_searchFieldDataSource searchField:self heightOfGroupViewForObjectValue:anObjectValue];
}

@end


@implementation NUAdvancedSearchField (NUAdvancedSearchFieldDelegate)

- (void)_didSelectItem:(id)anObjectValue
{
    if (!(_implementedSearchFieldDelegateMethods & NUAdvancedSearchFieldDelegate_didSelectItem_))
        return;

    [_searchFieldDelegate searchField:self didSelectItem:anObjectValue];
}

- (void)_searchFieldDidClosePanel
{
    if (!(_implementedSearchFieldDelegateMethods & NUAdvancedSearchFieldDelegate_searchFieldDidClosePanel_))
        return;

    [_searchFieldDelegate searchFieldDidClosePanel:self];
}

@end


/*! This class is used to trap the next mouse clicked. To close or not the panel
*/
@implementation _NUAdvancedSearchFieldPanel : CPPanel

- (void)orderFront:(id)sender
{
    [self _trapNextMouseDown];
    [super orderFront:sender];
}

- (void)_mouseWasClicked:(CPEvent)anEvent
{
    var mouseWindow = [anEvent window],
        rect = [self frame];

    if (mouseWindow != self && !CGRectContainsPoint(rect, [anEvent locationInWindow]))
        [[self delegate] closePanel];
    else
        [self _trapNextMouseDown];
}

- (void)_trapNextMouseDown
{
    // Don't dequeue the event so clicks in controls will work
    [CPApp setTarget:self selector:@selector(_mouseWasClicked:) forNextEventMatchingMask:CPLeftMouseDownMask untilDate:nil inMode:CPDefaultRunLoopMode dequeue:NO];
}

@end
