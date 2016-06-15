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
@import <AppKit/CPView.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPButton.j>
@import <Bambou/NURESTModelController.j>

@import "NUObjectsChooser.j"

@class NUKit
@class NURESTModelController


var NUAbstractObjectsAssignationLinkImage          = CPImageInBundle("button-link.png", 12.0, 12.0, [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]),
    NUAbstractObjectsAssignationLinkPressedImage   = CPImageInBundle("button-link-pressed.png", 12.0, 12.0, [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]),
    NUAbstractObjectsAssignationUnLinkImage        = CPImageInBundle("button-unlink.png", 12.0, 12.0, [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]),
    NUAbstractObjectsAssignationUnLinkPressedImage = CPImageInBundle("button-unlink-pressed.png", 12.0, 12.0, [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]);

var NUAbstractObjectsAssignation_didAssignObjects_      = 1 << 1,
    NUAbstractObjectsAssignation_didUnassignObjects_    = 1 << 2;

NUObjectsAssignationDisplayModeDataView = 1;
NUObjectsAssignationDisplayModeText     = 2;

var BUTTONS_SIZE = 12;

NUObjectsAssignationSettingsDataViewNameKey   = @"NUObjectsAssignationSettingsDataViewNameKey";
NUObjectsAssignationSettingsFetcherKeyPathKey = @"NUObjectsAssignationSettingsFetcherKeyPathKey";

/*! NUAbstractObjectsAssignation is the base class of assignation control
    An Assignation is a control that can let the user select one or multiple objects,
    and add IDs of selected objects in an array of its current parent.

    You should not use this class directly. Instead, you should implement this class
    and define all protocol methods.
*/
@implementation NUAbstractObjectsAssignation : CPViewController <CPTableViewDelegate>
{
    @outlet CPTableView         tableView;
    @outlet CPView              viewAssignationContainer;
    @outlet CPView              viewEmptyAssignationMask;
    @outlet CPView              viewTableViewContainer;

    BOOL                        _assignationButtonHidden    @accessors(property=assignationButtonHidden);
    BOOL                        _controlButtonsHidden       @accessors(property=controlButtonsHidden);
    BOOL                        _hasAssignedObjects         @accessors(getter=hasAssignedObjects);
    BOOL                        _hidesDataViewsControls     @accessors(property=hidesDataViewsControls);
    BOOL                        _modified                   @accessors(property=modified);
    BOOL                        _unassignButtonHidden       @accessors(property=unassignButtonHidden);
    CPArray                     _currentAssignedObjects     @accessors(property=currentAssignedObjects);
    CPArray                     _currentSelectedObjects     @accessors(property=currentSelectedObjects);
    id                          _currentParent              @accessors(property=currentParent);
    id                          _delegate                   @accessors(property=delegate);
    int                         _displayMode                @accessors(property=displayMode);

    BOOL                        _isFetching;
    BOOL                        _isListeningForPush;
    CPArray                     _activeTransactionsIDs;
    CPButton                    _buttonChooseAssignObjects;
    CPButton                    _buttonUnassignObjects;
    CPTextField                 _fieldAssignedObjectText;
    CPView                      _dataViewAssignedObject;
    CPView                      _innerButtonContainer;
    CPView                      _viewButtonsContainer;
    id                          _dataSource;
    int                         _implementedDelegateMethods;
    NUObjectsChooser            _assignedObjectChooser;
}


#pragma mark -
#pragma mark Initialization

