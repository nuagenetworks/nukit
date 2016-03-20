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
@import <Bambou/NURESTModelController.j>

@import "NUObjectsChooser.j"

@class NUKit
@class NURESTModelController


var NUAbstractObjectAssociatorLinkImage          = CPImageInBundle("button-link.png", 12.0, 12.0, [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]),
    NUAbstractObjectAssociatorLinkPressedImage   = CPImageInBundle("button-link-pressed.png", 12.0, 12.0, [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]),
    NUAbstractObjectAssociatorUnLinkImage        = CPImageInBundle("button-unlink.png", 12.0, 12.0, [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]),
    NUAbstractObjectAssociatorUnLinkPressedImage = CPImageInBundle("button-unlink-pressed.png", 12.0, 12.0, [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]);

var NUAbstractObjectAssociator_didAssociatorFetchAssociatedObject_          = 1 << 1,
    NUAbstractObjectAssociator_didAssociatorAddAssociation_                 = 1 << 2,
    NUAbstractObjectAssociator_didAssociatorRemoveAssociation_              = 1 << 3,
    NUAbstractObjectAssociator_didAssociatorChangeAssociation_              = 1 << 4;

var NUAbstractObjectAssociatorImageRequired = nil;

NUObjectAssociatorDisplayModeDataView = 1;
NUObjectAssociatorDisplayModeText     = 2;

var BUTTONS_SIZE = 12;

NUObjectAssociatorSettingsCategoryNameKey                   = @"NUObjectAssociatorSettingsCategoryNameKey";
NUObjectAssociatorSettingsDataViewNameKey                   = @"NUObjectAssociatorSettingsDataViewNameKey";
NUObjectAssociatorSettingsAssociatedObjectFetcherKeyPathKey = @"NUObjectAssociatorSettingsAssociatedObjectFetcherKeyPathKey";

