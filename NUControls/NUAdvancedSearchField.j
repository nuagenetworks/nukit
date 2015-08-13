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
@import "NUSkin.j"

@class _NUAdvancedSearchFieldPanel

@global CPTableColumnAutoresizingMask
@global CPBorderlessWindowMask
@global CPApp
@global CPViewFrameDidChangeNotification

var NUAdvancedSearchFieldDataSource_searchField_matchingItemsForString_        = 1 << 1,
    NUAdvancedSearchFieldDelegate_didSelectItem_                               = 1 << 2,
    NUAdvancedSearchFieldDelegate_searchFieldDidClosePanel_                    = 1 << 3,
    NUAdvancedSearchFieldDelegate_searchField_dataViewForObjectValue_          = 1 << 4,
    NUAdvancedSearchFieldDelegate_searchField_groupDataViewForObjectValue_     = 1 << 5,
    NUAdvancedSearchFieldDelegate_searchField_heightOfGroupViewForObjectValue_ = 1 << 6,
    NUAdvancedSearchFieldDelegate_searchField_heightOfViewForObjectValue_      = 1 << 7;


@protocol NUAdvancedSearchFieldDelegate <CPObject>

@optional
- (void)searchField:(NUAdvancedSearchField)aSearchField didSelectItem:(id)anItem;
- (void)searchFieldDidClosePanel:(NUAdvancedSearchField)aSearchField;
- (CPView)searchField:(NUAdvancedSearchField)aSearchField groupDataViewForObjectValue:(id)anObjectValue;
- (CPView)searchField:(NUAdvancedSearchField)aSearchField dataViewForObjectValue:(id)anObjectValue;
- (float)searchField:(NUAdvancedSearchField)aSearchField heightOfViewForObjectValue:(id)anObjectValue;
- (float)searchField:(NUAdvancedSearchField)aSearchField heightOfGroupViewForObjectValue:(id)anObjectValue;

@end

@protocol NUAdvancedSearchFieldDataSource <CPObject>

@optional
- (CPDictionary)searchField:(NUAdvancedSearchField)aSearchField matchingItemsForString:(CPString)aStringValue;

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
    CPColor                                     _panelBackgroundColor       @accessors(property=panelBackgroundColor);

    CPMutableArray                              _currentHiglightedItems;
    CPScrollView                                _scrollView;
    CPTableColumn                               _tableColumn;
    CPTableView                                 _tableView;
    int                                         _numberOfItems;
    int                                         _totalHeightTableView;
    unsigned                                    _implementedSearchFieldDataSourceMethods;
    unsigned                                    _implementedSearchFieldDelegateMethods;
    _NUAdvancedSearchFieldPanel                 _panel;
}


#pragma mark -
#pragma mark Initialization

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

    _panelBackgroundColor = NUSkinColorWhite;

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
    [_tableView setBackgroundColor:[CPColor clearColor]];
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
    [_scrollView setBackgroundColor:[CPColor clearColor]];
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
    [[_panel contentView] setBackgroundColor:_panelBackgroundColor];
    [_panel contentView]._DOMElement.style.WebkitBackdropFilter = "blur(10px)";
}


#pragma mark -
#pragma mark Notifications Handlers

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
#pragma mark DataSource Management

- (void)setDataSource:(id <NUAdvancedSearchFieldDataSource>)aDataSource
{
    _searchFieldDataSource = aDataSource;
    _implementedSearchFieldDataSourceMethods = 0;

    if ([_searchFieldDataSource respondsToSelector:@selector(searchField:matchingItemsForString:)])
        _implementedSearchFieldDataSourceMethods |= NUAdvancedSearchFieldDataSource_searchField_matchingItemsForString_;
}

- (CPDictionary)_sendDataSourceMatchingItemsForString:(CPString)aStringValue
{
    if (!(_implementedSearchFieldDataSourceMethods & NUAdvancedSearchFieldDataSource_searchField_matchingItemsForString_))
        return @{};

    return [_searchFieldDataSource searchField:self matchingItemsForString:aStringValue];
}