/*! @ignore
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    _currentAssignedObjects = [];
    _currentSelectedObjects = [];
    _hidesDataViewsControls = YES;

    var view      = [self view],
        frameSize = [view frameSize];

    [view setBackgroundColor:NUSkinColorWhite];
    [view setBorderColor:NUSkinColorGrey];

    _assignedObjectChooser = [NUObjectsChooser new];
    [_assignedObjectChooser view];
    [_assignedObjectChooser setDelegate:self];
    [_assignedObjectChooser setAllowsMultipleSelection:YES];

    [self _configureObjectsChooser];

    // VIEW INITIALIZATION

    // View that contains buttons
    _viewButtonsContainer = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    [_viewButtonsContainer setBackgroundColor:NUSkinColorGreyLight];
    [_viewButtonsContainer setAutoresizingMask:CPViewHeightSizable];
    [_viewButtonsContainer setBorderRightColor:NUSkinColorGrey];
    [viewAssignationContainer addSubview:_viewButtonsContainer];

    // View really containing the buttons for easier positioning
    _innerButtonContainer = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    [_innerButtonContainer setAutoresizingMask:CPViewMinYMargin | CPViewMaxYMargin];
    [_viewButtonsContainer addSubview:_innerButtonContainer];

    // Button add association
    _buttonChooseAssignObjects = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, BUTTONS_SIZE, BUTTONS_SIZE)];
    [_buttonChooseAssignObjects setTarget:self];
    [_buttonChooseAssignObjects setAction:@selector(openAssociatedObjectChooser:)];
    [_buttonChooseAssignObjects setBordered:NO];
    [_buttonChooseAssignObjects setButtonType:CPMomentaryChangeButton];
    [_buttonChooseAssignObjects setValue:NUAbstractObjectsAssignationLinkImage forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_buttonChooseAssignObjects setValue:NUAbstractObjectsAssignationLinkPressedImage forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    [_buttonChooseAssignObjects setToolTip:@"Assign one or multiple objects"];
    [_buttonChooseAssignObjects bind:CPHiddenBinding toObject:self withKeyPath:@"assignationButtonHidden" options:nil];
    [_innerButtonContainer addSubview:_buttonChooseAssignObjects];
    _cucappID(_buttonChooseAssignObjects, [self className] + @"-button-assign-objects");

    // Button remove association
    _buttonUnassignObjects = [[CPButton alloc] initWithFrame:CGRectMake(0, 14, BUTTONS_SIZE, BUTTONS_SIZE)];
    [_buttonUnassignObjects setTarget:self];
    [_buttonUnassignObjects setAction:@selector(removeSelectedObjects:)];
    [_buttonUnassignObjects setBordered:NO];
    [_buttonUnassignObjects setButtonType:CPMomentaryChangeButton];
    [_buttonUnassignObjects setValue:NUAbstractObjectsAssignationUnLinkImage forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_buttonUnassignObjects setValue:NUAbstractObjectsAssignationUnLinkPressedImage forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    [_buttonUnassignObjects setToolTip:@"Unassign selected objects"];
    [_buttonUnassignObjects bind:CPHiddenBinding toObject:self withKeyPath:@"unassignButtonHidden" options:nil];
    [_innerButtonContainer addSubview:_buttonUnassignObjects];
    _cucappID(_buttonUnassignObjects, [self className] + @"-button-unassign-objects");

    // TableView & DataSource
    _dataSource = [[TNTableViewDataSource alloc] init];
    [_dataSource setDelegate:self];

    _cucappID(tableView, [self className]);

    [tableView setIntercellSpacing:CGSizeMakeZero()];
    [tableView setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"tableview-view-background"]]; // white
    [tableView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleRegular];

    if ([[tableView tableColumns] count])
        [[[tableView tableColumns] firstObject] setMaxWidth:1000000];

    [_dataSource setTable:tableView];
    [tableView setDataSource:_dataSource];
    [tableView setDelegate:self];
    [tableView setTarget:self];
    [tableView setAllowsMultipleSelection:YES];

    // View empty mask
    if (viewEmptyAssignationMask)
        [viewEmptyAssignationMask setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    // Field that displays the a textual mode
    _fieldAssignedObjectText = [CPTextField labelWithTitle:@""];
    [_fieldAssignedObjectText setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [self setControlButtonsHidden:NO];

    // set default view mode only if it's not already set to something
    if (!_displayMode)
        [self setDisplayMode:[self defaultDisplayMode]];
}


#pragma mark -
#pragma mark Protocol

/*! Overrides this to change the mode.
    You can set NUObjectsAssignationDisplayModeDataView or NUObjectsAssignationDisplayModeText
*/
- (CPString)defaultDisplayMode
{
    return NUObjectsAssignationDisplayModeDataView;
}