/*! NUAbstractObjectAssociator is the base class of all associators.
    An associators allows you to provide an control that will
    let the user select a remote object, and the a key to the ID of
    the selected object into the current parent.

    You should not use this class directly. Instead, you can use the NUAbstractSimpleObjectAssociator
    or NUAbstractAdvancedObjectAssociator
*/
@implementation NUAbstractObjectAssociator : CPViewController
{
    BOOL                        _associationButtonHidden    @accessors(property=associationButtonHidden);
    BOOL                        _controlButtonsHidden       @accessors(property=controlButtonsHidden);
    BOOL                        _disassociationButtonHidden @accessors(property=disassociationButtonHidden);
    BOOL                        _hasAssociatedObject        @accessors(getter=hasAssociatedObject);
    BOOL                        _hidesDataViewsControls     @accessors(property=hidesDataViewsControls);
    BOOL                        _modified                   @accessors(property=modified);
    id                          _currentAssociatedObject    @accessors(property=currentAssociatedObject);
    id                          _currentParent              @accessors(property=currentParent);
    id                          _delegate                   @accessors(property=delegate);
    int                         _displayMode                @accessors(property=displayMode);

    BOOL                        _isRequired;
    BOOL                        _isListeningForPush;
    CPArray                     _activeTransactionsIDs;
    CPDictionary                _categoriesRegistry;
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

/*! @ignore
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    _hidesDataViewsControls = YES;
    _categoriesRegistry       = @{};

    var view = [self view],
        frameSize = [view frameSize];

    [view setBackgroundColor:NUSkinColorWhite];
    [view setBorderColor:NUSkinColorGrey];

    _associatedObjectChooser = [NUObjectsChooser new];
    [_associatedObjectChooser view];
    [_associatedObjectChooser setDelegate:self];
    [_associatedObjectChooser setAllowsMultipleSelection:NO];

    [self _configureObjectsChooser];

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
    _cucappID(_buttonChooseAssociatedObject, [self className] + @"-button-set-associatedobject");

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
    _cucappID(_buttonCleanAssociatedObject, [self className] + @"-button-clean-associatedobject");

    // Data View Container
    _viewDataViewContainer = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    [_viewDataViewContainer setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_viewAssociatorContainer addSubview:_viewDataViewContainer];
    _cucappID(_buttonCleanAssociatedObject, [self className] + @"-dataview-container");

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

    [self setControlButtonsHidden:NO];

    // set default view mode only if it's not already set to something
    if (!_displayMode)
        [self setDisplayMode:[self defaultDisplayMode]];

    [self _displayRequiredImage];
}


#pragma mark -
#pragma mark Protocol

/*! Overrides this to change the mode.
    You can set NUObjectAssociatorDisplayModeDataView or NUObjectAssociatorDisplayModeText
*/
- (CPString)defaultDisplayMode
{
    return NUObjectAssociatorDisplayModeDataView;
}

/*! Override this to define what will be display when nothing is associated.

    For instance "no associated object"
*/
- (CPString)emptyAssociatorTitle
{
    throw ("implement me");
}

/*! Override this to define the title of the NUObjectsChooser
    used to select the associated object.

    For instance "Select Task"
*/
- (CPString)titleForObjectChooser
{
    throw ("implement me");
}

/*! Override this to provide what keyPath of the current parent
    should be used to set the ID of the selected associated object.

    For instance: "associatedTaskID"
*/
- (CPString)keyPathForAssociatedObjectID
{
    throw ("implement me");
}

/*! Overrides this to provide the object that needs to be
    used to to fetch the associated object.

    For instance [NURESTUser default]
*/
- (id)parentOfAssociatedObjects
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
- (@action)removeCurrentAssociatedObject:(id)aSender
{
    throw ("implement me");
}

/*! @ignore
*/
- (CPString)associatedObjectNameKeyPath
{
    return @"name";
}

/*! Override this to provide the identifiers of the active contexts
*/
- (CPArray)currentActiveContextIdentifiers
{
    throw ("implement me");
}

/*! Override this to provide the associator settings.
    Settings is a CPDictionary looking like

    @{
        [SDTask RESTName]: @{
            NUObjectAssociatorSettingsDataViewNameKey: @"taskDataView",
            NUObjectAssociatorSettingsAssociatedObjectFetcherKeyPathKey: @"tasks"
        }
    }
*/
- (CPDictionary)associatorSettings
{
    throw ("implement me");
}


#pragma mark -
#pragma mark Internal Subclass Delegates

/*! @ignore
*/
- (void)didFetchAssociatedObject:(id)anObject
{
}

/*! @ignore
*/
- (void)didFetchAvailableAssociatedObjects:(CPArray)someObjects
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
        [self _unregisterFromAssociationKeyChanges]
        [self closePopover];
    }

    _currentParent = aParent;

    [self setModified:NO];

    // CS (11/04/2015) This looks unnecessary as we now unregister from binding earlier
    // [self setCurrentAssociatedObject:nil];
    // [self _updateDataViewWithAssociatedObject:nil];

    if (_currentParent)
    {
        [self _registerForPushNotification];
        [self _registerForAssociationKeyChanges];
    }
}

/*! Sets if the associator should be enabled or disabled
*/
- (void)setEnabled:(BOOL)shouldEnable
{
    [self setEnableAssociation:shouldEnable];
    [self setEnableDisassociation:shouldEnable];
}

/*! Sets if the association button should be enabled
*/
- (void)setEnableAssociation:(BOOL)shouldEnable
{
    [_buttonChooseAssociatedObject setEnabled:shouldEnable];
}

/*! Sets if the disassociation button should be enabled
*/
- (void)setEnableDisassociation:(BOOL)shouldEnable
{
    [_buttonCleanAssociatedObject setEnabled:shouldEnable];
}

/*! @ignore
*/
- (void)setCurrentAssociatedObject:(id)anObject
{
    if (anObject == _currentAssociatedObject)
        return;

    [self willChangeValueForKey:@"currentAssociatedObject"];
    [self willChangeValueForKey:@"hasAssociatedObject"];
    _currentAssociatedObject = anObject;
    [self didChangeValueForKey:@"currentAssociatedObject"];
    [self didChangeValueForKey:@"hasAssociatedObject"];
}

