/*
*   Filename:         NUAbstractObjectAssociator.j
*   Created:          Wed Feb 12 20:43:15 PST 2014
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
@import <AppKit/CPView.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPButton.j>
@import "../DataViews/NUDataViewsController.j"
@import "../Model/NUVSDObject.j"
@import "../ViewControllers/NUObjectsChooser.j"

var NUAbstractObjectAssociatorLinkImage          = CPImageInBundle("button-link.png", 12.0, 12.0),
    NUAbstractObjectAssociatorLinkPressedImage   = CPImageInBundle("button-link-pressed.png", 12.0, 12.0),
    NUAbstractObjectAssociatorUnLinkImage        = CPImageInBundle("button-unlink.png", 12.0, 12.0),
    NUAbstractObjectAssociatorUnLinkPressedImage = CPImageInBundle("button-unlink-pressed.png", 12.0, 12.0);

var NUAbstractObjectAssociator_didAssociatorFetchAssociatedObject_          = 1 << 1,
    NUAbstractObjectAssociator_didAssociatorAddAssociation_                 = 1 << 2,
    NUAbstractObjectAssociator_didAssociatorRemoveAssociation_              = 1 << 3,
    NUAbstractObjectAssociator_didAssociatorChangeAssociation_              = 1 << 4;

NUObjectAssociatorDisplayModeDataView = 1;
NUObjectAssociatorDisplayModeText = 2;

var BUTTONS_SIZE = 12;

@implementation NUAbstractObjectAssociator : CPViewController
{
    BOOL                        _associationButtonHidden    @accessors(property=associationButtonHidden);
    BOOL                        _disassociationButtonHidden @accessors(property=disassociationButtonHidden);
    BOOL                        _hasAssociatedObject        @accessors(getter=hasAssociatedObject);
    BOOL                        _hidesDataViewsControls     @accessors(property=hidesDataViewsControls);
    BOOL                        _modified                   @accessors(property=modified);
    id                          _currentParent              @accessors(property=currentParent);
    id                          _delegate                   @accessors(property=delegate);
    int                         _displayMode                @accessors(property=displayMode);
    NUVSDObject                 _currentAssociatedObject    @accessors(property=currentAssociatedObject);

    BOOL                        _isListeningForPush;
    CPArray                     _activeTransactionsIDs;
    CPButton                    _buttonChooseAssociatedObject;
    CPButton                    _buttonCleanAssociatedObject;
    CPTextField                 _fieldAssociatedObjectText;
    CPTextField                 _fieldEmptyAssociatorTitle;
    CPView                      _dataViewAssociatedObject;
    CPView                      _innerButtonContainer;
    CPView                      _viewAssociatorContainer;
    CPView                      _viewButtonsContainer;
    CPView                      _viewDataViewContainer;
    int                         _implementedDelegateMethods;
    NUObjectsChooser            _associatedObjectChooser;
}


#pragma mark -
#pragma mark Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];

    _hidesDataViewsControls = YES;

    var view = [self view],
        frameSize = [view frameSize];

    [view setBackgroundColor:NUSkinColorWhite];
    [view setBorderColor:NUSkinColorGrey];

    _associatedObjectChooser = [[NUObjectsChooser alloc] initWithCibName:@"ObjectSelector" bundle:[CPBundle mainBundle]];
    [_associatedObjectChooser view];
    [_associatedObjectChooser setDelegate:self];
    [_associatedObjectChooser setAllowsMultipleSelection:NO];
    [self configureDataViewsForObjectChooser:_associatedObjectChooser];

    // VIEW INITIALIZATION

    // General Container
    _viewAssociatorContainer = [[CPView alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)];
    [_viewAssociatorContainer setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    // View that contains buttons
    _viewButtonsContainer = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    [_viewButtonsContainer setBackgroundColor:NUSkinColorGreyLight];
    [_viewButtonsContainer setAutoresizingMask:CPViewHeightSizable];
    [_viewButtonsContainer setBorderRightColor:NUSkinColorGrey];
    [_viewAssociatorContainer addSubview:_viewButtonsContainer];

    // View really containing the buttons for easier positioning
    _innerButtonContainer = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    [_innerButtonContainer setAutoresizingMask:CPViewMinYMargin | CPViewMaxYMargin];
    [_viewButtonsContainer addSubview:_innerButtonContainer];

    // Button add association
    _buttonChooseAssociatedObject = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, BUTTONS_SIZE, BUTTONS_SIZE)];
    [_buttonChooseAssociatedObject setTarget:self];
    [_buttonChooseAssociatedObject setAction:@selector(openAssociatedObjectChooser:)];
    [_buttonChooseAssociatedObject setBordered:NO];
    [_buttonChooseAssociatedObject setButtonType:CPMomentaryChangeButton];
    [_buttonChooseAssociatedObject setValue:NUAbstractObjectAssociatorLinkImage forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_buttonChooseAssociatedObject setValue:NUAbstractObjectAssociatorLinkPressedImage forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    [_buttonChooseAssociatedObject setToolTip:@"Associate an object"];
    [_buttonChooseAssociatedObject bind:CPHiddenBinding toObject:self withKeyPath:@"associationButtonHidden" options:nil];
    [_innerButtonContainer addSubview:_buttonChooseAssociatedObject];
    _cucappID(_buttonChooseAssociatedObject, @"button-set-associatedobject");

    // Button remove association
    _buttonCleanAssociatedObject = [[CPButton alloc] initWithFrame:CGRectMake(0, 14, BUTTONS_SIZE, BUTTONS_SIZE)];
    [_buttonCleanAssociatedObject setTarget:self];
    [_buttonCleanAssociatedObject setAction:@selector(removeCurrentAssociatedObject:)];
    [_buttonCleanAssociatedObject setBordered:NO];
    [_buttonCleanAssociatedObject setButtonType:CPMomentaryChangeButton];
    [_buttonCleanAssociatedObject setValue:NUAbstractObjectAssociatorUnLinkImage forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_buttonCleanAssociatedObject setValue:NUAbstractObjectAssociatorUnLinkPressedImage forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    [_buttonCleanAssociatedObject setToolTip:@"Disassociate the object"];
    [_buttonCleanAssociatedObject bind:CPHiddenBinding toObject:self withKeyPath:@"disassociationButtonHidden" options:nil];
    [_innerButtonContainer addSubview:_buttonCleanAssociatedObject];
    _cucappID(_buttonCleanAssociatedObject, @"button-unset-associatedobject");

    // Data View Container
    _viewDataViewContainer = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    [_viewDataViewContainer setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_viewAssociatorContainer addSubview:_viewDataViewContainer];

    // Field shown when no association is present
    _fieldEmptyAssociatorTitle = [CPTextField labelWithTitle:[self emptyAssociatorTitle]];
    [_fieldEmptyAssociatorTitle setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin | CPViewMaxYMargin];
    [_fieldEmptyAssociatorTitle setAlignment:CPCenterTextAlignment];
    [_fieldEmptyAssociatorTitle setTextColor:NUSkinColorGreyDark];
    [_fieldEmptyAssociatorTitle setFont:[CPFont systemFontOfSize:12]];
    [_viewDataViewContainer addSubview:_fieldEmptyAssociatorTitle];

    // Field that displays the a textual mode
    _fieldAssociatedObjectText = [CPTextField labelWithTitle:@""];
    [_fieldAssociatedObjectText setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    // set default view mode only if it's not already set to something
    if (!_displayMode)
        [self setDisplayMode:[self defaultDisplayMode]];
}


#pragma mark -
#pragma mark Protocol

- (CPString)defaultDisplayMode
{
    return NUObjectAssociatorDisplayModeDataView;
}

- (void)configureDataViewsForObjectChooser:(NUObjectsChooser)anObjectChooser
{
    throw ("implement me");
}

- (Class)classForAssociatedObject
{
    throw ("implement me")
}

- (CPString)emptyAssociatorTitle
{
    throw ("implement me");
}

- (CPString)titleForObjectChooser
{
    throw ("implement me");
}

- (CPString)keyPathForAssociatedObjectID
{
    throw ("implement me");
}

- (CPString)fetcherKeyPathOfAssociatedObjects
{
    throw ("implement me");
}

- (NUVSDObject)parentOfAssociatedObjects
{
    throw ("implement me");
}

- (CPPredicate)filterObjectPredicate
{
    return nil;
}

- (CPPredicate)displayObjectPredicate
{
    return nil;
}

- (IBAction)removeCurrentAssociatedObject:(id)aSender
{
    throw ("implement me");
}

- (CPString)associatedObjectNameKeyPath
{
    return @"name";
}


#pragma mark -
#pragma mark Internal Subclass Delegates

- (void)didUpdateAssociatedObject:(NUVSDObject)anObject
{
}

- (void)didFetchAssociatedObject:(NUVSDObject)anObject
{
}

- (void)didFetchAvailableAssociatedObjects:(CPArray)someObjects
{
}

- (void)didSetCurrentParent:(NUVSDObject)aParent
{
}


#pragma mark -
#pragma mark Getters and Setters

- (void)setCurrentParent:(id)aParent
{
    if (_currentParent == aParent)
        return;

    _currentParent = aParent;

    [self setModified:NO];

    [self setCurrentAssociatedObject:nil];
    [self _updateDataViewWithAssociatedObject:nil];

    if (_currentParent)
    {
        [self _registerForPushNotification];
        [self _registerForAssociationKeyChanges];
    }
    else
    {
        [self _unregisterFromPushNotification];
        [self _unregisterFromAssociationKeyChanges];
        [self closePopover];
    }
}

- (void)setEnabled:(BOOL)shouldEnable
{
    [self setEnableAssociation:shouldEnable];
    [self setEnableDisassociation:shouldEnable];
}

- (void)setEnableAssociation:(BOOL)shouldEnable
{
    [_buttonChooseAssociatedObject setEnabled:shouldEnable];
}

- (void)setEnableDisassociation:(BOOL)shouldEnable
{
    [_buttonCleanAssociatedObject setEnabled:shouldEnable];
}

- (void)setCurrentAssociatedObject:(NUVSDObject)anObject
{
    if (anObject == _currentAssociatedObject)
        return;

    [self willChangeValueForKey:@"currentAssociatedObject"];
    [self willChangeValueForKey:@"hasAssociatedObject"];
    _currentAssociatedObject = anObject;
    [self didChangeValueForKey:@"currentAssociatedObject"];
    [self didChangeValueForKey:@"hasAssociatedObject"];
}

- (BOOL)hasAssociatedObject
{
    return !!_currentAssociatedObject;
}

- (CPPopover)closePopover
{
    [_associatedObjectChooser closeModulePopover];
}

- (void)setDisassociationButtonHidden:(BOOL)shouldHide
{
    if (shouldHide == _disassociationButtonHidden)
        return;

    [self willChangeValueForKey:@"disassociationButtonHidden"];
    _disassociationButtonHidden = shouldHide;
    [self didChangeValueForKey:@"disassociationButtonHidden"];

    [self view]; // force loading the view because we need to adjust the button position after initialization
    [self _repositionAssociateButton];
}

- (void)setDisplayMode:(int)aMode
{
    if (_displayMode === aMode)
        return;

    [self willChangeValueForKey:@"displayMode"];
    _displayMode = aMode;
    [self didChangeValueForKey:@"displayMode"];

    var generalFrame  = [[self view] frame],
        generalHeight = CGRectGetHeight(generalFrame),
        generalWidth  = CGRectGetWidth(generalFrame),
        generalCenter = CGPointMake(CGRectGetMidX(generalFrame), CGRectGetMidY(generalFrame));

    switch (_displayMode)
    {
        case NUObjectAssociatorDisplayModeDataView:
            [_viewButtonsContainer setFrame:CGRectMake(0, 0, 22, generalHeight)];
            [_innerButtonContainer setFrame:CGRectMake([_viewButtonsContainer frameSize].width / 2 - 6, [_viewButtonsContainer frameSize].height / 2 - 14, 12, 26)];
            [_buttonChooseAssociatedObject setFrameOrigin:CGPointMake(0, 0)];
            [_buttonCleanAssociatedObject setFrameOrigin:CGPointMake(0, 14)];
            [_viewDataViewContainer setFrame:CGRectMake([_viewButtonsContainer frameSize].width, 0, generalWidth - [_viewButtonsContainer frameSize].width, generalHeight)];
            [_fieldEmptyAssociatorTitle setFrameOrigin:CGPointMake([_viewDataViewContainer frameSize].width / 2 - [_fieldEmptyAssociatorTitle frameSize].width / 2, [_viewDataViewContainer frameSize].height / 2 - [_fieldEmptyAssociatorTitle frameSize].height / 2)];
            break;

        case NUObjectAssociatorDisplayModeText:
            [_viewButtonsContainer setFrame:CGRectMake(0, 0, 37, generalHeight)];
            [_innerButtonContainer setFrame:CGRectMake([_viewButtonsContainer frameSize].width / 2 - 15, [_viewButtonsContainer frameSize].height / 2 - 7, 26, 12)];
            [_buttonChooseAssociatedObject setFrameOrigin:CGPointMake(0, 0)];
            [_buttonCleanAssociatedObject setFrameOrigin:CGPointMake(14, 0)];
            [_viewDataViewContainer setFrame:CGRectMake([_viewButtonsContainer frameSize].width, 0, generalWidth - [_viewButtonsContainer frameSize].width, generalHeight)];
            [_fieldEmptyAssociatorTitle setFrameOrigin:CGPointMake([_viewDataViewContainer frameSize].width / 2 - [_fieldEmptyAssociatorTitle frameSize].width / 2, [_viewDataViewContainer frameSize].height / 2 - [_fieldEmptyAssociatorTitle frameSize].height / 2)];
            break;

        default:
            [CPException raise:CPInvalidArgumentException reason:@"display mode must be either 'NUObjectAssociatorDisplayModeDataView' or 'NUObjectAssociatorDisplayModeText"];
    }

    [self _repositionAssociateButton];
}

- (CPView)_associatorDataViewForCurrentAssociatedObject
{
    var dataView,
        objectValue;

    switch (_displayMode)
    {
        case NUObjectAssociatorDisplayModeDataView:
            objectValue = _currentAssociatedObject;
            dataView = [[_associatedObjectChooser registeredDataViewForClass:[_currentAssociatedObject class]] duplicate];
            break;

        case NUObjectAssociatorDisplayModeText:
            objectValue = [_currentAssociatedObject valueForKeyPath:[self associatedObjectNameKeyPath]];
            dataView = _fieldAssociatedObjectText;
            break;

        default:
            [CPException raise:CPInvalidArgumentException reason:@"display mode must be either 'NUObjectAssociatorDisplayModeDataView' or 'NUObjectAssociatorDisplayModeText"];
    }

    if (_hidesDataViewsControls && [dataView respondsToSelector:@selector(setControlsHidden:)])
        [dataView setControlsHidden:YES];

    [dataView setObjectValue:objectValue];
    [dataView setBackgroundColor:NUSkinColorWhite];
    [dataView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    return dataView;
}


#pragma mark -
#pragma mark Utilities

- (void)showLoading:(BOOL)shouldShow
{
    if (shouldShow)
        [[NUDataTransferController defaultDataTransferController] showFetchingViewOnView:[self view]];
    else
        [[NUDataTransferController defaultDataTransferController] hideFetchingViewFromView:[self view]];
}

- (void)_fetchAssociatedObjectWithID:(CPString)anID
{
    if (!anID)
    {
        [self _updateDataViewWithAssociatedObject:nil];
        [self didFetchAssociatedObject:nil];
        [self _sendDelegateDidAssociatorFetchAssociatedObject];

        return;
    }

    var associatedObject = [[self classForAssociatedObject] new];
    [associatedObject setID:anID];
    [associatedObject fetchAndCallSelector:@selector(_didFetchAssociatedObject:connection:) ofObject:self];

    [self showLoading:YES];
}

- (void)_didFetchAssociatedObject:(RESTObject)anObject connection:(NURESTConnection)aConnection
{
    [self showLoading:NO];

    if (aConnection && ![NURESTConnection handleResponseForConnection:aConnection postErrorMessage:YES])
        return;

    [self _updateDataViewWithAssociatedObject:anObject];
    [self didFetchAssociatedObject:anObject];
    [self _sendDelegateDidAssociatorFetchAssociatedObject];
}

- (void)_updateDataViewWithAssociatedObject:(NUVSDObject)anAssociatedObject
{
    if (![_viewAssociatorContainer superview])
    {
        var view = [self view];
        [_viewAssociatorContainer setFrame:[view bounds]];
        [view addSubview:_viewAssociatorContainer];
    }

    if (_dataViewAssociatedObject)
        [_dataViewAssociatedObject setObjectValue:nil];

    if ([_dataViewAssociatedObject superview])
        [_dataViewAssociatedObject removeFromSuperview];

    if (![self disassociationButtonHidden])
        [_buttonCleanAssociatedObject setHidden:!!!anAssociatedObject];

    [self setCurrentAssociatedObject:anAssociatedObject];

    if (anAssociatedObject)
    {
        if ([_fieldEmptyAssociatorTitle superview])
            [_fieldEmptyAssociatorTitle setHidden:YES];

        _dataViewAssociatedObject = [self _associatorDataViewForCurrentAssociatedObject];

        switch (_displayMode)
        {
            case NUObjectAssociatorDisplayModeDataView:
                [_dataViewAssociatedObject setFrame:CGRectMake(0, ([_viewDataViewContainer frameSize].height / 2 - [_dataViewAssociatedObject frameSize].height / 2), [_viewDataViewContainer frameSize].width, [_dataViewAssociatedObject frameSize].height)];
                break;

            case NUObjectAssociatorDisplayModeText:
                [_dataViewAssociatedObject setFrame:CGRectMake(4, ([_viewDataViewContainer frameSize].height / 2 - [_dataViewAssociatedObject frameSize].height / 2), [_viewDataViewContainer frameSize].width - 6, [_dataViewAssociatedObject frameSize].height)];
                break;

            default:
                [CPException raise:CPInvalidArgumentException reason:@"display mode must be either 'NUObjectAssociatorDisplayModeDataView' or 'NUObjectAssociatorDisplayModeText"];
        }

        [_viewDataViewContainer addSubview:_dataViewAssociatedObject];
    }
    else
    {
        [_fieldEmptyAssociatorTitle setStringValue:[self emptyAssociatorTitle]];
        [_fieldEmptyAssociatorTitle setHidden:NO];
    }

    [self _repositionAssociateButton];
}

- (void)_repositionAssociateButton
{
    var frame = [_innerButtonContainer frame];

    if ([_buttonCleanAssociatedObject isHidden])
    {
        if (_displayMode == NUObjectAssociatorDisplayModeDataView)
            [_buttonChooseAssociatedObject setFrameOrigin:CGPointMake(frame.size.width / 2 - BUTTONS_SIZE / 2, frame.size.height / 2 - BUTTONS_SIZE / 2)];
        else
            [_buttonChooseAssociatedObject setFrameOrigin:CGPointMake(7, 0)];
    }
    else
        [_buttonChooseAssociatedObject setFrameOrigin:CGPointMakeZero()];
}


#pragma mark -
#pragma mark Actions

- (IBAction)openAssociatedObjectChooser:(id)aSender
{
    if (_currentAssociatedObject)
        [_associatedObjectChooser setIgnoredObjects:[_currentAssociatedObject]];
    else
        [_associatedObjectChooser setIgnoredObjects:[]];

    var fetcherKeyPath      = [self fetcherKeyPathOfAssociatedObjects],
        parentObject        = [self parentOfAssociatedObjects],
        managedObjectClass  = [self classForAssociatedObject];

    [_associatedObjectChooser setModuleTitle:[self titleForObjectChooser]];
    [_associatedObjectChooser setMasterFilter:[self filterObjectPredicate]];
    [_associatedObjectChooser setDisplayFilter:[self displayObjectPredicate]];

    [_associatedObjectChooser setTitle:[self titleForObjectChooser]];
    [_associatedObjectChooser configureFetcherKeyPath:fetcherKeyPath forClass:managedObjectClass];
    [_associatedObjectChooser showOnView:aSender forParentObject:parentObject];
}


#pragma mark -
#pragma mark Push Management

- (void)_registerForPushNotification
{
    if (_isListeningForPush)
        return;

    _isListeningForPush = YES;

    CPLog.debug("PUSH: ObjectAssociator %@ is now registered for push", [self className]);
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didReceivePush:)
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

- (void)_unregisterFromPushNotification
{
    if (!_isListeningForPush)
        return;

    _isListeningForPush = NO;

    CPLog.debug("PUSH: ObjectAssociator %@ is now unregistered from push", [self className]);
    [[CPNotificationCenter defaultCenter] removeObserver:self
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

- (void)_didReceivePush:(CPNotification)aNotification
{
    [self _unregisterFromAssociationKeyChanges];

    var JSONObject = [aNotification userInfo],
        events = JSONObject.events;

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

    [self _registerForAssociationKeyChanges];
}

- (void)managePushedObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    if (aJSONObject.ID == [_currentAssociatedObject ID] && anEventType == NUPushEventTypeUpdate)
        [_currentAssociatedObject objectFromJSON:aJSONObject];
    if (aJSONObject.ID == [_currentAssociatedObject ID] && anEventType == NUPushEventTypeDelete)
    {
        [self _updateDataViewWithAssociatedObject:nil];
        [_currentParent setValue:nil forKeyPath:[self keyPathForAssociatedObjectID]];
    }
}

- (void)_registerForAssociationKeyChanges
{
    if (!_currentParent)
        return;
    [_currentParent addObserver:self forKeyPath:[self keyPathForAssociatedObjectID] options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
}

- (void)_unregisterFromAssociationKeyChanges
{
    if (!_currentParent)
        return;

    [_currentParent removeObserver:self forKeyPath:[self keyPathForAssociatedObjectID]];
}

- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    if ([change objectForKey:CPKeyValueChangeOldKey] == [change objectForKey:CPKeyValueChangeNewKey])
        return;

    [self _fetchAssociatedObjectWithID:[_currentParent valueForKeyPath:[self keyPathForAssociatedObjectID]]];
}


#pragma mark -
#pragma mark Object Chooser Delegate

- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser fetchObjects:(CPArray)someObjects
{
    [self didFetchAvailableAssociatedObjects:someObjects];
}

- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser selectObjects:(CPArray)selectedObjects
{
    throw ("implement me");
}

- (void)didObjectChooserCancelSelection:(NUObjectsChooser)anObjectChooser
{
    [self closePopover];
}


#pragma mark -
#pragma mark Delegate

- (void)setDelegate:(id)aDelegate
{
    if (_delegate === aDelegate)
        return;

    _delegate = aDelegate;
    _implementedDelegateMethods = 0;

    if ([_delegate respondsToSelector:@selector(didAssociatorFetchAssociatedObject:)])
        _implementedDelegateMethods |= NUAbstractObjectAssociator_didAssociatorFetchAssociatedObject_;

    if ([_delegate respondsToSelector:@selector(didAssociatorChangeAssociation:)])
        _implementedDelegateMethods |= NUAbstractObjectAssociator_didAssociatorChangeAssociation_;

    if ([_delegate respondsToSelector:@selector(didAssociatorAddAssociation:)])
        _implementedDelegateMethods |= NUAbstractObjectAssociator_didAssociatorAddAssociation_;

    if ([_delegate respondsToSelector:@selector(didAssociatorRemoveAssociation:)])
        _implementedDelegateMethods |= NUAbstractObjectAssociator_didAssociatorRemoveAssociation_;
}

- (void)_sendDelegateDidAssociatorFetchAssociatedObject
{
    if (_implementedDelegateMethods & NUAbstractObjectAssociator_didAssociatorFetchAssociatedObject_)
        [_delegate didAssociatorFetchAssociatedObject:self];
}

- (void)_sendDelegateDidAssociatorChangeAssociation
{
    if (_implementedDelegateMethods & NUAbstractObjectAssociator_didAssociatorChangeAssociation_)
        [_delegate didAssociatorChangeAssociation:self];
}

- (void)_sendDelegateDidAssociatorAddAssociation
{
    if (_implementedDelegateMethods & NUAbstractObjectAssociator_didAssociatorAddAssociation_)
        [_delegate didAssociatorAddAssociation:self];
}

- (void)_sendDelegateDidAssociatorRemoveAssociation
{
    if (_implementedDelegateMethods & NUAbstractObjectAssociator_didAssociatorRemoveAssociation_)
        [_delegate didAssociatorRemoveAssociation:self];
}

@end