/*! Override this to define the title of the NUObjectsChooser
    used to select the associated object.

    For instance "Select Task"
*/
- (CPString)titleForObjectChooser
{
    throw ("implement me");
}

/*! Override this to define the name of the attribute that holds
    the IDs in the current parent.
*/
- (CPString)keyPathForAssignedObjectIDs
{
    throw ("implement me");
}

/*! Overrides this to provide the object that needs to be
    used to to fetch the assigned objects.

    For instance [NURESTUser default]
*/
- (id)parentOfAssignedObjects
{
    throw ("implement me");
}

/*! Override this to provide an optional request filter
*/
- (CPPredicate)filterObjectPredicate
{
    return nil;
}

/*! Override this to provide an optional display filter
*/
- (CPPredicate)displayObjectPredicate
{
    return nil;
}

/*! @ignore
*/
- (CPString)assignedObjectNameKeyPath
{
    return @"name";
}

/*! Override this to provide the identifiers of the active contexts
*/
- (CPArray)currentActiveContextIdentifiers
{
    throw ("implement me");
}

/*! Override this to provide the assignation settings.
    Settings is a CPDictionary looking like

    @{
        [SDTask RESTName]: @{
            NUObjectsAssignationSettingsDataViewNameKey: @"taskDataView",
            NUObjectsAssignationSettingsFetcherKeyPathKey: @"tasks"
        }
    }
*/
- (CPDictionary)assignationSettings
{
    throw ("implement me");
}


#pragma mark -
#pragma mark Internal Subclass Delegates

/*! @ignore
*/
- (void)didFetchAssignedObject:(id)anObject
{
}

/*! @ignore
*/
- (void)didFetchAvailableAssignedObjects:(CPArray)someObjects
{
}

/*! @ignore
*/
- (void)didSetCurrentParent:(id)aParent
{
}


#pragma mark -
#pragma mark Getters and Setters

/*! @ignore
*/
- (void)setCurrentParent:(id)aParent
{
    if (_currentParent == aParent)
        return;

    if (_currentParent)
    {
        [self _unregisterFromPushNotification];
        [self _unregisterFromAssignationKeyChanges]
        [self closePopover];
    }

    _currentParent = aParent;

    [self setModified:NO];

    if (_currentParent)
    {
        [self _registerForPushNotification];
        [self _registerForAssignationKeyChanges];
        [self _fetchObjects:[_currentParent valueForKeyPath:[self keyPathForAssignedObjectIDs]]];
        [_buttonUnassignObjects setHidden:YES];
    }
    else
        [self _reset];


    [self didSetCurrentParent:_currentParent];
}

/*! Sets if the assignation should be enabled or disabled
*/
- (void)setEnabled:(BOOL)shouldEnable
{
    [self setEnableAssignation:shouldEnable];
    [self setEnableUnassignation:shouldEnable];
}

/*! Sets if the assignation button should be enabled
*/
- (void)setEnableAssignation:(BOOL)shouldEnable
{
    [_buttonChooseAssignObjects setEnabled:shouldEnable];
}

/*! Sets if the disassociation button should be enabled
*/
- (void)setEnableUnassignation:(BOOL)shouldEnable
{
    [_buttonUnassignObjects setEnabled:shouldEnable];
}

/*! Returns if the associator has an associated object
*/
- (BOOL)hasAssignedObjects
{
    return ![_currentAssignedObjects count];
}

/*! Close the NUObjectsChooser popover
*/
- (CPPopover)closePopover
{
    [_assignedObjectChooser closeModulePopover];
}