/*! Returns if the associator has an associated object
*/
- (BOOL)hasAssociatedObject
{
    return !!_currentAssociatedObject;
}

/*! Close the NUObjectsChooser popover
*/
- (CPPopover)closePopover
{
    [_associatedObjectChooser closeModulePopover];
}

/*! Sets if the disassociation button should be hidden
*/
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
        [self _layoutAssociator];
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

    [self _layoutAssociator];
}

/*! @ignore
*/
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

/*! Sets if the association is required
*/
- (void)setRequired:(BOOL)isRequired
{
    if (self._isRequired == isRequired)
        return;

    self._isRequired = isRequired;
}

/*! Checks if the association is required
*/
- (BOOL)isRequired
{
    return !!self._isRequired;
}


#pragma mark -
#pragma mark Utilities

/*! @ignore
*/
- (void)_displayRequiredImage
{
    var view         = [self view],
        currentFrame = [view bounds];

    if (self._isRequired)
    {
        if (!NUAbstractObjectAssociatorImageRequired)
            NUAbstractObjectAssociatorImageRequired = NUImageInKit(@"required.png", CGSizeMake(8, 8));

        self.__requiredImageView = [[CPImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        [self.__requiredImageView setAutoresizingMask:CPViewMinXMargin];
        [self.__requiredImageView setImage:NUAbstractObjectAssociatorImageRequired];
        [self.__requiredImageView setToolTip:@"This association is required"];

        [self.__requiredImageView setFrameOrigin:CGPointMake(CGRectGetWidth(currentFrame) - 16, CGRectGetMidY(currentFrame) - 4)];
        [[self view] addSubview:self.__requiredImageView];
    }
    else
    {
        if (self.__requiredImageView)
            [self.__requiredImageView removeFromSuperview];
    }
}

/*! @ignore
*/
- (void)_configureObjectsChooser
{
    var settings    = [self associatorSettings],
        RESTNames   = [settings allKeys];

    for (var i = [RESTNames count] - 1; i >= 0; i--)
    {
        var RESTName            = RESTNames[i],
            defaultController   = [NURESTModelController defaultController],
            objectClass         = [defaultController modelClassForRESTName:RESTName];

        if (![settings containsKey:RESTName])
            [CPException raise:CPInternalInconsistencyException reason:"No setting defined for entity " + RESTName];

        var setting = [settings objectForKey:RESTName];

        if (![setting containsKey:NUObjectAssociatorSettingsDataViewNameKey])
            [CPException raise:CPInternalInconsistencyException reason:"No dataView defined for " + RESTName];

        if (![setting containsKey:NUObjectAssociatorSettingsAssociatedObjectFetcherKeyPathKey])
            [CPException raise:CPInternalInconsistencyException reason:"No fetcherKeyPath defined for " + RESTName];

        var dataView        = [setting objectForKey:NUObjectAssociatorSettingsDataViewNameKey],
            fetcherKeyPath  = [setting objectForKey:NUObjectAssociatorSettingsAssociatedObjectFetcherKeyPathKey],
            categoryName    = [setting containsKey:NUObjectAssociatorSettingsCategoryNameKey] ? [setting objectForKey:NUObjectAssociatorSettingsCategoryNameKey] : nil;

        [_associatedObjectChooser registerDataViewWithName:dataView forClass:objectClass];
        [_associatedObjectChooser configureFetcherKeyPath:fetcherKeyPath forClass:objectClass];

        if (categoryName)
            [_categoriesRegistry setObject:[NUCategory categoryWithName:categoryName] forKey:RESTName];
    }
}

/*! @ignore
*/
- (CPArray)_currentCategories
{
    if (![_categoriesRegistry count])
        return;

    var identifiers = [self currentActiveContextIdentifiers],
        categories  = [CPArray new];

    if (![identifiers count])
        return;

    for (var i = [identifiers count] - 1; i >= 0; i--)
    {
        var identifier  = identifiers[i],
            category    = [_categoriesRegistry objectForKey:identifier];

        [categories addObject:category];
    }

    return categories
}

/*! Shows the loading view
*/
- (void)showLoading:(BOOL)shouldShow
{
    if (shouldShow)
        [[NUDataTransferController defaultDataTransferController] showFetchingViewOnView:[self view]];
    else
        [[NUDataTransferController defaultDataTransferController] hideFetchingViewFromView:[self view]];
}

/*! @ignore
*/
- (void)_fetchAssociatedObjectWithID:(CPString)anID
{
    if (!anID)
    {
        [self _updateDataViewWithAssociatedObject:nil];
        [self didFetchAssociatedObject:nil];
        [self _sendDelegateDidAssociatorFetchAssociatedObject];

        return;
    }

    var identifiers = [self currentActiveContextIdentifiers],
        settings    = [self associatorSettings],
        parentObject = [self parentOfAssociatedObjects];

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
                fetcherKeyPath  = [setting objectForKey:NUObjectAssociatorSettingsAssociatedObjectFetcherKeyPathKey],
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

    [self showLoading:YES];
}

/*! @ignore
*/
- (void)_didFetchObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (![NURESTConnection handleResponseForConnection:aConnection postErrorMessage:YES])
        return;

    [self showLoading:NO];
    [self _updateDataViewWithAssociatedObject:anObject];
    [self didFetchAssociatedObject:anObject];
    [self _sendDelegateDidAssociatorFetchAssociatedObject];
}

/*! @ignore
*/
- (void)_fetcher:(id)aFetcher ofObject:(NURESTObject)anObject didFetchContent:(CPArray)someContents
{
    if (![someContents count])
        return;

    [self showLoading:NO];

    var anObject = [someContents firstObject];

    [self _updateDataViewWithAssociatedObject:anObject];
    [self didFetchAssociatedObject:anObject];
    [self _sendDelegateDidAssociatorFetchAssociatedObject];
}

/*! @ignore
*/
- (void)_updateDataViewWithAssociatedObject:(id)anAssociatedObject
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

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_layoutAssociator
{
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
            break;

        case NUObjectAssociatorDisplayModeText:
            [_viewButtonsContainer setFrame:CGRectMake(0, 0, 37, generalHeight)];
            [_innerButtonContainer setFrame:CGRectMake([_viewButtonsContainer frameSize].width / 2 - 15, [_viewButtonsContainer frameSize].height / 2 - 7, 26, 12)];
            [_buttonChooseAssociatedObject setFrameOrigin:CGPointMake(0, 0)];
            [_buttonCleanAssociatedObject setFrameOrigin:CGPointMake(14, 0)];
            [_viewDataViewContainer setFrame:CGRectMake([_viewButtonsContainer frameSize].width, 0, generalWidth - [_viewButtonsContainer frameSize].width, generalHeight)];
            break;

        default:
            [CPException raise:CPInvalidArgumentException reason:@"display mode must be either 'NUObjectAssociatorDisplayModeDataView' or 'NUObjectAssociatorDisplayModeText"];
    }

    var viewButtonsContainerWidth = [_viewButtonsContainer isHidden] ? 0 : [_viewButtonsContainer frameSize].width;

    [_viewDataViewContainer setFrame:CGRectMake(viewButtonsContainerWidth, 0, generalWidth - viewButtonsContainerWidth, generalHeight)];

    [_fieldEmptyAssociatorTitle setFrameOrigin:CGPointMake([_viewDataViewContainer frameSize].width / 2 - [_fieldEmptyAssociatorTitle frameSize].width / 2, [_viewDataViewContainer frameSize].height / 2 - [_fieldEmptyAssociatorTitle frameSize].height / 2)];

    [self _repositionAssociateButton];
}


