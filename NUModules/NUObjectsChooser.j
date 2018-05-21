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
@import <TNKit/TNTableViewDataSource.j>

@import "NUModule.j"

@class NUKit

var NUObjectsChooser_categoryForObject_                 = 1 << 1,
    NUObjectsChooser_currentActiveContextsForChooser_   = 1 << 2,
    NUObjectsChooser_didObjectChooserCancelSelection_   = 1 << 3,
    NUObjectsChooser_didObjectChooser_selectObjects_    = 1 << 4;

/*! NUObjectChooser is a module used to retrieve a set of objects,
    and let the user select one or more objects. When the selection is
    done, a delegate method will be called to let it decide what to do
    with the selected objects.

    This often only used internally by modules like NUModuleAssignation
    or by the Associators.

    YOU MUST CREATE THIS MODULE PROGRAMMATICALLY using the + (id)new API
*/
@implementation NUObjectsChooser : NUModule
{
    @outlet CPButton        buttonSelect;
    @outlet CPPopUpButton   buttonAdditionalInfo;

    BOOL                    _hidesDataViewsControls             @accessors(property=hidesDataViewsControls);
    CPArray                 _currentActiveContextIdentifiers    @accessors(property=currentActiveContextIdentifiers);
    CPArray                 _ignoredObjects                     @accessors(property=ignoredObjects);
    CPArray                 _searchableKeyPaths                 @accessors(property=searchableKeyPaths);
    CPPredicate             _displayFilter                      @accessors(property=displayFilter);
    id                      _userInfo                           @accessors(property=userInfo);

    int                     _implementedDelegateMethods;
}


#pragma mark -
#pragma mark Initialization

/*! Creates a new NUObjectsChooser
*/
+ (id)new
{
    var obj = [[self alloc] initWithCibName:@"ObjectSelector" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]];

    [obj view];

    return obj;
}

/*! @ignore
*/
+ (BOOL)automaticSelectionSaving
{
    return NO;
}

/*! @ignore
*/
+ (BOOL)commitFetchedObjects
{
    return YES;
}

/*! @ignore
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    _currentActiveContextIdentifiers   = []
    _hidesDataViewsControls     = YES;

    [fieldModuleTitle setTextColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"chooser-popover-banner-foreground"]];
    [[fieldModuleTitle superview] setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"chooser-popover-banner-background"]];

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

/*! @ignore
*/
- (CPArray)configureContextualMenu
{
    return nil;
}


#pragma mark -
#pragma mark Configuration

/*! Add CPMenuItem to the option additional info button
*/
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

/*! Returns the selected CPMenuItem from the additional info button
*/
- (CPMenuItem)selectedAdditionalInfo
{
    return [buttonAdditionalInfo selectedItem];
}

/*! Sets if multiple selection should be allowed
*/
- (void)setAllowsMultipleSelection:(BOOL)isMultipleSelections
{
    [tableView setAllowsMultipleSelection:isMultipleSelections];
}

/*! Sets the title of the selection button
*/
- (void)setButtonTitle:(CPString)aTitle
{
    [buttonSelect setTitle:aTitle];
}


#pragma mark -
#pragma mark NUObjectsChooser API

/*! configure the fetcher key path to use in the currentParent in order to retrieve the list
    of children with the given class.
*/
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

/*! @ignore
*/
- (void)fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didFetchContent:(CPArray)someContents
{
    [someContents removeObjectsInArray:_ignoredObjects];

    if (_displayFilter)
        someContents = [someContents filteredArrayUsingPredicate:_displayFilter];

    [super fetcher:aFetcher ofObject:anObject didFetchContent:someContents];
}


#pragma mark -
#pragma mark Actions

/*! @ignore
*/
- (@action)selectCurrentObjects:(id)aSender
{
    if ([tableView numberOfSelectedRows] == 0)
        return;

    var selectedObjects = [self currentSelectedObjects];
    [self _sendDelegateDidObjectChooserSelectedObjects:selectedObjects];

    if (filterField)
        [filterField setStringValue:@""];
}


