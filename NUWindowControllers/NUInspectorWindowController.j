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
@import <AppKit/CPWindowController.j>
@import <AppKit/CPTableColumn.j>
@import <AppKit/CPWebView.j>
@import <TNKit/TNTableViewDataSource.j>
@import <TNKit/TNTabView.j>
@import <Bambou/NURESTPushCenter.j>
@import <Bambou/NURESTLoginController.j>
@import <Bambou/NURESTModelController.j>

@import "NUSkin.j"
@import "NUModule.j"

@class NUKit

@global CPApp
@global NUNullToNoInformationTransformerName
@global NUPushEventTypeDelete
@global NUPushEventTypeUpdate
@global NUPushEventTypeRevoke


var NUInspectorWindowsRegistry = @{},
    NUInspectorWindowAdditionalModuleClasses = @{};

#define VERTICAL_LINE_SIZE_HEIGHT 14


@implementation NUInspectorWindowController : CPWindowController
{
    @outlet CPTableView                 tableViewAttributes;
    @outlet CPTableView                 tableViewGenealogy;
    @outlet CPTextField                 fieldObjectCreationDate;
    @outlet CPTextField                 fieldObjectExternalID;
    @outlet CPTextField                 fieldObjectID;
    @outlet CPTextField                 fieldObjectLastUpdatedBy;
    @outlet CPTextField                 fieldObjectLastUpdatedDate;
    @outlet CPTextField                 fieldObjectName;
    @outlet CPTextField                 fieldObjectOwner;
    @outlet CPTextField                 fieldObjectParentID;
    @outlet CPTextField                 fieldObjectParentType;
    @outlet CPTextField                 fieldObjectRESTName;
    @outlet CPView                      viewTabInformation;
    @outlet TNTabView                   tabViewMain;

    int                                 _openingOffset      @accessors(property=openingOffset);
    id                                  _inspectedObject    @accessors(property=inspectedObject);

    BOOL                                _isListeningForPush;
    CPArray                             _genealogy;
    CPTabViewItem                       _tabViewItemInfo;
    CPView                              _dataViewPrototype;
    id                                  _rootObject;
    TNTableViewDataSource               _dataSourceAttributes;
    TNTableViewDataSource               _dataSourceGenealogy;
}


#pragma mark -
#pragma mark Class Methods

+ (BOOL)isInspectorOpenedForObjectWithID:(CPString)anID
{
    return [NUInspectorWindowsRegistry containsKey:anID];
}

+ (id)inspectorForObjectWithID:(CPString)anID
{
    return [NUInspectorWindowsRegistry objectForKey:anID];
}

+ (void)flushInspectorRegistry
{
    NUInspectorWindowsRegistry = @{};
}

+ (void)registerAdditionalModuleClass:(Class)aClass cibName:(CPString)aCibName displayDecisionFunction:(Function)aFunction
{
    var info = @{"moduleClass": aClass, "decisionFunction": aFunction, "cibName": aCibName};
    [NUInspectorWindowAdditionalModuleClasses setObject:info forKey:[aClass moduleIdentifier]];
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super initWithWindowCibName:@"InspectorWindow"])
    {
        _openingOffset     = [NUInspectorWindowsRegistry count];
        _dataViewPrototype = [[[NUKit kit] registeredDataViewWithIdentifier:@"genealogyDataView"] duplicate];
    }

    return self;
}

- (void)windowDidLoad
{
    var platformWindow = [[CPPlatformWindow alloc] initWithWindow:[self window]],
        contentView = [[self window] contentView];

    [[self window] setDelegate:self];

    _dataSourceGenealogy = [[TNTableViewDataSource alloc] init];
    [_dataSourceGenealogy setTable:tableViewGenealogy];
    [tableViewGenealogy setDataSource:_dataSourceGenealogy];
    [tableViewGenealogy setDelegate:self];
    [tableViewGenealogy setIntercellSpacing:CGSizeMakeZero()];
    [tableViewGenealogy setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleNone];
    [tableViewGenealogy setBackgroundColor:NUSkinColorBlack];
    [tableViewGenealogy setDoubleAction:@selector(openAnotherInspector:)];
    [tableViewGenealogy setTarget:self];
    [[tableViewGenealogy enclosingScrollView] setBorderColor:NUSkinColorGrey];

    _dataSourceAttributes = [[TNTableViewDataSource alloc] init];
    [_dataSourceAttributes setTable:tableViewAttributes];
    [tableViewAttributes setDataSource:_dataSourceAttributes];
    [tableViewAttributes setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleRegular];
    [tableViewAttributes setBackgroundColor:NUSkinColorWhite]
    [[tableViewAttributes enclosingScrollView] setBorderColor:NUSkinColorGrey];

    [tabViewMain setDelegate:self];
    _configure_nuage_tabview(tabViewMain, NO);

}


#pragma mark -
#pragma mark Bindings