#pragma mark -
#pragma mark Actions

/*! Opens the NUObjectsChooser popover
*/
- (@action)openAssociatedObjectChooser:(id)aSender
{
    if (_currentAssociatedObject)
        [_associatedObjectChooser setIgnoredObjects:[_currentAssociatedObject]];
    else
        [_associatedObjectChooser setIgnoredObjects:[]];

    [_associatedObjectChooser setCategories:[self _currentCategories]];
    [_associatedObjectChooser setModuleTitle:[self titleForObjectChooser]];
    [_associatedObjectChooser setMasterFilter:[self filterObjectPredicate]];
    [_associatedObjectChooser setDisplayFilter:[self displayObjectPredicate]];
    [_associatedObjectChooser setTitle:[self titleForObjectChooser]];

    var parentObject = [self parentOfAssociatedObjects];
    [_associatedObjectChooser showOnView:aSender forParentObject:parentObject];
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

    CPLog.debug("PUSH: ObjectAssociator %@ is now registered for push", [self className]);
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

    CPLog.debug("PUSH: ObjectAssociator %@ is now unregistered from push", [self className]);
    [[CPNotificationCenter defaultCenter] removeObserver:self
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_registerForAssociationKeyChanges
{
    if (!_currentParent)
        return;

    [_currentParent addObserver:self forKeyPath:[self keyPathForAssociatedObjectID] options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
}

/*! @ignore
*/
- (void)_unregisterFromAssociationKeyChanges
{
    if (!_currentParent)
        return;

    [_currentParent removeObserver:self forKeyPath:[self keyPathForAssociatedObjectID]];
}

/*! @ignore
*/
- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    if ([change objectForKey:CPKeyValueChangeOldKey] == [change objectForKey:CPKeyValueChangeNewKey])
        return;

    [self _fetchAssociatedObjectWithID:[_currentParent valueForKeyPath:[self keyPathForAssociatedObjectID]]];
}


#pragma mark -
#pragma mark Object Chooser Delegate

/*! @ignore
*/
- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser fetchObjects:(CPArray)someObjects
{
    [self didFetchAvailableAssociatedObjects:someObjects];
}

/*! @ignore
*/
- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser selectObjects:(CPArray)selectedObjects
{
    throw ("implement me");
}

/*! @ignore
*/
- (void)didObjectChooserCancelSelection:(NUObjectsChooser)anObjectChooser
{
    [self closePopover];
}

/*! @ignore
*/
- (NUCategory)categoryForObject:(id)anObject
{
    if (![_categoriesRegistry count])
        return;

    return [_categoriesRegistry objectForKey:[anObject RESTName]];
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


#pragma mark -
#pragma mark Delegate

/*! Sets the Delegates

    - (void)didAssociatorFetchAssociatedObject:(NUAbstractObjectAssociator)anAssociator
    - (void)didAssociatorChangeAssociation:(NUAbstractObjectAssociator)anAssociator
    - (void)didAssociatorAddAssociation:(NUAbstractObjectAssociator)anAssociator
    - (void)didAssociatorRemoveAssociation:(NUAbstractObjectAssociator)anAssociator
*/
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

/*! @ignore
*/
- (void)_sendDelegateDidAssociatorFetchAssociatedObject
{
    if (_implementedDelegateMethods & NUAbstractObjectAssociator_didAssociatorFetchAssociatedObject_)
        [_delegate didAssociatorFetchAssociatedObject:self];
}

/*! @ignore
*/
- (void)_sendDelegateDidAssociatorChangeAssociation
{
    if (_implementedDelegateMethods & NUAbstractObjectAssociator_didAssociatorChangeAssociation_)
        [_delegate didAssociatorChangeAssociation:self];
}

/*! @ignore
*/
- (void)_sendDelegateDidAssociatorAddAssociation
{
    if (_implementedDelegateMethods & NUAbstractObjectAssociator_didAssociatorAddAssociation_)
        [_delegate didAssociatorAddAssociation:self];
}

/*! @ignore
*/
- (void)_sendDelegateDidAssociatorRemoveAssociation
{
    if (_implementedDelegateMethods & NUAbstractObjectAssociator_didAssociatorRemoveAssociation_)
        [_delegate didAssociatorRemoveAssociation:self];
}

@end
