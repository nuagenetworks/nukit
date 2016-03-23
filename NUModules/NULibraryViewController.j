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


/*! NULibraryViewController is a class that allows to create and manipulate
    a library of objects, a la Xcode.
    NULibraryViewController MUST NOT be created from a XIB file.
    They MUST be created using [NULibraryViewController new] API programatically.
*/
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

/*! Creates and returns a new NULibraryViewController
*/
+ (id)new
{
    var obj = [[self alloc] initWithCibName:@"Library" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]];

    [obj view];

    return obj;
}

/*! Creates and returns a new NULibraryViewController with a given delegate and a given split view container.
*/
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

/*! @ignore
*/
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

/*! Sets the content of the library.
    It must be a CPArray of NULibraryItems
*/
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

/*! Registers an array of CPLibraryItems for a given identifier
*/
- (void)registerContent:(CPArray)aContent forIdentifier:(CPString)anIdentifier
{
    [_contentRegistry setObject:aContent forKey:anIdentifier];
}

/*! Returns the registered content associated with the given identifier
*/
- (CPArray)registeredContentWithIdentifier:(CPString)anIdentifier
{
    return [_contentRegistry objectForKey:anIdentifier];
}

/*! Make the registered content associated with the given identifier the current content.
*/
- (void)setCurrentContentWithIdentifier:(CPString)anIdentifier
{
    [self setContent:[self registeredContentWithIdentifier:anIdentifier]];
}


#pragma mark -
#pragma mark Multiplier Management

/*! Hides the multiplier field
*/
- (void)setMultiplierHidden:(BOOL)shouldHide
{
    [fieldMultiplier setHidden:shouldHide];
    [labelMultiplierError setHidden:shouldHide];
    [labelMultiplier setHidden:shouldHide];
}

/*! Returns the multiplier value
*/
- (int)multiplierValue
{
    var multiplier = [fieldMultiplier intValue];

    if (!multiplier || multiplier <= 0)
        multiplier = 1;

    return MIN(20, multiplier);
}

/*! Sets the multiplier value
*/
- (void)setMultiplierValue:(int)aValue
{
    [fieldMultiplier setIntValue:aValue];
}


#pragma mark -
#pragma mark Split View Management

/*! Set the split view containing the library
*/
- (void)setSplitView:(CPSplitView)aSplitView
{
    _splitView = aSplitView;
    [_splitView setDelegate:self];
}


#pragma mark -
#pragma mark Visibility Management

/*! Shows the library (uncollapse the split view)
*/
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

/*! Sets the Delegate

    - (void)libraryController:(NULibraryViewController)aLibrary addLibraryObject:(NULibraryItem)anItem count:(CPNumber)aCount
*/
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

/*! @ignore
*/
- (void)_didDoubleClickOnTableView:(id)aSender
{
    var selectedObject = [_dataSourceLibrary objectAtIndex:[tableViewLibrary selectedRow]],
        multiplier     = [self multiplierValue];

    [self sendDelegateAddObject:selectedObject count:multiplier];

    [self setMultiplierValue:1];
}

/*! @ignore
*/
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

/*! @ignore
*/
- (int)tableView:(CPTabView)aTableView heightOfRow:(int)aRow
{
    return [[[NUKit kit] registeredDataViewWithIdentifier:@"libraryItemDataView"] frameSize].height;
}

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (float)splitView:(CPSplitView)aSplitView constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)subviewIndex
{
    return _isVisible ? [aSplitView frameSize].height - 19 : [aSplitView frameSize].height;
}

/*! @ignore
*/
- (float)splitView:(CPSplitView)aSplitView constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)subviewIndex
{
    return _isVisible ? 24 : [aSplitView frameSize].height;
}

@end


/*! @ignore
*/
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