#pragma mark -
#pragma mark Delegate Management

- (void)setDelegate:(id <NUAdvancedSearchFieldDelegate>)aDelegate
{
    _searchFieldDelegate = aDelegate
    _implementedSearchFieldDelegateMethods = 0;

    if ([_searchFieldDelegate respondsToSelector:@selector(searchField:heightOfViewForObjectValue:)])
        _implementedSearchFieldDelegateMethods |= NUAdvancedSearchFieldDelegate_searchField_heightOfViewForObjectValue_;

    if ([_searchFieldDelegate respondsToSelector:@selector(searchField:groupDataViewForObjectValue:)])
        _implementedSearchFieldDelegateMethods |= NUAdvancedSearchFieldDelegate_searchField_groupDataViewForObjectValue_;

    if ([_searchFieldDelegate respondsToSelector:@selector(searchField:dataViewForObjectValue:)])
        _implementedSearchFieldDelegateMethods |= NUAdvancedSearchFieldDelegate_searchField_dataViewForObjectValue_;

    if ([_searchFieldDelegate respondsToSelector:@selector(searchField:heightOfGroupViewForObjectValue:)])
        _implementedSearchFieldDelegateMethods |= NUAdvancedSearchFieldDelegate_searchField_heightOfGroupViewForObjectValue_;

    if ([_searchFieldDelegate respondsToSelector:@selector(searchField:didSelectItem:)])
        _implementedSearchFieldDelegateMethods |= NUAdvancedSearchFieldDelegate_didSelectItem_;

    if ([_searchFieldDelegate respondsToSelector:@selector(searchFieldDidClosePanel:)])
        _implementedSearchFieldDelegateMethods |= NUAdvancedSearchFieldDelegate_searchFieldDidClosePanel_;
}

- (CPView)_sendDelegateGroupDataViewForObjectValue:(id)anObjectValue
{
    if (!(_implementedSearchFieldDelegateMethods & NUAdvancedSearchFieldDelegate_searchField_groupDataViewForObjectValue_))
        return [CPTextField labelWithTitle:anObjectValue];

    return [_searchFieldDelegate searchField:self groupDataViewForObjectValue:anObjectValue];
}

- (CPView)_sendDelegateDataViewForObjectValue:(id)anObjectValue
{
    if (!(_implementedSearchFieldDelegateMethods & NUAdvancedSearchFieldDelegate_searchField_dataViewForObjectValue_))
        return [CPTextField labelWithTitle:anObjectValue];

    return [_searchFieldDelegate searchField:self dataViewForObjectValue:anObjectValue];
}

- (float)_sendDelegateHeightOfViewForObjectValue:(id)anObjectValue
{
    if (!(_implementedSearchFieldDelegateMethods & NUAdvancedSearchFieldDelegate_searchField_heightOfViewForObjectValue_))
        return 30;

    return [_searchFieldDelegate searchField:self heightOfViewForObjectValue:anObjectValue];
}

- (float)_sendDelegateHeightOfGroupViewForObjectValue:(id)anObjectValue
{
    if (!(_implementedSearchFieldDelegateMethods & NUAdvancedSearchFieldDelegate_searchField_heightOfGroupViewForObjectValue_))
        return 30;

    return [_searchFieldDelegate searchField:self heightOfGroupViewForObjectValue:anObjectValue];
}

- (void)_sendDelegateDidSelectItem:(id)anObjectValue
{
    if (!(_implementedSearchFieldDelegateMethods & NUAdvancedSearchFieldDelegate_didSelectItem_))
        return;

    [_searchFieldDelegate searchField:self didSelectItem:anObjectValue];
}

- (void)_sendDelegateSearchFieldDidClosePanel
{
    if (!(_implementedSearchFieldDelegateMethods & NUAdvancedSearchFieldDelegate_searchFieldDidClosePanel_))
        return;

    [_searchFieldDelegate searchFieldDidClosePanel:self];
}


