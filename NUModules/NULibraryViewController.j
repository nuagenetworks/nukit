/*
*   Filename:         NULibraryViewController.j
*   Created:          Fri Jun 21 11:13:36 PDT 2013
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
@import <AppKit/CPSplitView.j>
@import <AppKit/CPTrackingArea.j>
@import <TNKit/TNTableViewDataSource.j>
@import "NUUtilities.j"
@import "NUNumericTextField.j"

@class NUKit
@class NULibraryTableView

@global CPApp

@global CPTrackingMouseEnteredAndExited
@global CPTrackingActiveInKeyWindow
@global CPTrackingInVisibleRect
@global CPTrackingMouseMoved

var NULibraryViewControllerDelegate_libraryController_addLibraryObject_count_  = 1 << 1;

NULibraryItemDraggingType = @"NULibraryItemDraggingType";

var NULibraryViewControllerImageCollapseShow,
    NULibraryViewControllerImageCollapseShowPressed,
    NULibraryViewControllerImageCollapseHide,
    NULibraryViewControllerImageCollapseHidePressed;



@implementation NULibraryViewController : CPViewController
{
    @outlet CPTextField                 labelTitle;
    @outlet CPTextField                 labelMultiplier;
    @outlet CPTextField                 labelMultiplierError;
    @outlet NULibraryTableView          tableViewLibrary;
    @outlet NUNumericTextField          fieldMultiplier;

    id                                  _delegate               @accessors(property=delegate);
    int                                 _defaultHeight          @accessors(property=defaultHeight);

    BOOL                                _isVisible;
    CPDictionary                        _contentRegistry;
    CPSplitView                         _splitView;
    TNTableViewDataSource               _dataSourceLibrary;
    unsigned                            _implementedDelegateMethods;
}


#pragma mark -
#pragma mark Class Methods

+ (id)new
{
    var obj = [[self alloc] initWithCibName:@"Library" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]];

    [obj view];

    return obj;
}

+ (id)libraryControllerWithSplitViewInnerView:(CPView)aContainer delegate:(id)aDelegate
{
    var obj   = [self new],
        frame = [aContainer bounds];

    [obj setSplitView:[aContainer superview]];
    [obj setDelegate:aDelegate];

    [[obj view] setFrame:frame];
    [aContainer addSubview:[obj view]];

    return obj;
}


#pragma mark -
#pragma mark Initialization

- (void)awakeFromCib
{
    _contentRegistry = @{};
    _defaultHeight   = 200;
    _title           = @"Library";

    _dataSourceLibrary = [[TNTableViewDataSource alloc] init];
    [_dataSourceLibrary setTable:tableViewLibrary];
    [_dataSourceLibrary setDelegate:self];

    var trackingArea = [[CPTrackingArea alloc] initWithRect:CGRectMakeZero()
                                                options:CPTrackingMouseEnteredAndExited | CPTrackingActiveInKeyWindow | CPTrackingMouseMoved | CPTrackingInVisibleRect
                                                  owner:tableViewLibrary
                                               userInfo:nil];

    [tableViewLibrary addTrackingArea:trackingArea];

    [tableViewLibrary setDataSource:_dataSourceLibrary];
    [tableViewLibrary setDelegate:self];
    [tableViewLibrary setTarget:self];
    [tableViewLibrary setDoubleAction:@selector(_didDoubleClickOnTableView:)];
    _cucappID(tableViewLibrary, @"library-table-view");

    [labelMultiplierError setHidden:YES];

    [labelTitle bind:CPValueBinding toObject:self withKeyPath:@"title" options:nil];
}


#pragma mark -
#pragma mark Content Management

- (void)setContent:(CPArray)someContent
{
    if (someContent && [someContent count])
    {
        [_dataSourceLibrary setContent:someContent];
        [self showLibrary:YES];
    }
    else
    {
        [_dataSourceLibrary setContent:[]];
        [self showLibrary:NO];
    }

    [self setMultiplierValue:1]
    [tableViewLibrary reloadData];
}

- (void)setCurrentContentWithIdentifier:(CPString)anIdentifier
{
    [self setContent:[self registeredContentWithIdentifier:anIdentifier]];
}

- (void)registerContent:(CPArray)aContent forIdentifier:(CPString)anIdentifier
{
    [_contentRegistry setObject:aContent forKey:anIdentifier];
}

- (CPArray)registeredContentWithIdentifier:(CPString)anIdentifier
{
    return [_contentRegistry objectForKey:anIdentifier];
}


#pragma mark -
#pragma mark Multiplier Management

- (void)setMultiplierHidden:(BOOL)shouldHide
{
    [fieldMultiplier setHidden:shouldHide];
    [labelMultiplierError setHidden:shouldHide];
    [labelMultiplier setHidden:shouldHide];
}

- (int)multiplierValue
{
    var multiplier = [fieldMultiplier intValue];

    if (!multiplier || multiplier <= 0)
        multiplier = 1;

    return MIN(20, multiplier);
}

- (void)setMultiplierValue:(int)aValue
{
    [fieldMultiplier setIntValue:aValue];
}


#pragma mark -
#pragma mark Split View Management

- (void)setSplitView:(CPSplitView)aSplitView
{
    _splitView = aSplitView;
    [_splitView setDelegate:self];
}


#pragma mark -
#pragma mark Visibility Management

- (void)showLibrary:(BOOL)shouldShow
{
    if (_isVisible === shouldShow)
        return;

    _isVisible = shouldShow;

    [_splitView setDelegate:nil];

    if (_isVisible)
        [_splitView setPosition:([_splitView frameSize].height - _defaultHeight) ofDividerAtIndex:0];
    else
        [_splitView setPosition:([_splitView frameSize].height) ofDividerAtIndex:0];

    [_splitView setDelegate:self];
}


#pragma mark -
#pragma mark Delegate Management

- (void)setDelegate:(id)aDelegate
{
    if (aDelegate == _delegate)
        return;

    _delegate = aDelegate;
    _implementedDelegateMethods = 0;

    if ([_delegate respondsToSelector:@selector(libraryController:addLibraryObject:count:)])
        _implementedDelegateMethods |= NULibraryViewControllerDelegate_libraryController_addLibraryObject_count_;
}

- (void)sendDelegateAddObject:(id)anObject count:(CPNumber)aCount
{
    if (_implementedDelegateMethods & NULibraryViewControllerDelegate_libraryController_addLibraryObject_count_)
        [_delegate libraryController:self addLibraryObject:anObject count:aCount];
}


#pragma mark -
#pragma mark Actions

- (void)_didDoubleClickOnTableView:(id)aSender
{
    var selectedObject = [_dataSourceLibrary objectAtIndex:[tableViewLibrary selectedRow]],
        multiplier     = [self multiplierValue];

    [self sendDelegateAddObject:selectedObject count:multiplier];

    [self setMultiplierValue:1];
}

- (@action)updateFieldMultiplier:(id)aSender
{
    if ([aSender intValue] > 20)
    {
        [labelMultiplierError setHidden:NO];
        [aSender setStringValue:@"20"];
    }
    else
        [labelMultiplierError setHidden:YES];
}


#pragma mark -
#pragma mark Table View Delegates and DataSources

- (int)tableView:(CPTabView)aTableView heightOfRow:(int)aRow
{
    return [[[NUKit kit] registeredDataViewWithIdentifier:@"libraryItemDataView"] frameSize].height;
}

- (CPView)tableView:(CPTabView)aTableView viewForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    var key = @"NULibraryItem",
        view = [aTableView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        view = [[[NUKit kit] registeredDataViewWithIdentifier:@"libraryItemDataView"] duplicate];
        [view setAutoresizingMask:CPViewNotSizable];
        [view setIdentifier:key];
    }

    return view;
}

- (void)dataSource:(TNTableViewDataSource)aDataSource writeRowsWithIndexes:(CPIndexSet)indexes toPasteboard:(CPPasteboard)aPasteboard
{
    var draggedObject = [[aDataSource objectsAtIndexes:indexes] firstObject];
    [aPasteboard declareTypes:[NULibraryItemDraggingType] owner:nil];
    [aPasteboard setData:draggedObject forType:NULibraryItemDraggingType];

    [[CPCursor arrowCursor] set];
    return CPDragOperationCopy;
}


#pragma mark -
#pragma mark Split View Delegates

- (float)splitView:(CPSplitView)aSplitView constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)subviewIndex
{
    return _isVisible ? [aSplitView frameSize].height - 19 : [aSplitView frameSize].height;
}

- (float)splitView:(CPSplitView)aSplitView constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)subviewIndex
{
    return _isVisible ? 24 : [aSplitView frameSize].height;
}

@end



@implementation NULibraryTableView : CPTableView

- (CPView)dragViewForRowsWithIndexes:(CPIndexSet)theDraggedRows tableColumns:(CPArray)theTableColumns event:(CPEvent)theDragEvent offset:(CGPoint)dragViewOffset
{
    var column   = [theTableColumns firstObject],
        row      = [theDraggedRows firstIndex],
        dataView = [self _newDataViewForRow:row tableColumn:column];

    [self _setObjectValueForTableColumn:column row:row forView:dataView];

    return [dataView draggingImageView];
}

- (void)mouseEntered:(CPEvent)anEvent
{
    [[CPCursor closedHandCursor] set];
    [super mouseEntered:anEvent];
}

- (void)mouseMoved:(CPEvent)anEvent
{
    [[CPCursor closedHandCursor] set];
    [super mouseEntered:anEvent];
}

- (void)mouseExited:(CPEvent)anEvent
{
    [[CPCursor arrowCursor] set];
    [super mouseEntered:anEvent];
}

- (void)mouseDown:(CPEvent)anEvent
{
    [[CPCursor closedHandCursor] set];
    [super mouseDown:anEvent];
}

@end