/*! Sets if the disassociation button should be hidden
*/
- (void)setUnassignButtonHidden:(BOOL)shouldHide
{
    if (shouldHide == _unassignButtonHidden)
        return;

    [self willChangeValueForKey:@"unassignButtonHidden"];
    _unassignButtonHidden = shouldHide;
    [self didChangeValueForKey:@"unassignButtonHidden"];

    [self view]; // force loading the view because we need to adjust the button position after initialization
    [self _repositionAssignButton];
}

/*! Sets if the control button bar should be hidden
    This is useful for read only.
*/
- (void)setControlButtonsHidden:(BOOL)shouldHide
{
    if (_controlButtonsHidden == shouldHide)
        return;

    _controlButtonsHidden = shouldHide;
    [_viewButtonsContainer setHidden:_controlButtonsHidden];

    if (_displayMode)
        [self _layoutAssignation];
}

/*! Update the displat mode
*/
- (void)setDisplayMode:(int)aMode
{
    if (_displayMode === aMode)
        return;

    [self willChangeValueForKey:@"displayMode"];
    _displayMode = aMode;
    [self didChangeValueForKey:@"displayMode"];

    [self _layoutAssignation];
}

/*! @ignore
*/
- (CPView)_dataViewForObject:(id)anObject
{
    var dataView;

    switch (_displayMode)
    {
        case NUObjectsAssignationDisplayModeDataView:
            dataView = [[_assignedObjectChooser registeredDataViewForClass:[anObject class]] duplicate];
            break;

        case NUObjectsAssignationDisplayModeText:
            dataView = _fieldAssignedObjectText;
            break;

        default:
            [CPException raise:CPInvalidArgumentException reason:@"display mode must be either 'NUObjectsAssignationDisplayModeDataView' or 'NUObjectsAssignationDisplayModeText"];
    }

    if (_hidesDataViewsControls && [dataView respondsToSelector:@selector(setControlsHidden:)])
        [dataView setControlsHidden:YES];

    [dataView setObjectValue:anObject];
    [dataView setBackgroundColor:NUSkinColorWhite];
    [dataView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    return dataView;
}


#pragma mark -
#pragma mark Utilities

/*! @ignore
*/
- (void)_configureObjectsChooser
{
    var settings    = [self assignationSettings],
        RESTNames   = [settings allKeys];

    for (var i = [RESTNames count] - 1; i >= 0; i--)
    {
        var RESTName            = RESTNames[i],
            defaultController   = [NURESTModelController defaultController],
            objectClass         = [defaultController modelClassForRESTName:RESTName];

        if (![settings containsKey:RESTName])
            [CPException raise:CPInternalInconsistencyException reason:"No setting defined for entity " + RESTName];

        var setting = [settings objectForKey:RESTName];

        if (![setting containsKey:NUObjectsAssignationSettingsDataViewNameKey])
            [CPException raise:CPInternalInconsistencyException reason:"No dataView defined for " + RESTName];

        if (![setting containsKey:NUObjectsAssignationSettingsFetcherKeyPathKey])
            [CPException raise:CPInternalInconsistencyException reason:"No fetcherKeyPath defined for " + RESTName];

        var dataView        = [setting objectForKey:NUObjectsAssignationSettingsDataViewNameKey],
            fetcherKeyPath  = [setting objectForKey:NUObjectsAssignationSettingsFetcherKeyPathKey];

        [_assignedObjectChooser registerDataViewWithName:dataView forClass:objectClass];
        [_assignedObjectChooser configureFetcherKeyPath:fetcherKeyPath forClass:objectClass];
    }
}

/*! Shows the loading view
*/
- (void)showLoading:(BOOL)shouldShow
{
    _isFetching = shouldShow;

    if (shouldShow)
        [[NUDataTransferController defaultDataTransferController] showFetchingViewOnView:[self view]];
    else
        [[NUDataTransferController defaultDataTransferController] hideFetchingViewFromView:[self view]];
}

/*! @ignore
*/
- (void)_removeDeletedObject:(id)anObject
{
    [_dataSource removeObject:anObject];
    var currentIDs = [_currentParent valueForKeyPath:[self keyPathForAssignedObjectIDs]];

    if ([currentIDs containsObject:[anObject ID]])
        [currentIDs removeObject:[anObject ID]];

    [tableView reloadData];
    [self _manageEmptyAssignationMask];
}

- (void)_removeObjectWithID:(CPString)anID
{
    var predicate       = [CPPredicate predicateWithFormat:@"ID = = %@", anID],
        filteredObjects = [_currentAssignedObjects filteredArrayUsingPredicate:predicate];

    if (![filteredObjects count])
        return;

    [_currentAssignedObjects removeObject:[filteredObjects first]];
    [_currentSelectedObjects removeObject:[filteredObjects first]];
    [tableView reloadData];
    [self _manageEmptyAssignationMask];
}

- (void)_reset
{
    [_currentAssignedObjects removeAllObjects];
    [_currentSelectedObjects removeAllObjects];
}

/*! @ignore
*/
- (void)_updateCurrentSelection
{
    _currentSelectedObjects = [_dataSource objectsAtIndexes:[tableView selectedRowIndexes]];
    [_buttonUnassignObjects setHidden:![_currentSelectedObjects count]];
}

/*! @ignore
*/
- (void)_fetchObjects:(CPArray)anArray
{
    [self _fetchObjects:anArray fromObjects:[]];
}

/*! @ignore
*/
- (void)_fetchObjects:(CPArray)anArray fromObjects:(CPArray)previousArray
{
    [self showLoading:YES];

    if (!anArray || ![anArray count])
    {
        [self _reset];
        [self setDataSourceContent:_currentAssignedObjects];
        return;
    }

    for (var index = [anArray count] - 1 ; index >= 0; index--)
    {
        var anID = [anArray objectAtIndex:index];

        if ([previousArray containsObject:anID])
            continue;

        [self _fetchAssignedObjectWithID:anID];
    }
    // TODO: Should we remove objects from previousArray that are not present in anArray ?

    for (var index = [previousArray count] - 1 ; index >= 0; index--)
    {
        var anID = [previousArray objectAtIndex:index];

        if ([anArray containsObject:anID])
            continue;

        [self _removeObjectWithID:anID];
    }
}

/*! @ignore
*/
- (void)_fetchAssignedObjectWithID:(CPString)anID
{
    var identifiers  = [self currentActiveContextIdentifiers],
        settings     = [self assignationSettings],
        parentObject = [self parentOfAssignedObjects];

    if ([identifiers count] == 1)
        {
            // Use a direct fetch
            var identifier  = identifiers[0],
                instance    = [[[NURESTModelController defaultController] modelClassForRESTName:identifier] new];

            [instance setID:anID];
            [instance fetchAndCallSelector:@selector(_didFetchObject:connection:) ofObject:self];
    }
    else
    {
        // Make a fetch with filter for each context
        if (!parentObject)
            return;

        for (var i = [identifiers count] - 1; i >= 0; i--)
        {
            var identifier      = identifiers[i],
                setting         = [settings objectForKey:identifier],
                fetcherKeyPath  = [setting objectForKey:NUObjectsAssignationSettingsFetcherKeyPathKey],
                fetcher         = [parentObject valueForKeyPath:fetcherKeyPath],
                predicateFilter = [CPPredicate predicateWithFormat:@"ID == %@", anID];

            [fetcher fetchWithMatchingFilter:predicateFilter
                                masterFilter:nil
                                   orderedBy:nil
                                   groupedBy:nil
                                        page:0
                                    pageSize:1
                                      commit:NO
                             andCallSelector:@selector(_fetcher:ofObject:didFetchContent:)
                                    ofObject:self
                                       block:nil];
        }
    }
}

/*! @ignore
*/
- (void)_didFetchObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (![NURESTConnection handleResponseForConnection:aConnection postErrorMessage:YES])
        return;

    [self didFetchAssignedObject:anObject];
    [_currentAssignedObjects addObject:anObject];

    // if (!_isFetching)
    [self setDataSourceContent:_currentAssignedObjects];
}