- (void)_bindControls
{
    var noInfoTransformer = @{CPValueTransformerNameBindingOption: NUNullToNoInformationTransformerName};
    [fieldObjectID bind:CPValueBinding toObject:self withKeyPath:@"inspectedObject.ID" options:noInfoTransformer];
    [fieldObjectExternalID bind:CPValueBinding toObject:self withKeyPath:@"inspectedObject.externalID" options:noInfoTransformer];
    [fieldObjectCreationDate bind:CPValueBinding toObject:self withKeyPath:@"inspectedObject.formatedCreationDate" options:noInfoTransformer];
    [fieldObjectParentType bind:CPValueBinding toObject:self withKeyPath:@"inspectedObject.parentType" options:noInfoTransformer];
    [fieldObjectParentID bind:CPValueBinding toObject:self withKeyPath:@"inspectedObject.parentID" options:noInfoTransformer];
    [fieldObjectLastUpdatedDate bind:CPValueBinding toObject:self withKeyPath:@"inspectedObject.formatedLastUpdatedDate" options:noInfoTransformer];
    [fieldObjectName bind:CPValueBinding toObject:self withKeyPath:@"inspectedObject.name" options:noInfoTransformer];
    [fieldObjectLastUpdatedBy bind:CPValueBinding toObject:self withKeyPath:@"inspectedObject.lastUpdatedBy" options:nil];

    [fieldObjectOwner setStringValue:[_inspectedObject owner] || @"system"];
}

- (void)_unbindControls
{
    [fieldObjectID unbind:CPValueBinding];
    [fieldObjectExternalID unbind:CPValueBinding];
    [fieldObjectCreationDate unbind:CPValueBinding];
    [fieldObjectParentType unbind:CPValueBinding];
    [fieldObjectParentID unbind:CPValueBinding];
    [fieldObjectLastUpdatedDate unbind:CPValueBinding];
    [fieldObjectName unbind:CPValueBinding];
    [fieldObjectLastUpdatedBy unbind:CPValueBinding];
}


#pragma mark -
#pragma mark REST Attributes

- (void)_reloadAttributes
{
    var attributes = [[_inspectedObject RESTAttributes] allKeys].sort(),
        ignoreList = ["ID", "externalID", "creationDate", "owner", "parentType", "parentID", "lastUpdatedBy", "lastUpdatedDate"],
        content = [];

    for (var i = 0; i < [attributes count]; i++)
    {
        var attr = attributes[i];

        if ([ignoreList containsObject:attr])
            continue;

        var value = [_inspectedObject valueForKeyPath:attr];

        if (value === nil)
            value = @"null";

        [content addObject:@{@"attribute": attr, @"value": value}];
    }

    [_dataSourceAttributes setContent:content];
    [tableViewAttributes reloadData];
}


#pragma mark -
#pragma mark Genealogy Management

- (void)_prepareGenealogy
{
    _genealogy = [_inspectedObject];
    [self _genealogyOfObject:_inspectedObject];
}

- (void)_genealogyOfObject:(id)anObject
{
    if (![anObject parentType] || ![anObject parentID])
    {
        [self _reloadGenealogy];
        return;
    }

    var parentObject = [[[NURESTModelController defaultController] modelClassForRESTName:[anObject parentType]] new];
    [parentObject setID:[anObject parentID]];

    [parentObject fetchAndCallSelector:@selector(_didFetchParent:connection:) ofObject:self];
}

- (void)_didFetchParent:(id)anObject connection:(NURESTConnection)aConnection
{
    [_genealogy addObject:anObject];
    [self _genealogyOfObject:anObject];
}

- (void)_reloadGenealogy
{
    _genealogy.reverse();
    [_dataSourceGenealogy setContent:_genealogy];
    [tableViewGenealogy reloadData];
}


#pragma mark -
#pragma mark Tab View

- (void)_prepareTabViewItems
{
    var tabViewItemInspector = [[CPTabViewItem alloc] initWithIdentifier:@"info"];
    [tabViewItemInspector setLabel:@"Info"];
    [tabViewItemInspector setView:viewTabInformation];
    [tabViewMain addTabViewItem:tabViewItemInspector];

    for (var i = [[NUInspectorWindowAdditionalModuleClasses allValues] count] - 1; i >= 0; i--)
    {
        var info             = [NUInspectorWindowAdditionalModuleClasses allValues][i],
            moduleClass      = [info objectForKey:@"moduleClass"],
            moduleCibName    = [info objectForKey:@"cibName"],
            decisionFunction = [info objectForKey:@"decisionFunction"];

        if (!decisionFunction(_inspectedObject))
            continue;

        var tabViewItem = [[CPTabViewItem alloc] initWithIdentifier:[moduleClass moduleIdentifier]],
            module      = [[moduleClass alloc] initWithCibName:moduleCibName bundle:[CPBundle mainBundle]];

        [[module view] setFrame:[viewTabInformation bounds]];

        [tabViewItem setLabel:[moduleClass moduleName]];
        [tabViewItem setRepresentedObject:module];
        [tabViewItem setView:[module view]];

        [tabViewMain addTabViewItem:tabViewItem];
    }

    [tabViewMain selectTabViewItemAtIndex:0];
}