#pragma mark -
#pragma mark NUAdvancedSearchField API

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

- (void)closePanel
{
    [self _initSearchValues];
    [_panel orderOut:nil];
    [self _sendDelegateSearchFieldDidClosePanel];
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

- (BOOL)isVisible
{
    return [_panel isVisible];
}

- (void)setPanelBackgroundColor:(CPColor)aColor
{
    _panelBackgroundColor = aColor;

    if (_panel)
        [[_panel contentView] setBackgroundColor:_panelBackgroundColor];
}


#pragma mark -
#pragma mark Utilities

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

- (void)_selectCurrentItemAndClosePanel
{
    var objectValue = [self _objectValueForIndex:[_tableView selectedRow]];
    [self _sendDelegateDidSelectItem:objectValue];
    [self setStringValue:@""];
}


#pragma mark -
#pragma mark Action

- (void)_doubleClickTableView:(id)sender
{
    [self _selectCurrentItemAndClosePanel];
}

- (void)_searchFieldAction:(id)sender
{
    var stringValue = [sender stringValue];

    // If the searchField is empty or a canvasView wasn't given we close the panel
    if (!stringValue || stringValue === @"")
    {
        [self setContent:[]];
        [self closePanel];
        return;
    }

    [self _initSearchValues];
    [self setContent:[self _sendDataSourceMatchingItemsForString:stringValue]];
}

- (void)_cancelButtonClick:(id)aSender
{
    [self setStringValue:@""];
}


#pragma mark -
#pragma mark Overrides

- (void)setStringValue:(CPString)aStringValue
{
    [super setStringValue:aStringValue];

    if (!aStringValue || aStringValue === @"")
    {
         [self closePanel];
         [self _updateCancelButtonVisibility];
    }
}

- (void)viewWillMoveToSuperview:(CPView)aView
{
    [super viewWillMoveToSuperview:aView];

    [[CPNotificationCenter defaultCenter] removeObserver:self name:CPViewFrameDidChangeNotification object:nil];

    if (aView)
        [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChangeNotification:) name:CPViewFrameDidChangeNotification object:nil];
}

- (void)insertNewline:(id)sender
{
    if ([self isVisible] && [_tableView selectedRow] != CPNotFound)
        [self _selectCurrentItemAndClosePanel];
}

- (void)cancelOperation:(id)sender
{
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

- (void)scrollPageDown:(id)sender
{
    if ([self isVisible])
        [_scrollView scrollPageDown:sender];
}

- (void)scrollPageUp:(id)sender
{
    if ([self isVisible])
        [_scrollView scrollPageUp:sender];
}

- (void)scrollToBeginningOfDocument:(id)sender
{
    [_scrollView scrollToBeginningOfDocument:sender];
}

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
#pragma mark CPTableView DataSource

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    return _numberOfItems;
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    return [self _objectValueForIndex:aRowIndex];
}

- (id)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    var objectValue = [self _objectValueForIndex:aRowIndex];

    if ([self _isGroupRow:aRowIndex])
        return [self _sendDelegateGroupDataViewForObjectValue:objectValue];

    return [self _sendDelegateDataViewForObjectValue:objectValue];
}


#pragma mark -
#pragma mark CPTableView Delegates

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
    return ![self _isGroupRow:rowIndex];
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    var selectedRow = [_tableView selectedRow],
        objectValue = [self _objectValueForIndex:selectedRow];

    [self _sendDelegateDidSelectItem:objectValue];
}

- (BOOL)tableView:(CPTableView)aTableView isGroupRow:(int)aRowIndex
{
    return [self _isGroupRow:aRowIndex];
}

- (float)tableView:(CPTableView)tableView heightOfRow:(int)row
{
    var objectValue = [self _objectValueForIndex:row],
        height = [self _isGroupRow:row] ? [self _sendDelegateHeightOfGroupViewForObjectValue:objectValue] : [self _sendDelegateHeightOfViewForObjectValue:objectValue];

    _totalHeightTableView += height;

    return height;
}

@end



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