/*! @ignore
*/
- (void)setDataSourceContent:(CPArray)contents
{
    [self showLoading:NO];
    [self _manageEmptyAssignationMask];

    [_dataSource setContent:contents];
    [tableView reloadData];
}


/*! @ignore
*/
- (void)_fetcher:(id)aFetcher ofObject:(NURESTObject)anObject didFetchContent:(CPArray)someContents
{
    [self setDataSourceContent:someContents];
}

- (void)_manageEmptyAssignationMask
{
    if (!viewEmptyAssignationMask)
        return;

    if (![_currentAssignedObjects count])
    {
        if (![viewEmptyAssignationMask superview])
            [tableView addSubview:viewEmptyAssignationMask];
    }
    else
    {
        if ([viewEmptyAssignationMask superview])
            [viewEmptyAssignationMask removeFromSuperview];
    }
}

/*! @ignore
*/
- (void)_repositionAssignButton
{
    var frame = [_innerButtonContainer frame];

    if ([_buttonUnassignObjects isHidden])
    {
        if (_displayMode == NUObjectsAssignationDisplayModeDataView)
            [_buttonChooseAssignObjects setFrameOrigin:CGPointMake(frame.size.width / 2 - BUTTONS_SIZE / 2, frame.size.height / 2 - BUTTONS_SIZE / 2)];
        else
            [_buttonChooseAssignObjects setFrameOrigin:CGPointMake(7, 0)];
    }
    else
        [_buttonChooseAssignObjects setFrameOrigin:CGPointMakeZero()];
}