#pragma mark -
#pragma mark NUModule Delegates

/*! @ignore
*/
- (void)moduleDidSelectObjects:(CPArray)someObject
{
    [super moduleDidSelectObjects:someObject];
    [buttonSelect setEnabled:[someObject count] >= 1];
}

/*! @ignore
*/
- (void)didShowGettingStartedView:(BOOL)didShow
{
    [buttonSelect setHidden:didShow];
}

/*! @ignore
*/
- (NUCategory)categoryForObject:(NUVSDObject)anObject
{
    return [self _sendDelegateCategoryForObject:anObject];
}

/*! @ignore
*/
- (CPArray)moduleCurrentActiveContexts
{
    return [self _sendDelegateCurrentActiveContextsForChooser];
}


#pragma mark -
#pragma mark Overrides

/*! @ignore
*/
- (void)setCurrentParent:(id)aParent
{
    // we create a copy, so we won't be discarding the real parent objects when we close the popover
    [super setCurrentParent:[aParent duplicate]];
}

/*! @ignore
*/
- (void)popoverWillShow:(CPPopover)aPopover
{
    [super popoverWillShow:aPopover];
    [buttonSelect setEnabled:NO];
}

/*! @ignore
*/
- (void)popoverDidClose:(CPPopover)aPopover
{
    [super popoverDidClose:aPopover];

    if ([[self currentSelectedObjects] count])
        return;

    [self _sendDelegateDidObjectChooserCancelSelection];
}


#pragma mark -
#pragma mark Delegate

/*! Sets the Delegate

    - (NUCategory)categoryForObject:(NUObjectChooser)aChooser
    - (CPArray)currentActiveContextsForChooser:(NUObjectChooser)aChooser
    - (void)didObjectChooserCancelSelection:(NUObjectChooser)aChooser
    - (void)didObjectChooser:(NUObjectChooser)aChooser selectObjects:(CPArray)selectedObjects
*/
- (void)setDelegate:(id)aDelegate
{
    if (_delegate === aDelegate)
        return;

    _delegate = aDelegate;
    _implementedDelegateMethods = 0;

    if ([_delegate respondsToSelector:@selector(categoryForObject:)])
        _implementedDelegateMethods |= NUObjectsChooser_categoryForObject_;

    if ([_delegate respondsToSelector:@selector(currentActiveContextsForChooser:)])
        _implementedDelegateMethods |= NUObjectsChooser_currentActiveContextsForChooser_;

    if ([_delegate respondsToSelector:@selector(didObjectChooserCancelSelection:)])
        _implementedDelegateMethods |= NUObjectsChooser_didObjectChooserCancelSelection_;

    if ([_delegate respondsToSelector:@selector(didObjectChooser:selectObjects:)])
        _implementedDelegateMethods |= NUObjectsChooser_didObjectChooser_selectObjects_;
}

/*! @ignore
*/
- (CPArray)_sendDelegateCategoryForObject:(NURESTObject)anObject
{
    if (_implementedDelegateMethods & NUObjectsChooser_categoryForObject_)
        return [_delegate categoryForObject:anObject];

    return [super categoryForObject:anObject];
}

/*! @ignore
*/
- (CPArray)_sendDelegateCurrentActiveContextsForChooser
{
    if (_implementedDelegateMethods & NUObjectsChooser_currentActiveContextsForChooser_)
        return [_delegate currentActiveContextsForChooser:self];

    return [super moduleCurrentActiveContexts];
}

/*! @ignore
*/
- (void)_sendDelegateDidObjectChooserCancelSelection
{
    if (_implementedDelegateMethods & NUObjectsChooser_didObjectChooserCancelSelection_)
        [_delegate didObjectChooserCancelSelection:self];
}

/*! @ignore
*/
- (void)_sendDelegateDidObjectChooserSelectedObjects:(CPArray)selectedObjects
{
    if (_implementedDelegateMethods & NUObjectsChooser_didObjectChooser_selectObjects_)
        [_delegate didObjectChooser:self selectObjects:selectedObjects];
}

@end