- (void)_showModuleOfTabItem:(CPTabViewItem)anItem
{
    if ([[anItem representedObject] isKindOfClass:NUModule])
    {
        [[anItem representedObject] setCurrentParent:_inspectedObject];
        [[anItem representedObject] willShow];
    }
}

- (void)_hideModuleOfTabItem:(CPTabViewItem)anItem
{
    if ([[anItem representedObject] isKindOfClass:NUModule])
    {
        [[anItem representedObject] willHide];
        [[anItem representedObject] setCurrentParent:nil];
    }
}


#pragma mark -
#pragma mark Utilities

- (void)makeKeyInspector
{
    if ([[[self window] platformWindow] isVisible])
        [[self window] platformWindow]._DOMWindow.focus();
}


#pragma mark -
#pragma mark Actions

- (@action)openAnotherInspector:(id)aSender
{
    [[NUKit kit] openInspectorForSelectedObject];
}


#pragma mark -
#pragma mark Push Management

- (void)registerForPushNotification
{
    if (_isListeningForPush)
        return;

    _isListeningForPush = YES;

    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_didReceivePush:) name:NURESTPushCenterPushReceived object:[NURESTPushCenter defaultCenter]];
}

- (void)unregisterFromPushNotification
{
    if (!_isListeningForPush)
        return;

    _isListeningForPush = NO;

    [[CPNotificationCenter defaultCenter] removeObserver:self name:NURESTPushCenterPushReceived object:[NURESTPushCenter defaultCenter]];
}

- (void)_didReceivePush:(CPNotification)aNotification
{
    var JSONObject = [aNotification userInfo],
        events     = JSONObject.events;

    if (events.length <= 0)
        return;

    for (var i = 0, c = events.length; i < c; i++)
    {
        var eventType  = events[i].type,
            entityType = events[i].entityType,
            entityJSON = events[i].entities[0];

        if (entityType != [_inspectedObject RESTName] || entityJSON.ID != [_inspectedObject ID])
            continue;

        switch (eventType)
        {
            case NUPushEventTypeRevoke:
            case NUPushEventTypeDelete:
                [self close];
                break;

            case NUPushEventTypeUpdate:
                [self _reloadAttributes];
                break;
        }
    }
}


#pragma mark -
#pragma mark CPWindow Delegates

- (void)windowWillClose:(CPWindow)aWindow
{
    [self unregisterFromPushNotification];
    [self _hideModuleOfTabItem:[tabViewMain selectedTabViewItem]];
    [self _unbindControls];
    [NUInspectorWindowsRegistry removeObjectForKey:[_inspectedObject ID]];

    _inspectedObject = nil;
}


#pragma mark -
#pragma mark Table View Delegates

- (int)tableView:(CPTableView)aTableView heightOfRow:(int)aRow
{
    if (aRow == ([_dataSourceGenealogy count] - 1))
        return [_dataViewPrototype frameSize].height + VERTICAL_LINE_SIZE_HEIGHT;

    return [_dataViewPrototype frameSize].height;
}

- (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    var item = [_dataSourceGenealogy objectAtIndex:aRow],
        key  = [item isKindOfClass:NURESTObject] ? [item RESTName] : [item UID],
        view = [aTableView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        view = [_dataViewPrototype duplicate];
        [view setIdentifier:key];
    }

    return view;
}


#pragma mark -
#pragma mark TNtabView Delegates

- (void)tabView:(TNTabView)aTabView willSelectTabViewItem:(CPTabViewItem)anItem
{
    [self _hideModuleOfTabItem:[tabViewMain selectedTabViewItem]];
}

- (void)tabView:(TNTabView)aTabView didSelectTabViewItem:(CPTabViewItem)anItem
{
    [self _showModuleOfTabItem:anItem];
}


#pragma mark -
#pragma mark Overrides

- (void)showWindow:(id)aSender
{
    if (!_inspectedObject)
        return;

    if ([[self window] isVisible])
        return;

    [self _prepareTabViewItems];
    [self _prepareGenealogy];
    [self _reloadAttributes];

    [fieldObjectRESTName setStringValue:[[_inspectedObject class] RESTName]];

    [super showWindow:nil];

    [NUInspectorWindowsRegistry setObject:self forKey:[_inspectedObject ID]];

    var commonName = @"";

    if ([_inspectedObject respondsToSelector:@selector(name)])
        commonName = @" - " + [_inspectedObject name];

    [[self window] setTitle:@"Inspector - " + [[_inspectedObject class] RESTName] + commonName];

    [self registerForPushNotification];
    [self _bindControls];
}

- (void)loadWindow
{
    if (_window)
        return;

    [[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"] loadCibFile:[self windowCibPath] externalNameTable:@{ CPCibOwner: _cibOwner }];
}

- (CPString)windowCibPath
{
    if (_windowCibPath)
        return _windowCibPath;

    return [[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"] pathForResource:_windowCibName + @".cib"];
}

@end