/*! @ignore
*/
- (void)_layoutAssignation
{

    var generalFrame  = [[self view] frame],
        generalHeight = CGRectGetHeight(generalFrame),
        generalWidth  = CGRectGetWidth(generalFrame),
        generalCenter = CGPointMake(CGRectGetMidX(generalFrame), CGRectGetMidY(generalFrame));

    switch (_displayMode)
    {
        case NUObjectsAssignationDisplayModeDataView:
            [_viewButtonsContainer setFrame:CGRectMake(0, 0, 22, generalHeight)];
            [_innerButtonContainer setFrame:CGRectMake([_viewButtonsContainer frameSize].width / 2 - 6, [_viewButtonsContainer frameSize].height / 2 - 14, 12, 26)];
            [_buttonChooseAssignObjects setFrameOrigin:CGPointMake(0, 0)];
            [_buttonUnassignObjects setFrameOrigin:CGPointMake(0, 14)];
            break;

        case NUObjectsAssignationDisplayModeText:
            [_viewButtonsContainer setFrame:CGRectMake(0, 0, 37, generalHeight)];
            [_innerButtonContainer setFrame:CGRectMake([_viewButtonsContainer frameSize].width / 2 - 15, [_viewButtonsContainer frameSize].height / 2 - 7, 26, 12)];
            [_buttonChooseAssignObjects setFrameOrigin:CGPointMake(0, 0)];
            [_buttonUnassignObjects setFrameOrigin:CGPointMake(14, 0)];
            break;

        default:
            [CPException raise:CPInvalidArgumentException reason:@"display mode must be either 'NUObjectsAssignationDisplayModeDataView' or 'NUObjectsAssignationDisplayModeText"];
    }

    var viewButtonsContainerWidth = [_viewButtonsContainer isHidden] ? 0 : [_viewButtonsContainer frameSize].width;

    [viewTableViewContainer setFrame:CGRectMake(viewButtonsContainerWidth, 0, generalWidth - viewButtonsContainerWidth, generalHeight)];
    [viewEmptyAssignationMask setFrame:[viewTableViewContainer bounds]];

    [self _repositionAssignButton];
}


#pragma mark -
#pragma mark Actions

/*! Opens the NUObjectsChooser popover
*/
- (@action)openAssociatedObjectChooser:(id)aSender
{
    [_assignedObjectChooser setIgnoredObjects:_currentAssignedObjects];

    [_assignedObjectChooser setModuleTitle:[self titleForObjectChooser]];
    [_assignedObjectChooser setMasterFilter:[self filterObjectPredicate]];
    [_assignedObjectChooser setDisplayFilter:[self displayObjectPredicate]];
    [_assignedObjectChooser setTitle:[self titleForObjectChooser]];

    var parentObject = [self parentOfAssignedObjects];
    [_assignedObjectChooser showOnView:aSender forParentObject:parentObject];
}

/*! @ignore
*/
- (@action)removeSelectedObjects:(id)aSender
{
    if (![_currentSelectedObjects count])
        return;

    for (var index = [_currentSelectedObjects count] - 1 ; index >= 0; index--)
    {
        var anObject = [_currentSelectedObjects objectAtIndex:index];
        [self _removeDeletedObject:anObject];
    }

    [_currentSelectedObjects removeAllObjects];
    [tableView deselectAll];
    [self _sendDelegateDidUnassignObjects];
}


#pragma mark -
#pragma mark Push Management

/*! @ignore
*/
- (void)_registerForPushNotification
{
    if (_isListeningForPush)
        return;

    _isListeningForPush = YES;

    CPLog.debug("PUSH: ObjectAssignation %@ is now registered for push", [self className]);
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didReceivePush:)
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

/*! @ignore
*/
- (void)_unregisterFromPushNotification
{
    if (!_isListeningForPush)
        return;

    _isListeningForPush = NO;

    CPLog.debug("PUSH: ObjectAssignation %@ is now unregistered from push", [self className]);
    [[CPNotificationCenter defaultCenter] removeObserver:self
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

/*! @ignore
*/
- (void)_didReceivePush:(CPNotification)aNotification
{
    [self _unregisterFromAssignationKeyChanges];

    var JSONObject = [aNotification userInfo],
        events     = JSONObject.events;

    if (events.length > 0)
    {
        for (var i = 0, c = events.length; i < c; i++)
        {
            var eventType  = events[i].type,
                entityType = events[i].entityType,
                entityJSON = events[i].entities[0];

            if (![self shouldManagePushForEntityType:entityType])
                continue;

            [self managePushedObject:entityJSON ofType:entityType eventType:eventType];
        }
    }

    [self _registerForAssignationKeyChanges];
}

- (BOOL)shouldManagePushForEntityType:(CPString)entityType
{
    var entityTypes = [[self assignationSettings] allKeys];
    return [entityTypes containsObject:entityType];
}

/*! @ignore
*/
- (void)managePushedObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    var anObject = [_dataSource objectWithID:aJSONObject.ID];

    if (!anObject)
        return;

    switch(anEventType)
    {
        case NUPushEventTypeUpdate:
            [anObject objectFromJSON:aJSONObject];
            break;

        case NUPushEventTypeDelete:
            [self _removeDeletedObject:anObject];
            break;
    }
}

/*! @ignore
*/
- (void)_registerForAssignationKeyChanges
{
    if (!_currentParent)
        return;

    [_currentParent addObserver:self forKeyPath:[self keyPathForAssignedObjectIDs] options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
}

/*! @ignore
*/
- (void)_unregisterFromAssignationKeyChanges
{
    if (!_currentParent)
        return;

    [_currentParent removeObserver:self forKeyPath:[self keyPathForAssignedObjectIDs]];
}

/*! @ignore
*/
- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    if ([change objectForKey:CPKeyValueChangeOldKey] == [change objectForKey:CPKeyValueChangeNewKey])
        return;

    [self _fetchObjects:[change objectForKey:CPKeyValueChangeNewKey] fromObjects:[change objectForKey:CPKeyValueChangeOldKey]];
}


#pragma mark -
#pragma mark Object Chooser Delegate

/*! @ignore
*/
- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser fetchObjects:(CPArray)someObjects
{
    [self didFetchAvailableAssignedObjects:someObjects];
}

/*! @ignore
*/
- (void)didObjectChooserCancelSelection:(NUObjectsChooser)anObjectChooser
{
    [self closePopover];
}

/*! @ignore
*/
- (CPArray)currentActiveContextsForChooser:(NUObjectChooser)anObjectChooser
{
    var identifiers = [self currentActiveContextIdentifiers],
        contexts    = [CPArray new],
        index;

    if (!identifiers)
        return [];

    for (index = [identifiers count] - 1; index >= 0; index--)
    {
        var identifier  = identifiers[index],
            context     = [anObjectChooser contextWithIdentifier:identifier];

        if (![contexts containsObject:context])
            [contexts addObject:context];
    }

    return contexts;
}

/*! @ignore
*/
- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser selectObjects:(CPArray)selectedObjects
{
    if ([selectedObjects count])
    {
        var currentIDs  = [_currentParent valueForKeyPath:[self keyPathForAssignedObjectIDs]],
            previousIDs = [currentIDs copy],
            IDsToAdd    = [];

        for (var index = [selectedObjects count] - 1 ; index >= 0 ; index--)
            [IDsToAdd addObject:[[selectedObjects objectAtIndex:index] ID]];

        [currentIDs addObjectsFromArray:IDsToAdd];
        [self _fetchObjects:currentIDs fromObjects:previousIDs];
        [self _sendDelegateDidAssignObjects];
    }

    [anObjectChooser closeModulePopover];
}


#pragma mark -
#pragma mark Delegate

/*! Sets the Delegates

    - (void)didAssignObjects:(NUAbstractObjectsAssignation)anAssignation
    - (void)didUnassignObjects:(NUAbstractObjectsAssignation)anAssignation
*/
- (void)setDelegate:(id)aDelegate
{
    if (_delegate === aDelegate)
        return;

    _delegate = aDelegate;
    _implementedDelegateMethods = 0;

    if ([_delegate respondsToSelector:@selector(didAssignObjects:)])
        _implementedDelegateMethods |= NUAbstractObjectsAssignation_didAssignObjects_;

    if ([_delegate respondsToSelector:@selector(didUnassignObjects:)])
        _implementedDelegateMethods |= NUAbstractObjectsAssignation_didUnassignObjects_;

}

/*! @ignore
*/
- (void)_sendDelegateDidAssignObjects
{
    if (_implementedDelegateMethods & NUAbstractObjectsAssignation_didAssignObjects_)
        [_delegate didAssignObjects:self];
}

/*! @ignore
*/
- (void)_sendDelegateDidUnassignObjects
{
    if (_implementedDelegateMethods & NUAbstractObjectsAssignation_didUnassignObjects_)
        [_delegate didUnassignObjects:self];
}


#pragma mark -
#pragma mark Table View Delegates

/*! @ignore
*/
- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    [[CPRunLoop mainRunLoop] performBlock:function(){
        [self _updateCurrentSelection];
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    } argument:nil order:0 modes:[CPDefaultRunLoopMode]];
}

/*! @ignore
*/
- (int)tableView:(CPTableView)aTableView heightOfRow:(int)aRow
{
    var dataView = [self _dataViewForObject:[_dataSource objectAtIndex:aRow]];

    if ([dataView respondsToSelector:@selector(computedHeightForObjectValue:)])
        return [dataView computedHeightForObjectValue:[_dataSource objectAtIndex:aRow]];
    else
        return [dataView frameSize].height;
}

/*! @ignore
*/
- (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    var item = [_dataSource objectAtIndex:aRow],
        key  = @"dataview_" + ([item isKindOfClass:NURESTObject] ? [item RESTName] : [item UID]),
        view = [aTableView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        view = [[self _dataViewForObject:item] duplicate];
        [view setIdentifier:key];
    }

    return view;
}

@end
