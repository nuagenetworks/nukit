/*
*   Filename:         NUModule.j
*   Created:          Tue Oct  9 11:54:17 PDT 2012
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
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
@import <AppKit/CPArrayController.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPButtonBar.j>
@import <AppKit/CPMenuItem.j>
@import <AppKit/CPOutlineView.j>
@import <AppKit/CPPopover.j>
@import <AppKit/CPSearchField.j>
@import <AppKit/CPSplitView.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPTabView.j>
@import <AppKit/CPTabViewItem.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPView.j>
@import <AppKit/CPViewController.j>
@import <RESTCappuccino/RESTCappuccino.j>
@import <TNKit/TNTableViewDataSource.j>
@import <TNKit/TNTabView.j>

@import "NUAdvancedFilteringViewController.j"
@import "NUCategory.j"
@import "NUDataTransferController.j"
@import "NUEditorsViewController.j"
@import "NUExpandableSearchField.j"
@import "NUJobExport.j"
@import "NUJobImport.j"
@import "NUKitObject.j"
@import "NUModuleContext.j"
@import "NUOutlineViewDataSource.j"
@import "NUSkin.j"
@import "NUTabViewItemPrototype.j"
@import "NUTotalNumberValueTransformer.j"

@class NUKit

@global CPApp
@global NUKitUserLoggedOutNotification
@global NURESTUserRoleCSPRoot
@global NURESTUserRoleOrgAdmin
@global _CPWindowDidChangeFirstResponderNotification


NUModuleRESTPageSize               = 50;

var NUModuleRESTPageLoadingTrigger = 500,
    NUModuleArchiveMaxSize         = 100,
    NUModuleSplitViewEditorMaxSize = 300,
    NUModuleSplitViewEditorMinSize = 100;

NUModuleAutoValidation                 = NO;
NUModuleUpdateMechanismRefetch         = @"REFETCH";
NUModuleUpdateMechanismRefetchHierachy = @"REFETCH_HIERARCHY";


NUModuleActionAdd                 = 1;
NUModuleActionDelete              = 2;
NUModuleActionEdit                = 3;
NUModuleActionExport              = 4;
NUModuleActionImport              = 5;
NUModuleActionInstantiate         = 6;
NUModuleActionInspect             = 7;

NUModuleTabViewModeText = 1;
NUModuleTabViewModeIcon = 2;


@implementation NUModule : CPViewController <CPTableViewDelegate, CPOutlineViewDelegate, CPPopoverDelegate, CPSplitViewDelegate, CPTabViewDelegate>
{
    @outlet CPButton                buttonHelp;
    @outlet CPButton                buttonOpenInExternalWindow;
    @outlet CPButtonBar             buttonBarMain;
    @outlet CPPopover               popover;
    @outlet CPSearchField           filterField;
    @outlet CPSplitView             splitViewEditor;
    @outlet CPSplitView             splitViewMain;
    @outlet CPTableView             tableView;
    @outlet CPTextField             fieldModuleSubtitle;
    @outlet CPTextField             fieldModuleTitle;
    @outlet CPTextField             fieldTotalEntities;

    @outlet CPView                  maskingView;
    @outlet CPView                  multipleSelectedObjectsMaskingView;
    @outlet CPView                  viewEditObject;
    @outlet CPView                  viewEditorContainer;
    @outlet CPView                  viewGettingStarted;
    @outlet CPView                  viewMainTableViewContainer;
    @outlet CPView                  viewPopoverModuleTitleContainer;
    @outlet CPView                  viewSubtitleContainer;
    @outlet CPView                  viewTabsContainer;
    @outlet CPView                  viewTitleContainer;
    @outlet NUEditorsViewController editorController                        @accessors(property=editorController);
    @outlet TNTabView               tabViewContent                          @accessors(property=tabViewContent);

    BOOL                            _disableViewGettingStarted              @accessors(property=disableViewGettingStarted);
    BOOL                            _enableAdvancedSearch                   @accessors(property=enableAdvancedSearch);
    BOOL                            _isListeningForPush                     @accessors(getter=isListeningForPush);
    BOOL                            _isVisible                              @accessors(getter=isVisible);
    BOOL                            _showsInExternalWindow                  @accessors(property=showsInExternalWindow);
    BOOL                            _showsInPopover                         @accessors(property=showsInPopover);
    BOOL                            _stickyEditor                           @accessors(property=stickyEditor);
    BOOL                            _usesPagination                         @accessors(getter=isUsingPagination, setter=setUsesPagination:);
    CGSize                          _modulePopoverBaseSize                  @accessors(property=modulePopoverBaseSize);
    CPArray                         _categories                             @accessors(property=categories);
    CPArray                         _currentSelectedObjects                 @accessors(property=currentSelectedObjects);
    CPArray                         _masterGrouping                         @accessors(property=masterGrouping);
    CPArray                         _subModules                             @accessors(property=subModules);
    CPDictionary                    _cuccapPrefixesRegistry                 @accessors(property=cuccapPrefixesRegistry);
    CPDictionary                    _dataViews                              @accessors(property=dataViews);
    CPNumber                        _autoResizeSplitViewSize                @accessors(property=autoResizeSplitViewSize);
    CPNumber                        _latestPageLoaded                       @accessors(property=latestPageLoaded);
    CPNumber                        _multipleSelectionMaskingViewTrigger    @accessors(property=multipleSelectionMaskingViewTrigger);
    CPNumber                        _totalNumberOfEntities                  @accessors(property=totalNumberOfEntities);
    CPPredicate                     _masterFilter                           @accessors(property=masterFilter);
    CPString                        _dataViewIdentifierPrefix               @accessors(property=dataViewIdentifierPrefix);
    CPString                        _masterOrdering                         @accessors(property=masterOrdering);
    CPString                        _moduleSubtitle                         @accessors(property=moduleSubtitle);
    CPString                        _moduleTitle                            @accessors(property=moduleTitle);
    CPTabViewItem                   _tabViewItem                            @accessors(property=tabViewItem);
    CPURL                           _helpURL                                @accessors(property=helpURL);
    CPWindow                        _externalWindow                         @accessors(property=externalWindow);
    id                              _currentParent                          @accessors(property=currentParent);
    id                              _delegate                               @accessors(property=delegate);
    id                              _filter                                 @accessors(property=filter);
    int                             _splitViewMaxX                          @accessors(property=splitViewMaxX);
    int                             _splitViewMinX                          @accessors(property=splitViewMinX);
    NUModule                        _parentModule                           @accessors(property=parentModule);
    NUModuleContext                 _currentContext                         @accessors(property=currentContext);


    BOOL                            _inhibitsSelectionUpdate;
    BOOL                            _isListeningForEditorSelectionChangeNotification;
    BOOL                            _isObservingScrollViewBounds;
    BOOL                            _isProcessingPush;
    BOOL                            _overrideShouldHide;
    BOOL                            _paginationSynchronizing;
    BOOL                            _reloadHierarchyAfterRefetch;
    BOOL                            _scrollToSelectedRows;
    BOOL                            _selectionDidChanged;
    CPArray                         _activeSubModules;
    CPArray                         _activeTransactionsIDs;
    CPArray                         _contextualMenuItemRegistry;
    CPArray                         _currentPermittedActions;
    CPArray                         _latestSortDescriptors;
    CPArray                         _previousSelectedObjects;
    CPArray                         _removedObjectsIDs;
    CPArray                         _sortedActionsForMenu;
    CPButton                        _buttonAddObject;
    CPButton                        _buttonDeleteObject;
    CPButton                        _buttonEditObject;
    CPButton                        _buttonFirstCreate
    CPButton                        _buttonFirstImport;
    CPButton                        _buttonImportObject;
    CPButton                        _buttonExportObject;
    CPButton                        _buttonInstantiateObject;
    CPDictionary                    tabViewPropertiesCache;
    CPDictionary                    _contextRegistry;
    CPDictionary                    _controlsForActionRegistry;
    CPDictionary                    _parentModuleHierarchyCache;
    CPDictionary                    _selectionArchive;
    CPMenu                          _contextualMenu;
    CPNumber                        _maxPossiblePage;
    CPPopover                       _modulePopover;
    CPTimer                         _timerReloadLatestPage;
    id                              _dataSource;
    id                              _fileUpload;
    int                             _numberOfRemainingContextsToLoad;
}


#pragma mark -
#pragma mark Class Methods

+ (BOOL)autoConfirm
{
    return NUModuleAutoValidation;
}

+ (void)setAutoConfirm:(BOOL)isEnabled
{
    NUModuleAutoValidation = isEnabled;
}

+ (BOOL)isTableBasedModule
{
    return YES;
}

+ (CPString)moduleName
{
    return [self className];
}

+ (BOOL)moduleTabViewMode
{
    return NUModuleTabViewModeText;
}

+ (CPString)moduleTabIconIdentifier
{
    return nil;
}

+ (CPImage)moduleIcon
{
    return nil;
}

+ (CPString)moduleIdentifier
{
    return @"net.nuagenetworks.vsd." + [[self className] lowercaseString];
}

+ (BOOL)automaticContextManagement
{
    return YES;
}

+ (BOOL)automaticSelectionSaving
{
    return YES;
}

+ (BOOL)automaticChildrenListsDiscard
{
    return YES;
}

+ (BOOL)commitFetchedObjects
{
    return YES;
}


#pragma mark -
#pragma mark Initialization

- (void)viewDidLoad
{
    [[self view] setBackgroundColor:NUSkinColorGreyLighter];

    _activeSubModules                                   = [];
    _activeTransactionsIDs                              = [];
    _autoResizeSplitViewSize                            = 265;
    tabViewPropertiesCache                             = @{};
    _categories                                         = [];
    _contextRegistry                                    = @{};
    _contextualMenuItemRegistry                         = @{};
    _controlsForActionRegistry                          = @{};
    _cuccapPrefixesRegistry                             = @{};
    _currentPermittedActions                            = [];
    _currentSelectedObjects                             = [];
    _dataViewIdentifierPrefix                           = @"";
    _dataViews                                          = @{};
    _disableViewGettingStarted                          = NO;
    _enableAdvancedSearch                               = YES;
    _helpURL                                            = nil;
    _inhibitsSelectionUpdate                            = NO;
    _isListeningForEditorSelectionChangeNotification    = NO;
    _isObservingScrollViewBounds                        = NO;
    _latestPageLoaded                                   = -1;
    _masterGrouping                                     = nil;
    _masterOrdering                                     = nil;
    _modulePopoverBaseSize                              = [[self view] frameSize];
    _multipleSelectionMaskingViewTrigger                = 2;
    _paginationSynchronizing                            = NO;
    _parentModuleHierarchyCache                         = @{};
    _previousSelectedObjects                            = [];
    _removedObjectsIDs                                  = [];
    _scrollToSelectedRows                               = NO;
    _selectionDidChanged                                = NO;
    _selectionArchive                                   = @{};
    _showsInPopover                                     = NO;
    _stickyEditor                                       = YES;
    _subModules                                         = [];
    _totalNumberOfEntities                              = -1;
    _usesPagination                                     = [[self class] isTableBasedModule];

    _contextualMenu = [[CPMenu alloc] init];
    [_contextualMenu setAutoenablesItems:NO];

    _sortedActionsForMenu = [self configureContextualMenu];

    if (tableView)
    {
        switch ([tableView className])
        {
            case @"CPTableView":
                _dataSource = [[TNTableViewDataSource alloc] init];
                [_dataSource setDelegate:self];
                break;

            case @"CPOutlineView":
                var button = [CPButton buttonWithTitle:nil];
                [button setEnabled:NO];
                [button setHidden:YES];
                [tableView setDisclosureControlPrototype:button];
                [tableView setIndentationPerLevel:0];
                _dataSource = [[NUOutlineViewDataSource alloc] init];
                [self registerDataViewWithName:@"categoryDataView" forClass:NUCategory];
                break;
        }

        _cucappID(tableView, [self className]);

        [tableView setIntercellSpacing:CGSizeMakeZero()];
        [tableView setBackgroundColor:NUSkinColorWhite];
        [tableView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleRegular];

        [_dataSource setTable:tableView];
        [tableView setDataSource:_dataSource];
        [tableView setDelegate:self];
        [tableView setTarget:self];

        [tableView setNextKeyView:tabViewContent];
        [tableView setDoubleAction:@selector(openEditObjectPopover:)];

        // set ourself as the scroll view delegate
        [[[tableView superview] superview] setDelegate:self];
    }

    if (filterField)
    {
        [filterField setTarget:self];
        [filterField setAction:@selector(filterObjects:)];
        [filterField setNextKeyView:tableView];

        var searchButton = [filterField searchButton];
        [searchButton setTarget:self];
        [searchButton setAction:@selector(clickSearchButton:)];
    }

    if (buttonBarMain)
    {
        _buttonAddObject = [CPButtonBar plusButton];
        [_buttonAddObject setImage:NUSkinImageButtonPlus];
        [_buttonAddObject setAlternateImage:NUSkinImageButtonPlusAlt];
        [_buttonAddObject setButtonType:CPMomentaryChangeButton];
        [_buttonAddObject setTarget:self];
        [_buttonAddObject setAction:@selector(openNewObjectPopover:)];
        [self registerControl:_buttonAddObject forAction:NUModuleActionAdd];

        _buttonImportObject = [CPButtonBar plusButton];
        [_buttonImportObject setImage:NUSkinImageButtonImport];
        [_buttonImportObject setAlternateImage:NUSkinImageButtonImportAlt];
        [_buttonImportObject setButtonType:CPMomentaryChangeButton];
        [_buttonImportObject setTarget:self];
        [_buttonImportObject setAction:@selector(import:)];
        [self registerControl:_buttonImportObject forAction:NUModuleActionImport];

        _buttonExportObject = [CPButtonBar plusButton];
        [_buttonExportObject setImage:NUSkinImageButtonExport];
        [_buttonExportObject setAlternateImage:NUSkinImageButtonExportAlt];
        [_buttonExportObject setButtonType:CPMomentaryChangeButton];
        [_buttonExportObject setTarget:self];
        [_buttonExportObject setAction:@selector(exportSelectedObjects:)];
        [self registerControl:_buttonExportObject forAction:NUModuleActionExport];

        _buttonInstantiateObject = [CPButtonBar plusButton];
        [_buttonInstantiateObject setImage:NUSkinImageButtonInstantiate];
        [_buttonInstantiateObject setAlternateImage:NUSkinImageButtonInstantiateAlt];
        [_buttonInstantiateObject setButtonType:CPMomentaryChangeButton];
        [_buttonInstantiateObject setTarget:self];
        [_buttonInstantiateObject setAction:@selector(openNewObjectPopover:)];
        [self registerControl:_buttonInstantiateObject forAction:NUModuleActionInstantiate];

        _buttonEditObject = [CPButtonBar minusButton];
        [_buttonEditObject setImage:NUSkinImageButtonEdit];
        [_buttonEditObject setAlternateImage:NUSkinImageButtonEditAlt];
        [_buttonEditObject setButtonType:CPMomentaryChangeButton];
        [_buttonEditObject setTarget:self];
        [_buttonEditObject setAction:@selector(openEditObjectPopover:)];
        [self registerControl:_buttonEditObject forAction:NUModuleActionEdit];

        _buttonDeleteObject = [CPButtonBar minusButton];
        [_buttonDeleteObject setImage:NUSkinImageButtonMinus];
        [_buttonDeleteObject setAlternateImage:NUSkinImageButtonMinusAlt];
        [_buttonDeleteObject setButtonType:CPMomentaryChangeButton];
        [_buttonDeleteObject setTarget:self];
        [_buttonDeleteObject setAction:@selector(openDeleteObjectPopover:)];
        [self registerControl:_buttonDeleteObject forAction:NUModuleActionDelete];

        [buttonBarMain setButtons:[_buttonAddObject, _buttonDeleteObject, _buttonEditObject, _buttonInstantiateObject, _buttonImportObject, _buttonExportObject]];
    }

    if (viewGettingStarted)
    {
        var container = [[viewGettingStarted subviewWithTag:@"container"] subviewWithTag:@"buttonscontainer"];

        _buttonFirstCreate = [container subviewWithTag:@"first_create_button"];

        if (_buttonFirstCreate && _buttonAddObject)
        {
            [_buttonFirstCreate setBordered:NO];
            [_buttonFirstCreate setButtonType:CPMomentaryChangeButton];
            [_buttonFirstCreate setValue:NUImageInKit("button-first-create.png", 32.0, 32.0) forThemeAttribute:@"image" inState:CPThemeStateNormal];
            [_buttonFirstCreate setValue:NUImageInKit("button-first-create-pressed.png", 32.0, 32.0) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
            [_buttonFirstCreate setTarget:self];
            [_buttonFirstCreate setAction:@selector(openNewObjectPopover:)];

            [self registerControl:_buttonFirstCreate forAction:NUModuleActionAdd];
        }

        _buttonFirstImport = [container subviewWithTag:@"first_import_button"];

        if (_buttonFirstImport && _buttonAddObject)
        {
            [_buttonFirstImport setBordered:NO];
            [_buttonFirstImport setButtonType:CPMomentaryChangeButton];
            [_buttonFirstImport setValue:NUImageInKit("button-first-import.png", 32.0, 32.0) forThemeAttribute:@"image" inState:CPThemeStateNormal];
            [_buttonFirstImport setValue:NUImageInKit("button-first-import-pressed.png", 32.0, 32.0) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
            [_buttonFirstImport setTarget:self];
            [_buttonFirstImport setAction:@selector(import:)];

            [self registerControl:_buttonFirstImport forAction:NUModuleActionImport];
        }

        [viewGettingStarted setBackgroundColor:[CPColor whiteColor]];
    }

    if (buttonHelp)
    {
        [buttonHelp setTarget:self];
        [buttonHelp setAction:@selector(openHelpWindow:)];
        [buttonHelp setBordered:NO];
        [buttonHelp setButtonType:CPMomentaryChangeButton];

        [buttonHelp setValue:NUSkinImageButtonHelp forThemeAttribute:@"image"];
        [buttonHelp setValue:NUSkinImageButtonHelpPressed forThemeAttribute:@"image" inState:CPThemeStateHighlighted];

        // @TODO: remove this when help will be written
        [buttonHelp setHidden:YES];
    }

    if (maskingView)
        [maskingView setBackgroundColor:NUSkinColorGreyLighter];

    if (multipleSelectedObjectsMaskingView)
        [multipleSelectedObjectsMaskingView setBackgroundColor:NUSkinColorGreyLighter];

    if (viewTitleContainer)
        [viewTitleContainer setBackgroundColor:NUSkinColorGreyLight];

    if (viewSubtitleContainer)
        [viewSubtitleContainer setBackgroundColor:NUSkinColorGreyLight];

    if (splitViewMain)
    {
        [splitViewMain setButtonBar:buttonBarMain forDividerAtIndex:0];
        [splitViewMain setDelegate:self];
    }

    if (fieldTotalEntities)
    {
        var opts = @{CPValueTransformerNameBindingOption: NUTotalNumberValueTransformerName};
        [fieldTotalEntities bind:CPValueBinding toObject:self withKeyPath:"formatedTotalNumberOfEntities" options:opts];
        [fieldTotalEntities setTextColor:NUSkinColorBlack];

        [[fieldTotalEntities superview] setBackgroundColor:NUSkinColorGreyLighter];

        _cucappID(fieldTotalEntities, @"field_total_" + [self className]);
    }

    if (fieldModuleTitle)
    {
        [self setModuleTitle:[fieldModuleTitle stringValue]];
        [fieldModuleTitle setTextColor:NUSkinColorBlack];
        [fieldModuleTitle bind:CPValueBinding toObject:self withKeyPath:@"moduleTitle" options:nil];
    }

    if (fieldModuleSubtitle)
    {
        [self setModuleSubtitle:[fieldModuleSubtitle stringValue]];
        [fieldModuleSubtitle setTextColor:NUSkinColorBlack];
        [fieldModuleSubtitle bind:CPValueBinding toObject:self withKeyPath:@"moduleSubtitle" options:nil];
    }

    if (buttonOpenInExternalWindow)
    {
        [buttonOpenInExternalWindow setToolTip:@"Open this in an external browser window"];
        [buttonOpenInExternalWindow setBordered:NO];
        [buttonOpenInExternalWindow setButtonType:CPMomentaryChangeButton];
        [buttonOpenInExternalWindow setValue:NUImageInKit(@"button-new-window.png", 16, 16) forThemeAttribute:@"image" inState:CPThemeStateNormal];
        [buttonOpenInExternalWindow setValue:NUImageInKit(@"button-new-window-pressed.png", 16, 16) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
        [buttonOpenInExternalWindow setTarget:self];
        [buttonOpenInExternalWindow setAction:@selector(openModuleInExternalWindow:)];
    }

    if (viewPopoverModuleTitleContainer)
    {
        [fieldModuleTitle setTextColor:NUSkinColorWhite];
        [viewPopoverModuleTitleContainer setBackgroundColor:NUSkinColorBlack];
    }

    if (tabViewContent)
    {
        switch ([[self class] moduleTabViewMode])
        {
            case NUModuleTabViewModeText:
                [tabViewContent setTabItemViewPrototype:[NUTabViewItemPrototype new]];
                break;

            case NUModuleTabViewModeIcon:
                [tabViewContent setTabItemViewPrototype:[NUImageTabViewItemPrototype new]];
                [tabViewContent._viewTabs setBorderTopColor:nil];
                break;
        }

        [tabViewContent setDelegate:self];
    }

    if (editorController)
    {
        [editorController view];

        [self configureEditor:editorController];

        if ([self isTableBasedModule])
            [tableView setAction:@selector(tableViewDidClick:)];

        if (![editorController parentModule])
        {
            [self showModuleEditor:_stickyEditor];
            [editorController setParentModule:self];
            [viewEditorContainer setBackgroundColor:NUSkinColorGreyLight];

            if (splitViewEditor)
                [splitViewEditor setDelegate:self];

            if (viewEditorContainer)
                viewEditorContainer._DOMElement.style.boxShadow = "0 0 10px " + [NUSkinColorGrey cssString];
        }
    }

    [self displayCurrentMaskingView];

    [self configureAdditionalControls];
    [self configureCucappIDs];
    [self configureContexts];

    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_userLoggedOut:) name:NUKitUserLoggedOutNotification object:nil];
}

- (BOOL)isTableBasedModule
{
    return [[self class] isTableBasedModule];
}


#pragma mark -
#pragma mark Notification Handlers

- (void)_userLoggedOut:(CPNotification)aNotification
{
    [self closeAllPopovers];

    if (_modulePopover)
        [_modulePopover close];

    _selectionArchive = @{};
    _previousSelectedObjects = [];
    [self moduleLoggingOut];
}

- (void)moduleLoggingOut
{

}


#pragma mark -
#pragma mark Context Management

- (void)registerContext:(NUModuleContext)aContext forClass:(Class)aClass
{
    [aContext setManagedObjectClass:aClass];
    [aContext setDelegate:self];

    [_contextRegistry setObject:aContext forKey:[aClass RESTName]];

    [self setCurrentContext:aContext];
}

- (BOOL)containsContextWithIdentifier:(CPString)anIdentifier
{
    var contexts = [_contextRegistry allValues];

    for (var i = [contexts count] - 1; i >= 0; i--)
    {
        if ([contexts[i] identifier] == anIdentifier)
            return YES;
    }
    return NO;
}

- (NUModuleContext)contextWithIdentifier:(CPString)anIdentifier
{
    var contexts = [_contextRegistry allValues];

    for (var i = [contexts count] - 1; i >= 0; i--)
    {
        var context = contexts[i];

        if ([context identifier] == anIdentifier)
            return context;
    }
}

- (void)setCurrentContext:(NUModuleContext)aContext
{
    if (aContext == _currentContext)
        return;

    _currentContext = aContext;
    [_currentContext setParentObject:_currentParent];
    [_currentContext setSelectedObjects:_currentSelectedObjects];

    [self updateCucappIDsAccordingToContext:aContext];
}

- (void)setCurrentContextWithIdentifier:(CPString)anIdentifier
{
    if ([_currentContext identifier] == anIdentifier)
        return;

    [self setCurrentContext:[self contextWithIdentifier:anIdentifier]];
}

- (void)_cleanContexts
{
    var contexts = [_contextRegistry allValues];

    for (var i = [contexts count] - 1; i >= 0; i--)
    {
        [contexts[i] setEditedObject:nil];
        [contexts[i] setParentObject:nil];
    }
}

#pragma mark Context Management Internal API

- (void)configureContexts
{
}

- (NUModuleContext)defaultContextForAction:(id)anAction
{
    return _currentContext;
}

- (CPArray)moduleCurrentActiveContexts
{
    return _currentContext ? [_currentContext]: [];
}


#pragma mark -
#pragma mark Module Popover Embededed Management

- (void)setShowsInPopover:(BOOL)shoulShowInPopover
{
    _showsInPopover = shoulShowInPopover;

    if (!_showsInPopover)
        return;

    _modulePopover = [CPPopover new];
    [_modulePopover setContentViewController:self];
    [_modulePopover setBehavior:CPPopoverBehaviorTransient];
    [_modulePopover setDelegate:self];

    [viewMainTableViewContainer setBorderColor:NUSkinColorGreyLight];
}

- (void)showOnView:(CPView)aView forParentObject:(id)aParentObject
{
    [self showOnView:aView relativeToRect:nil forParentObject:aParentObject];
}

- (void)showOnView:(CPView)aView relativeToRect:(CGRect)aRect forParentObject:(id)aParentObject
{
    [self view];

    if (!_modulePopover)
        [self setShowsInPopover:YES];

    [self setCurrentParent:aParentObject];

    if (buttonOpenInExternalWindow && ([[CPApp currentEvent] modifierFlags] & CPShiftKeyMask))
    {
        [self openModuleInExternalWindow:nil];
        return;
    }

    if ([_modulePopover isShown])
        [_modulePopover close];

    [[_modulePopover contentViewController] view]._DOMElement.style.borderRadius = "5px";
    [_modulePopover showRelativeToRect:aRect ofView:aView preferredEdge:nil];
}

- (void)closeModulePopover
{
    if (!_showsInPopover)
        return;

    [[_modulePopover contentViewController] view]._DOMElement.style.borderRadius = "";
    [_modulePopover close];
}


#pragma mark -
#pragma mark Parent Management

- (void)setCurrentParent:(id)aParent
{
    if ([aParent isKindOfClass:NUCategory])
        [CPException raise:CPInternalInconsistencyException reason:"Cannot set a NUCategory as current parent"];

    if (_currentParent == aParent)
        return;

    _currentParent = aParent;

    if (_currentParent)
        CPLog.debug("CURRENTPARENT: %@: setting current to object object with ID %@", [self className], [_currentParent ID])
    else
        CPLog.debug("CURRENTPARENT: %@: resetting current parent to nil", [self className])

    var contexts = [_contextRegistry allValues];

    for (var i = [contexts count] - 1; i >= 0; i--)
        [contexts[i] setParentObject:_currentParent];

    if (!_currentParent)
        [self _flushTableView];

    [self moduleDidSetCurrentParent:_currentParent];
}

#pragma mark Parent Management Internal API

- (void)moduleDidSetCurrentParent:(id)aParent
{
}


#pragma mark -
#pragma mark Menu Management

- (CPArray)configureContextualMenu
{
    var menuItemAdd = [[CPMenuItem alloc] initWithTitle:@"Add..." action:@selector(openNewObjectPopover:) keyEquivalent:@""];
    [self registerMenuItem:menuItemAdd forAction:NUModuleActionAdd];

    var menuItemEdit = [[CPMenuItem alloc] initWithTitle:@"Edit..." action:@selector(openEditObjectPopover:) keyEquivalent:@""];
    [self registerMenuItem:menuItemEdit forAction:NUModuleActionEdit];

    var menuItemDelete = [[CPMenuItem alloc] initWithTitle:@"Delete..." action:@selector(openDeleteObjectPopover:) keyEquivalent:@""];
    [self registerMenuItem:menuItemDelete forAction:NUModuleActionDelete];

    var menuItemInstantiate = [[CPMenuItem alloc] initWithTitle:@"Instantiate..." action:@selector(openNewObjectPopover:) keyEquivalent:@""];
    [self registerMenuItem:menuItemInstantiate forAction:NUModuleActionInstantiate];

    var menuItemImport = [[CPMenuItem alloc] initWithTitle:@"Import..." action:@selector(import:) keyEquivalent:@""];
    [self registerMenuItem:menuItemImport forAction:NUModuleActionImport];

    var menuItemExport = [[CPMenuItem alloc] initWithTitle:@"Export" action:@selector(exportSelectedObjects:) keyEquivalent:@""];
    [self registerMenuItem:menuItemExport forAction:NUModuleActionExport];

    var menuInspect = [[CPMenuItem alloc] initWithTitle:@"Inspect" action:@selector(openInspector:) keyEquivalent:@""];
    [self registerMenuItem:menuInspect forAction:NUModuleActionInspect];

    return [NUModuleActionAdd, NUModuleActionEdit, NUModuleActionDelete, NUModuleActionInstantiate, NUModuleActionImport, NUModuleActionExport,  NUModuleActionInspect];
}

- (void)registerMenuItem:(CPMenuItem)aMenuItem forAction:(int)anAction
{
    if (![_controlsForActionRegistry containsKey:anAction])
        [_controlsForActionRegistry setObject:[] forKey:anAction];

    [_contextualMenuItemRegistry setObject:aMenuItem forKey:anAction];
    [aMenuItem setTarget:self];
}

- (id)actionForMenuItem:(CPMenuItem)aMenuItem
{
    return [[_contextualMenuItemRegistry allKeysForObject:aMenuItem] firstObject];
}

- (CPMenu)_currentContextualMenu
{
    [self _updateCurrentSelection];
    [_contextualMenu removeAllItems];

    var sortedActions = [self _sortedPermittedActions];

    for (var i = 0, c = [sortedActions count]; i < c; i++)
        [_contextualMenu addItem:[_contextualMenuItemRegistry objectForKey:sortedActions[i]]];

    if (![[_contextualMenu itemArray] count])
        return nil;

    return _contextualMenu;
}

- (CPArray)_sortedPermittedActions
{
    var sortedActions = _sortedActionsForMenu,
        ret = [];

    for (var i = 0, c = [sortedActions count]; i < c; i++)
    {
        var action = sortedActions[i];

        if ([_currentPermittedActions containsObject:action])
            [ret addObject:action];
    }

    return ret;
}

#pragma mark Menu Management Internal API

- (CPControl)defaultPopoverTargetForMenuItem
{
    return tableView;
}


#pragma mark -
#pragma mark Visibility Management

- (void)willShow
{
    if (_isVisible)
        return;

    _isProcessingPush    = NO;
    _isVisible           = YES;

    [[self view] setNextResponder:self];

    [self cleanOutdatedArchivedSelection];
    [self adjustSplitViewSize];
    [self registerForPushNotification];
    [self displayCurrentMaskingView];
    [self updatePermittedActions];

    if (splitViewEditor)
        [[CPRunLoop mainRunLoop] performBlock:function(){[splitViewEditor setPosition:([splitViewEditor frameSize].width - NUModuleSplitViewEditorMaxSize) ofDividerAtIndex:0];} argument:nil order:0 modes:[CPDefaultRunLoopMode]];

    [self moduleDidShow];

    CPLog.debug("MODULE VISIBILIY: %@ is now visible", [self className]);

    if (![self isTableBasedModule])
        [self refreshActiveSubModules];

    [self reload];
}

- (BOOL)shouldHide
{
    if (!_isVisible)
        return YES;

    if (editorController && ![editorController checkIfEditorAgreeToHide])
        return NO;

    for (var i = [_subModules count] - 1; i >= 0; i--)
        if (![_subModules[i] shouldHide])
            return NO;

    return [self moduleShouldHide];
}

- (void)willHide
{
    if (!_isVisible)
        return;

    [self hideLoading];
    [self archiveCurrentSelection];
    [self hideAllSubModules];

    if (editorController)
        [editorController setCurrentParent:nil];

    [self moduleWillHide];

    _isVisible           = NO;
    _isProcessingPush    = NO;
    _filter              = @"";

    [filterField setStringValue:@""];

    [_activeTransactionsIDs removeAllObjects];
    [_previousSelectedObjects removeAllObjects];
    [_currentSelectedObjects removeAllObjects];

    [self _removeScrollViewObservers];
    [self unregisterFromPushNotification];
    [self closeAllPopovers];
    [self _flushTableView];
    [self _cleanContexts];
    [self _discardCurrentParentChildren];

    // in updateModuleTitle and updateModuleSubtitle
    // it is very common that subclasses bind this value
    // to the currentParent with a NU*ModuleSubtitleValueTransformer
    // so let's simply force unbind
    [self unbind:@"moduleSubtitle"];
    [self unbind:@"moduleTitle"];

    CPLog.debug("MODULE VISIBILIY: %@ is now hidden", [self className]);
}

#pragma mark Visibility Management Internal API

- (void)moduleDidShow
{

}

- (BOOL)moduleShouldHide
{
    return YES;
}

- (void)moduleWillHide
{

}


#pragma mark -
#pragma mark Memory Management

- (void)_discardCurrentParentChildren
{
    if (![[self class] automaticChildrenListsDiscard])
        return;

    var contexts = [_contextRegistry allValues];

    for (var i = [contexts count] - 1; i >= 0; i--)
        [_currentParent discardFetcherForRESTName:[contexts[i] identifier]];
}


#pragma mark -
#pragma mark Loading and Pagination

- (void)reload
{
    _latestPageLoaded                = -1;
    _maxPossiblePage                 = -1;
    _removedObjectsIDs               = [];
    _numberOfRemainingContextsToLoad = [_contextRegistry count];

    [_activeTransactionsIDs removeAllObjects];
    [self setTotalNumberOfEntities:-1];
    [self setPaginationSynchronizing:NO];
    [self _flushTableView];
    [self updateModuleTitle];

    if (!_currentParent)
        return;

    [self flushCategoriesContent];

    if (!_isProcessingPush)
        [self showLoading];

    if ([[self class] automaticContextManagement])
    {
        var contexts = [self moduleCurrentActiveContexts];

        for (var i = [contexts count] - 1; i >= 0; i--)
            [self _reloadUsingContext:contexts[i]];
    }

    [self moduleDidReload];
}

- (void)_reloadUsingContext:(NUModuleContext)aContext
{
    var fetcherKeyPath = [aContext fetcherKeyPath],
        fetcher = [_currentParent valueForKeyPath:fetcherKeyPath];

    if (!fetcherKeyPath)
        [CPException raise:CPInternalInconsistencyException reason:"Context has no defined fetcherKeyPath in module " + self];

    if (!fetcher)
        [CPException raise:CPInternalInconsistencyException reason:"Context cannot find fetcher " + fetcherKeyPath  + " in currentParent  " + _currentParent + " of module "+ self];

    if (_usesPagination)
        [self loadFirstPageUsingFetcher:fetcher];
    else
        [self loadEverythingUsingFetcher:fetcher];
}

- (void)loadPage:(CPNumber)aPage usingFetcher:(NURESTFetcher)aFetcher
{
    if (aPage === nil)
        _latestPageLoaded = -1;

    if (_maxPossiblePage != -1 && aPage > _maxPossiblePage)
    {
        CPLog.debug("PAGINATION: ignoring: aPage (%@) > _maxPossiblePage (%@): ", aPage, _maxPossiblePage);
        return;
    }

    _latestPageLoaded = MAX(aPage, _latestPageLoaded);

    CPLog.debug("PAGINATION: Loading page #%@ using fetcher %@", aPage, aFetcher);

    var ID = [aFetcher fetchWithMatchingFilter:[self filter]
                                  masterFilter:[self masterFilter]
                                     orderedBy:[self masterOrdering]
                                     groupedBy:[self masterGrouping]
                                          page:aPage
                                      pageSize:NUModuleRESTPageSize
                                        commit:[[self class] commitFetchedObjects]
                               andCallSelector:@selector(__fetcher:ofObject:didFetchContent:)
                                      ofObject:self
                                         block:nil];

    [_activeTransactionsIDs addObject:ID];
}

- (void)loadEverythingUsingFetcher:(NURESTFetcher)aFetcher
{
    [aFetcher flush];
    [self loadPage:nil usingFetcher:aFetcher];
}

- (void)loadFirstPageUsingFetcher:(NURESTFetcher)aFetcher
{
    [aFetcher flush];
    [self loadPage:0 usingFetcher:aFetcher];
}

- (void)loadNextPageUsingFetcher:(NURESTFetcher)aFetcher
{
    [self loadPage:(_latestPageLoaded + 1) usingFetcher:aFetcher];
}

- (void)reloadLatestPageUsingFetcher:(NURESTFetcher)aFetcher
{
    [self loadPage:_latestPageLoaded usingFetcher:aFetcher];
}

- (void)loadNextPage
{
    // CS 01/11/2016: For now, we don't deal with pagination when using categories...
    // Meaning that if we deal with pagination, we have only one context!
    var contexts       = [self moduleCurrentActiveContexts],
        fetcherKeyPath = [[contexts firstObject] fetcherKeyPath],
        fetcher        = [_currentParent valueForKeyPath:fetcherKeyPath];

    if (fetcher)
        [self loadNextPageUsingFetcher:fetcher];
    else
        [CPException raise:CPInternalInconsistencyException reason:"Cannot find fetcher to load next page in module " + self];
}

- (void)reloadLatestPage
{
    if (_timerReloadLatestPage)
    {
        [self setPaginationSynchronizing:NO];
        [_timerReloadLatestPage invalidate];
    }

    [self setPaginationSynchronizing:YES];

    _timerReloadLatestPage = [CPTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_performReloadLatestPage:) userInfo:nil repeats:NO];
}

- (void)_performReloadLatestPage:(CPTimer)aTimer
{
    var fetcherKeyPath = [_currentContext fetcherKeyPath],
        fetcher = [_currentParent valueForKeyPath:fetcherKeyPath];

    if (fetcher)
        [fetcher countWithMatchingFilter:[self filter]
                               masterFilter:[self masterFilter]
                                  groupedBy:[self masterGrouping]
                            andCallSelector:@selector(_fetcher:ofObject:didCountChildren:)
                                   ofObject:self
                                      block:nil];
    else
        [self setPaginationSynchronizing:NO];
}

- (void)_fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didCountChildren:(int)aCount
{
    [self setPaginationSynchronizing:NO];
    [self setTotalNumberOfEntities:aCount];
    [self _synchronizePagination];

    [self reloadLatestPageUsingFetcher:aFetcher];
}

- (void)_synchronizePagination
{
    if (_latestPageLoaded == -1)
        return;

    _maxPossiblePage    = MAX(Math.ceil(_totalNumberOfEntities / NUModuleRESTPageSize) - 1, 0);
    _latestPageLoaded   = MAX(Math.ceil([_dataSource count] / NUModuleRESTPageSize) - 1, 0);

    CPLog.debug("PAGINATION: Synchronized pagination is now %@/%@ (objects: %@/%@)", _latestPageLoaded, _maxPossiblePage, [_dataSource count], _totalNumberOfEntities);
}

- (void)setPaginationSynchronizing:(BOOL)isSycing
{
    [self willChangeValueForKey:@"formatedTotalNumberOfEntities"];
    _paginationSynchronizing = isSycing;
    [self didChangeValueForKey:@"formatedTotalNumberOfEntities"];
}

- (void)_addScrollViewObservers
{
    if (![self isTableBasedModule] || _isObservingScrollViewBounds)
        return;

    _isObservingScrollViewBounds = YES;

    var scrollViewClipView = [[[tableView superview] superview] contentView];
    [scrollViewClipView addObserver:self forKeyPath:@"bounds" options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
}

- (void)_removeScrollViewObservers
{
    if (![self isTableBasedModule] || !_isObservingScrollViewBounds)
        return;

    _isObservingScrollViewBounds = NO;

    var scrollViewClipView = [[[tableView superview] superview] contentView];
    [scrollViewClipView removeObserver:self forKeyPath:@"bounds"];
}

#pragma mark Reloading Internal API

- (void)moduleDidReload
{

}


#pragma mark -
#pragma mark Object Counting

- (void)formatedTotalNumberOfEntities
{
    if (_paginationSynchronizing)
        return @"synchronizing...";

    if (_totalNumberOfEntities == -1)
        return "loading...";

    if (_totalNumberOfEntities == 0)
        return _filter ? "No matches" : "Empty";

    return (_totalNumberOfEntities < 2) ? _totalNumberOfEntities + " object" : _totalNumberOfEntities + " objects";
}

- (void)setTotalNumberOfEntities:(CPNumber)aTotal
{
    [self willChangeValueForKey:@"totalNumberOfEntities"];
    [self willChangeValueForKey:@"formatedTotalNumberOfEntities"];
    _totalNumberOfEntities = aTotal;
    [self didChangeValueForKey:@"totalNumberOfEntities"];
    [self didChangeValueForKey:@"formatedTotalNumberOfEntities"];
}

- (void)_updateGrandTotal
{
    var grandTotal  = 0,
        contexts    = [self moduleCurrentActiveContexts];

    for (var i = [contexts count] - 1; i >= 0; i--)
        grandTotal += [[_currentParent valueForKeyPath:[contexts[i] fetcherKeyPath]] currentTotalCount];

    [self setTotalNumberOfEntities:grandTotal];
}


#pragma mark -
#pragma mark  Module Titles

- (void)updateModuleTitle
{
}

- (void)updateModuleSubtitle
{
}


#pragma mark -
#pragma mark Permitted Actions

- (void)updatePermittedActions
{
    var allActions       = [_controlsForActionRegistry allKeys],
        permittedActions = [self _permittedActionsForSelectedObjects];

    for (var i = [allActions count] - 1; i >= 0; i--)
        [self setAction:allActions[i] permitted:NO];

    for (var i = [permittedActions count] - 1; i >= 0; i--)
        [self setAction:permittedActions[i] permitted:YES];

    [self _filterEnabledActions];
}

- (void)_filterEnabledActions
{
    var conditionEmptySelection  = [_currentSelectedObjects count] == 0,
        conditionSingleSelection = [_currentSelectedObjects count] == 1;

    if (!conditionSingleSelection)
    {
        [self setAction:NUModuleActionEdit permitted:NO];
        [self setAction:NUModuleActionInstantiate permitted:NO];
        [self setAction:NUModuleActionExport permitted:NO];
    }

    if (conditionEmptySelection)
    {
        [self setAction:NUModuleActionDelete permitted:NO];
        [self setAction:NUModuleActionInspect permitted:NO];
    }
}

- (CPArray)_permittedActionsForSelectedObjects
{
    var permittedActionsSet = [self permittedActionsForObject:nil];

    for (var i = [_currentSelectedObjects count] - 1; i >= 0; i--)
    {
        var selectedObject = _currentSelectedObjects[i],
            actionsSet     = [self permittedActionsForObject:selectedObject];

        [actionsSet addObject:NUModuleActionInspect];

        [permittedActionsSet unionSet:actionsSet];
    }

    return [permittedActionsSet allObjects];
}

- (CPSet)permittedActionsForObject:(id)anObject
{
    var conditionAdministrator  = _currentUserHasRoles([NURESTUserRoleCSPRoot, NURESTUserRoleOrgAdmin]),
        conditionParentIsOwned  = [_currentParent isOwnedByCurrentUser],
        conditionObjectIsOwned  = [anObject isOwnedByCurrentUser],
        conditionCanAdd         = conditionAdministrator || conditionParentIsOwned || conditionObjectIsOwned,
        conditionCanEdit        = anObject && conditionCanAdd,
        permittedActionsSet     = [CPSet new];

    if (conditionCanAdd)
        [permittedActionsSet addObject:NUModuleActionAdd];

    if (conditionCanEdit)
        [permittedActionsSet addObject:NUModuleActionEdit];

    if (conditionCanEdit)
        [permittedActionsSet addObject:NUModuleActionDelete];

    return permittedActionsSet;
}

- (void)setAction:(CPString)anAction permitted:(BOOL)isPermitted
{
    if (isPermitted && ![_currentPermittedActions containsObject:anAction])
        [_currentPermittedActions addObject:anAction];

    if (!isPermitted && [_currentPermittedActions containsObject:anAction])
        [_currentPermittedActions removeObject:anAction];

    [[self controlsForAction:anAction] makeObjectsPerformSelector:@selector(setHidden:) withObject:!isPermitted];
}

- (BOOL)isActionPermitted:(int)anAction
{
    return [_currentPermittedActions containsObject:anAction];
}

- (void)registerControl:(CPControl)aControl forAction:(CPString)anAction
{
    if (![_controlsForActionRegistry containsKey:anAction])
        [_controlsForActionRegistry setObject:[] forKey:anAction];

    [[_controlsForActionRegistry objectForKey:anAction] addObject:aControl];
}

- (CPArray)controlsForAction:(CPString)anAction
{
    return [_controlsForActionRegistry objectForKey:anAction];
}

- (id)actionForControl:(CPControl)aControl
{
    var keys = [_controlsForActionRegistry allKeys];

    for (var i = [keys count] - 1; i >= 0; i--)
    {
        var key = keys[i];

        if ([[_controlsForActionRegistry objectForKey:key] containsObject:aControl])
            return key;
    }

    return nil;
}

- (void)actionForSender:(id)aSender
{
    if ([aSender isKindOfClass:CPMenuItem])
        return [self actionForMenuItem:aSender];
    else
        return [self actionForControl:aSender];
}

#pragma mark Additional Action

- (void)configureAdditionalControls
{
}


#pragma mark -
#pragma mark CRUD Operations

- (@action)openNewObjectPopover:(id)aSender
{
    var action = [aSender isKindOfClass:CPMenuItem] ? [self actionForMenuItem:aSender] : [self actionForControl:aSender];

    if (![self isActionPermitted:action])
        return;

    [self setCurrentContext:[self defaultContextForAction:action]];

    var currentEditedObject = [self createObjectWithRESTName:[_currentContext identifier]];

    [self closeAllPopovers];

    // CuCapp
    var editionPopoverView = [[[_currentContext popover] contentViewController] view];
    _cucappID(editionPopoverView, @"popover_" + [currentEditedObject RESTName]);

    [_currentContext setEditedObject:currentEditedObject];

    if ([aSender isKindOfClass:CPMenuItem])
        aSender = [self controlsForAction:action][0];

    [_currentContext openPopoverForAction:action sender:aSender];
}

- (@action)openEditObjectPopover:(id)aSender
{
    if ([tableView numberOfSelectedRows] != 1)
        return;

    var clickPoint   = [[CPApp currentEvent] locationInWindow],
        selectedRow  = [tableView selectedRow],
        ignoreAction = aSender == tableView && !CGRectContainsPoint([tableView convertRectToBase:[tableView rectOfRow:selectedRow]], clickPoint);

    if (![self isActionPermitted:NUModuleActionEdit] || ignoreAction)
        return;

    var currentEditedObject = [tableView className] == @"CPTableView" ? [_dataSource objectAtIndex:selectedRow] : [tableView itemAtRow:selectedRow];

    [self closeAllPopovers];

    [self setCurrentContextWithIdentifier:[currentEditedObject RESTName]];
    [_currentContext setEditedObject:currentEditedObject];

    // CuCapp
    var editionPopoverView = [[[_currentContext popover] contentViewController] view];
    _cucappID(editionPopoverView, @"popover_" + [currentEditedObject RESTName]);

    if ([aSender isKindOfClass:CPMenuItem] || aSender == self)
        aSender = [self defaultPopoverTargetForMenuItem];

    [_currentContext openPopoverForAction:NUModuleActionEdit sender:aSender];
}

- (@action)openDeleteObjectPopover:(id)aSender
{
    if (![self isActionPermitted:NUModuleActionDelete])
        return;

    if (NUModuleAutoValidation || [[CPApp currentEvent] modifierFlags] & CPShiftKeyMask)
    {
        [self _performDeleteObjects:nil];
        return;
    }

    var popoverConfirmation = [[NUKit kit] registeredDataViewWithIdentifier:@"popoverConfirmation"],
        buttonConfirm = [[[popoverConfirmation contentViewController] view] subviewWithTag:@"confirm"],
        relativeRect;

    [buttonConfirm setTarget:self];
    [buttonConfirm setAction:@selector(_performDeleteObjects:)];
    _cucappID(buttonConfirm, @"button_popover_confirm_delete");

    if ([aSender isKindOfClass:CPMenuItem])
        aSender = [self defaultPopoverTargetForMenuItem];

    if ([aSender isKindOfClass:CPTableView])
    {
        relativeRect = computeRelativeRectOfSelectedRow(aSender);
        aSender = [aSender enclosingScrollView];
    }

    [popoverConfirmation showRelativeToRect:relativeRect ofView:aSender preferredEdge:CPMinYEdge];
    [popoverConfirmation setDefaultButton:buttonConfirm];
}

- (void)_performDeleteObjects:(id)aSender
{
    [[[NUKit kit] registeredDataViewWithIdentifier:@"popoverConfirmation"] close];

    var deleteRegistry = @{},
        cleanedObjects = [self modulePerformSelectionCleanupBeforeDeletion:[_currentSelectedObjects copy]];

    for (var i = [cleanedObjects count] - 1; i >= 0; i--)
    {
        var objectToDelete = cleanedObjects[i],
            contextIdentifier = [objectToDelete RESTName];

        if (![deleteRegistry containsKey:contextIdentifier])
            [deleteRegistry setObject:[] forKey:contextIdentifier];

        if ([[self permittedActionsForObject:objectToDelete] containsObject:NUModuleActionDelete])
            [[deleteRegistry objectForKey:contextIdentifier] addObject:objectToDelete];
    }

    var contexts = [_contextRegistry allValues];

    for (var i = [contexts count] - 1; i >= 0; i--)
    {
        var context = contexts[i];

        if ([deleteRegistry containsKey:[context identifier]])
        {
            [context setSelectedObjects:[deleteRegistry objectForKey:[context identifier]]];
            [context deleteSelectedObjects:aSender];
        }
    }
}


#pragma mark -
#pragma mark CRUD Operation Internal API

- (CPArray)modulePerformSelectionCleanupBeforeDeletion:(CPArray)someSelectedObjects
{
    return someSelectedObjects;
}


#pragma mark -
#pragma mark Import and Export

- (void)exportObject:(id)anObject usingAction:(id)anAction
{
    [[NURESTJobsController defaultController] postJob:[self moduleExportJobForAction:anAction]
                                         toEntity:anObject
                                  andCallSelector:@selector(_didExport:)
                                         ofObject:self];
}

- (@action)exportSelectedObjects:(id)aSender
{
    for (var i = [_currentSelectedObjects count] - 1; i >= 0; i--)
        [self exportObject:_currentSelectedObjects[i] usingAction:[self actionForSender:aSender]];
}

- (void)_didExport:(NUJobExport)aJob
{
    if ([aJob status] != NURESTJobStatusSUCCESS)
    {
        [NURESTError postRESTErrorWithName:@"Export Failed" description:[aJob result] connection:nil];
        return;
    }

    // try to find the name of the exported object
    var eventualObject,
        fileName = [aJob parentType];

    if ([_categories count])
    {
        for (var i = [_categories count] - 1; i >= 0; i--)
        {
            eventualObject = [[[_categories[i] children] filteredArrayUsingPredicate:[CPPredicate predicateWithFormat:@"ID == %@", [aJob parentID]]] firstObject];
            if (eventualObject)
                break;
        }
    }
    else
    {
        eventualObject = [[_dataSource filteredArrayUsingPredicate:[CPPredicate predicateWithFormat:@"ID == %@", [aJob parentID]]] firstObject];
    }

    if (eventualObject)
        fileName = [eventualObject name].replace(/ /g, "-");

    createDownload(JSON.stringify([aJob result]), fileName, "json");
}

- (void)importInObject:(id)anObject usingAction:(id)anAction
{
    _fileUpload                = document.createElement("input");
    _fileUpload.accept         = @"application/json";
    _fileUpload.type           = "file";
    _fileUpload.style.position = "absolute";
    _fileUpload.style.top      = "-100px";
    _fileUpload.style.left     = "-100px";
    _fileUpload.style.opacity  = "0";

    _fileUpload.addEventListener("change", function(evt)
    {
        var file     = evt.target.files.item(0),
            filename = file ? file.name : nil;

        if (!filename || [[filename pathExtension] lowercaseString] != "json")
            return;

        var reader = new FileReader();

        reader.addEventListener("load", function(evt)
        {
            var importJob = [self moduleImportJobForAction:anAction];

            try
            {
                JSON.parse(evt.target.result);
            }
            catch (e)
            {
                [NURESTError postRESTErrorWithName:@"Import Failed" description:@"The given file does not seems to be valid." connection:nil];
                return;
            }

            [importJob setParameters:evt.target.result];

            [[NURESTJobsController defaultController] postJob:importJob toEntity:anObject andCallSelector:@selector(_didImport:) ofObject:self];
        }, NO);

        reader.readAsText(file);
        _fileUpload.value = nil;

    }, NO);

    _fileUpload.click();
}

- (@action)import:(id)aSender
{
    [self importInObject:_currentParent usingAction:[self actionForSender:aSender]];
}

- (void)_didImport:(NUJobImport)aJob
{
    if ([aJob status] != NURESTJobStatusSUCCESS)
        [NURESTError postRESTErrorWithName:@"Import Failed" description:[aJob result] connection:nil];
}

#pragma mark Import and Export Internal API

- (NURESTJob)moduleImportJobForAction:(id)anAction
{
    return [NUJobImport new];
}

- (NURESTJob)moduleExportJobForAction:(id)anAction
{
    return [NUJobExport new];
}


#pragma mark -
#pragma mark Help Window

- (@action)openHelpWindow:(id)aSender
{
    window.open([[CPURL URLWithString:@"Resources/Help/" + [[self class] moduleIdentifier] + @".html"] absoluteString], "_new", "width=800,height=600");
}


#pragma mark -
#pragma mark Filtering

- (@action)clickSearchButton:(id)aSender
{
    if ([self enableAdvancedSearch])
    {
        var object = [self createObjectWithRESTName:[_currentContext identifier]];
        [[NUAdvancedFilteringViewController defaultController] openPopoverOnView:aSender forModule:self object:object predicateFormat:[filterField stringValue]];
    }
    else
        [self filterObjects:aSender];
}

- (@action)filterObjects:(id)aSender
{
    var filterString = [aSender stringValue];

    [self setFilter:[filterString length] ? filterString : nil];

    [self reload];
}

- (void)applyAdvancedFilters:(CPString)aString
{
    [filterField setStringValue:aString];
    [filterField _updateCancelButtonVisibility];
    [self filterObjects:filterField];
}


#pragma mark -
#pragma mark External Windows

- (@action)openModuleInExternalWindow:(id)aSender
{
    var bundle                 = [CPBundle bundleForClass:[self class]],
        externalizedModule     = [[[self class] alloc] initWithCibName:[self cibName] bundle:bundle],
        externalizedModuleView = [externalizedModule view],
        mask                   = CPTitledWindowMask | CPClosableWindowMask | CPMiniaturizableWindowMask | CPResizableWindowMask,
        externalWindow         = [[CPWindow alloc] initWithContentRect:[[self view] bounds] styleMask:mask],
        plaformWindow          = [[CPPlatformWindow alloc] initWithWindow:externalWindow];

    // size the module and put it as content view of the new window
    var contentView = [externalWindow contentView];
    [externalizedModuleView setFrameSize:[contentView frameSize]];
    [externalizedModuleView setFrameOrigin:CGPointMakeZero()];
    [externalizedModuleView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [externalizedModule setExternalWindow:externalWindow];
    [externalizedModule setShowsInExternalWindow:YES];
    [externalizedModule setModuleTitle:[self moduleTitle]];
    [externalizedModule setModuleSubtitle:[self moduleSubtitle]];

    [externalWindow setDelegate:externalizedModule];

    [contentView addSubview:externalizedModuleView];
    [contentView setBackgroundColor:NUSkinColorGreyLighter];

    // open the window and register it
    [externalWindow makeKeyAndOrderFront:nil];

    // add CSS and theme stuff
    [[NUKit kit] installStyleSheetOnDocument:plaformWindow._DOMWindow.document];

    // Initialize the module, set the current parent and tell it it'll be shown
    [externalizedModule setCurrentParent:_currentParent];
    [externalizedModule willShow];

    // Wait that the platform is well opened
    [[CPRunLoop mainRunLoop] performBlock:function()
    {
        // send the callback message both for the parent module and for the clone
        [externalizedModule didOpenAsCloneOfModule:self];
        [self didOpenCloneModule:externalizedModule];
    } argument:nil order:0 modes:[CPDefaultRunLoopMode]];
}

- (void)closeModuleExternalWindow
{
    if (!_showsInExternalWindow)
        return;

    [self willHide];
    [self setCurrentParent:nil];

    // close the window
    [_externalWindow orderOut:nil];
}

#pragma mark External Windows Internal API

- (void)didOpenCloneModule:(NUModule)aCloneModule
{
}

- (void)didOpenAsCloneOfModule:(NUModule)aParentModule
{
    [[[self view] window] setTitle:[self moduleTitle]];

    [buttonOpenInExternalWindow setHidden:YES];
}

- (void)didCloseFromExternalWindow
{
    [self willHide];
}


#pragma mark -
#pragma mark TabView Management

- (CPTabViewItem)tabViewItem
{
    if (!_tabViewItem)
    {
        _tabViewItem = [[CPTabViewItem alloc] initWithIdentifier:[[self class] moduleIdentifier]];
        [_tabViewItem setLabel:[[self class] moduleName]]
        [_tabViewItem setRepresentedObject:self];
        _tabViewItem._cucappID = [[self class] moduleIdentifier];

        var iconIdentifier = [[self class] moduleTabIconIdentifier];

        if (iconIdentifier)
        {
            _tabViewItem._icon            = CPImageInBundle("tabitem-icon-" + iconIdentifier + ".png", 16, 16, [CPBundle bundleForClass:[self class]]);
            _tabViewItem._iconHighlighted = CPImageInBundle("tabitem-icon-" + iconIdentifier + "-selected.png", 16, 16, [CPBundle bundleForClass:[self class]]);
            _tabViewItem._iconSelected    = CPImageInBundle("tabitem-icon-" + iconIdentifier + "-selected.png", 16, 16, [CPBundle bundleForClass:[self class]]);
            _tabViewItem._tooltip         = [[self class] moduleName];
        }
    }

    return _tabViewItem;
}


#pragma mark -
#pragma mark SubModules Management

- (void)_updateActiveSubModules
{
    _activeSubModules = [self currentActiveSubModules];

    if (![self _tabViewItemsNeedsUpdate])
        return;

    var currentTabItems = [tabViewContent tabViewItems];

    for (var i = 0, c = [currentTabItems count]; i < c; i++)
        [tabViewContent removeTabViewItem:currentTabItems[i]];

    for (var i = 0, c = [_activeSubModules count]; i < c; i++)
        [tabViewContent addTabViewItem:[_activeSubModules[i] tabViewItem]];

    [self _setCurrentParentForSubModules];
}

- (BOOL)_tabViewItemsNeedsUpdate
{
    var currentTabItems = [tabViewContent tabViewItems];

    if ([_activeSubModules count] != [currentTabItems count])
        return YES;

    for (var i = [currentTabItems count] - 1; i >= 0; i--)
        if ([currentTabItems[i] representedObject] != _activeSubModules[i])
            return YES;

    return NO;
}

- (void)setSubModules:(CPArray)someModules
{
    for (var i = [_subModules count] - 1; i >= 0; i--)
        [self removeSubModule:_subModules[i]];

    for (var i = 0, c = [someModules count]; i < c; i++)
        [self addSubModule:someModules[i]];

    [self moduleDidSetSubModules:someModules];
}

- (void)addSubModule:(NUModule)aSubModule
{
    if (!aSubModule)
        [CPException raise:CPInternalInconsistencyException reason:"Module " + self + " is trying a to register a null sub controller."];

    if ([_subModules containsObject:aSubModule])
        return;

    [_subModules addObject:aSubModule];
    [_activeSubModules addObject:aSubModule];

    [aSubModule setParentModule:self];

    [self moduleDidAddSubModule:aSubModule];
}

- (void)removeSubModule:(NUModule)aSubModule
{
    if (!aSubModule || ![_subModules containsObject:aSubModule])
        return;

    [self moduleWillRemoveSubModule:aSubModule];

    [_subModules removeObject:aSubModule];
    [_activeSubModules removeObject:aSubModule];

    [aSubModule setParentModule:nil];
    [aSubModule setCurrentParent:nil];
    [tabViewContent removeTabViewItem:[aSubModule tabViewItem]];
}

- (NUModule)visibleSubModule
{
    for (var i = [_activeSubModules count] - 1; i >= 0; i--)
    {
        var module = _activeSubModules[i];

        if ([module isVisible])
            return module;
    }

    return nil;
}

- (void)refreshActiveSubModules
{
    var previousSelectedIdentifier;

    if (tabViewContent)
        previousSelectedIdentifier = [[tabViewContent selectedTabViewItem] identifier];

    [self _updateActiveSubModules];

    if (tabViewContent)
    {
        var newIndex = [tabViewContent indexOfTabViewItemWithIdentifier:previousSelectedIdentifier];
        [tabViewContent selectTabViewItemAtIndex:(newIndex != CPNotFound) ? newIndex : 0];
        // not sure this is necessary selectTabViewItemAtIndex should call the delegate
        // [[self _subModuleWithIdentifier:[[tabViewContent selectedTabViewItem] identifier]] willShow];
    }
    else
    {
        [_activeSubModules makeObjectsPerformSelector:@selector(willShow)];
    }
}

- (void)hideAllSubModules
{
    for (var i = [_activeSubModules count] - 1; i >= 0; i--)
    {
        var controller = _activeSubModules[i];
        [controller willHide];
        [controller setCurrentParent:nil];
    }
}

- (NUModule)_subModuleWithIdentifier:(CPString)anIndentifier
{
    for (var i = [_subModules count] - 1; i >= 0; i--)
    {
        var controller = _subModules[i];

        if ([[controller class] moduleIdentifier] == anIndentifier)
            return controller;
    }

    return nil;
}

- (void)_setCurrentParentForSubModules
{
    var parentObject = [[self class] isTableBasedModule] ? [_currentSelectedObjects firstObject] : _currentParent;

    if (tabViewContent)
        [[self _subModuleWithIdentifier:[[tabViewContent selectedTabViewItem] identifier]] setCurrentParent:parentObject];
    else
        [_activeSubModules makeObjectsPerformSelector:@selector(setCurrentParent:) withObject:parentObject];
}


#pragma mark  Sub Modules Internal API

- (void)moduleDidSetSubModules:(CPArray)someModules
{
}

- (void)moduleDidAddSubModule:(NUModule)aSubModule
{
}

- (void)moduleWillRemoveSubModule:(NUModule)aSubModule
{
}

- (CPArray)currentActiveSubModules
{
    return _subModules;
}

- (void)moduleDidChangeVisibleSubmodule
{

}


#pragma mark -
#pragma mark  Push Management

- (void)registerForPushNotification
{
    if (![[self class] automaticContextManagement])
        return;

    if (_isListeningForPush)
        return;

    _isListeningForPush = YES;

    CPLog.debug("PUSH: Controller %@ is now registered for push", [self className]);
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didReceivePush:)
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

- (void)unregisterFromPushNotification
{
    if (![[self class] automaticContextManagement])
        return;

    if (!_isListeningForPush)
        return;

    _isListeningForPush = NO;

    CPLog.debug("PUSH: Controller %@ is now unregistered from push", [self className]);
    [[CPNotificationCenter defaultCenter] removeObserver:self
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

- (void)_didReceivePush:(CPNotification)aNotification
{
    // if the current parent is dirty, don't manage any push
    if ([_currentParent respondsToSelector:@selector(isDirty)] && [_currentParent isDirty])
        return NO;

    var JSONObject = [aNotification userInfo],
        events = JSONObject.events,
        pushManaged = NO,
        pushProcessed = NO,
        needsSorting = NO;

    if (events.length <= 0)
        return;

    _isProcessingPush = YES;

    // we save the current selection in case of modification
    // later on, if table needs to be reloded, we will restore the
    // selection using that save
    [self _saveCurrentSelection];

    for (var i = 0, c = events.length; i < c; i++)
    {
        var eventType       = events[i].type,
            entityType      = events[i].entityType,
            entityJSON      = events[i].entities[0],
            updateMechanism = events[i].updateMechanism;

        if (![self shouldManagePushOfType:eventType forEntityType:entityType])
            continue;

        if (!pushManaged)
        {
            pushManaged = YES;
            [self performPrePushOperation];

            if (_timerReloadLatestPage)
                [_timerReloadLatestPage invalidate];
        }

        switch (eventType)
        {
            case NUPushEventTypeGrant:
            case NUPushEventTypeCreate:
                if (![self shouldProcessJSONObject:entityJSON ofType:entityType eventType:eventType])
                    continue;
                pushProcessed = [self _processCreateEventWithJSONObject:entityJSON ofType:entityType updateMechanism:updateMechanism] || pushProcessed;
                needsSorting = YES;
                break;

            case NUPushEventTypeUpdate:
                if (![self shouldProcessJSONObject:entityJSON ofType:entityType eventType:eventType])
                    continue;
                pushProcessed = [self _processUpdateEventWithJSONObject:entityJSON ofType:entityType updateMechanism:updateMechanism] || pushProcessed;
                break;

            case NUPushEventTypeRevoke:
            case NUPushEventTypeDelete:
                if (![self shouldProcessJSONObject:entityJSON ofType:entityType eventType:eventType])
                    continue;
                pushProcessed = [self _processDeleteEventWithJSONObject:entityJSON ofType:entityType updateMechanism:updateMechanism] || pushProcessed;
                break;
        }
    }

    if (pushProcessed)
    {
        if (needsSorting)
            [self sortDataSourceContent];

        [self _reloadUIAfterPush];
        [self _restorePreviousSelection];
    }

    if (pushManaged)
        [self performPostPushOperation];

    _isProcessingPush = NO;
}

- (BOOL)_processCreateEventWithJSONObject:(id)aJSONObject ofType:(CPString)aType updateMechanism:(CPString)updateMechanism
{
    var obj = [self createObjectWithRESTName:aType];
    [obj objectFromJSON:aJSONObject];

    if (_masterFilter && ![_masterFilter evaluateWithObject:obj])
        return NO;

    [_currentParent addChild:obj];
    [self _insertCreatedObject:obj updateTotal:YES];

    if (updateMechanism == NUModuleUpdateMechanismRefetchHierachy)
        [self _refetchObject:obj hierarchy:YES];

    return YES;
}

- (BOOL)_processUpdateEventWithJSONObject:(id)aJSONObject ofType:(CPString)aType updateMechanism:(CPString)updateMechanism
{
    var obj = [_dataSource objectWithID:aJSONObject.ID];

    if (!obj)
        obj = [self createObjectWithRESTName:aType];

    [obj objectFromJSON:aJSONObject];

    if (_masterFilter && ![_masterFilter evaluateWithObject:obj])
        return NO;

    switch (updateMechanism)
    {
        case NUModuleUpdateMechanismRefetch:
            [self _refetchObject:obj hierarchy:NO];
            break;

        case NUModuleUpdateMechanismRefetchHierachy:
            [self _refetchObject:obj hierarchy:YES];
            break;

        default:
            var destination = [_categories count] > 0 ? [[self categoryForObject:obj] children] : _dataSource;

            // if it's an update of an object we don't have, simply add it.
            if (![destination containsObject:obj])
                [self _insertCreatedObject:obj updateTotal:NO];

            [self _updateCurrentEditedObjectWithObjectIfNeeded:obj];
            break;
    }

    return YES;
}

- (BOOL)_processDeleteEventWithJSONObject:(id)aJSONObject ofType:(CPString)aType updateMechanism:(CPString)updateMechanism
{
    var ID = aJSONObject.ID,
        obj = [_dataSource objectWithID:ID];

    if (_usesPagination)
        [_removedObjectsIDs addObject:ID];

    if (!obj)
    {
        obj = [self createObjectWithRESTName:aType];
        [obj objectFromJSON:aJSONObject];
    }

    if (_masterFilter && ![_masterFilter evaluateWithObject:obj])
        return NO;

    [_currentParent removeChild:obj];
    [self _removeDeletedObject:obj];

    return YES;
}

- (void)_reloadUIAfterPush
{
    if (![self isTableBasedModule])
        return;

    [self tableViewReloadData];

    if (_usesPagination)
    {
        [self _synchronizePagination];
        [self reloadLatestPage];
    }
}

- (void)_insertCreatedObject:(id)anObject updateTotal:(BOOL)shouldUpdateTotal
{
    if (_filter)
        return;

    [anObject setParentObject:_currentParent];

    var array = [_categories count] > 0 ? [[self categoryForObject:anObject] children] : _dataSource;

    if (![[array filteredArrayUsingPredicate:[CPPredicate predicateWithFormat:@"ID == %@", [anObject ID]]] count])
    {
        [array addObject:anObject];

        if (shouldUpdateTotal && !_usesPagination)
            [self setTotalNumberOfEntities:(_totalNumberOfEntities + 1)];
    }

    [self _manageGettingStartedVisibility];
}

- (void)_removeDeletedObject:(id)anObject
{
    if (!anObject)
    {
        CPLog.warn("NUMODULE: trying to _removeDeletedObject: on a null object")
        return;
    }

    if ([_categories count] > 0)
        [[[self categoryForObject:anObject] children] removeObject:anObject];
    else
        [_dataSource removeObject:anObject];

    if (!_usesPagination)
    {
        // @TODO: this is a really dirty fix that prevents
        // to have in some rare case a negative number of object.
        // we need to fix that correctly, but I have no clue why it's doing this
        if (_totalNumberOfEntities - 1 < 0)
            _totalNumberOfEntities = 1;

        [self setTotalNumberOfEntities:(_totalNumberOfEntities - 1)];
    }

    if ([[_currentContext editedObject] isEqual:anObject])
    {
        [_currentContext setEditedObject:nil];
        [[_currentContext popover] close];
    }

    [anObject discard];

    [self _manageGettingStartedVisibility];
}

- (void)_refetchObject:(id)anObject hierarchy:(BOOL)shouldRefreshHierarchy
{
    _reloadHierarchyAfterRefetch = shouldRefreshHierarchy;

    if (anObject)
        [anObject fetchAndCallSelector:@selector(_didRefetchObject:connection:) ofObject:self];
}

- (void)_didRefetchObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_reloadHierarchyAfterRefetch)
        [tableView deselectAll];

    switch ([aConnection responseCode])
    {
        case NURESTConnectionResponseCodeEmpty:
        case NURESTConnectionResponseCodeSuccess:
        case NURESTConnectionResponseCodeCreated:
            break;

        default:
            [_removedObjectsIDs addObject:[anObject ID]];
            [_currentParent removeChild:anObject];
            [self _removeDeletedObject:anObject]
            [self _reloadUIAfterPush];
            break;
    }

    [self performPostRefetchOperation];
}

- (void)_updateCurrentEditedObjectWithObjectIfNeeded:(id)anObject
{
    if (![[_currentContext editedObject] isEqual:anObject])
        return;

    [_currentContext updateEditedObjectWithNewVersion:anObject];
}

#pragma mark Push Management Internal API

- (void)performPrePushOperation
{
}

- (void)performPostPushOperation
{
    if ([tableView isKindOfClass:CPOutlineView])
        [tableView expandAll];
}

- (BOOL)shouldManagePushOfType:(CPString)aType forEntityType:(CPString)entityType
{
    var shouldForceManage = NO;

    // if we don't have a _parentModule, no one will ever update the value of _currentParent
    // so in that case we manage it
    if (!_parentModule && aType == NUPushEventTypeUpdate && entityType == [_currentParent RESTName])
        return YES;

    if (_showsInPopover || _showsInExternalWindow)
        shouldForceManage = [_currentParent genealogyContainsType:entityType];

    return shouldForceManage || [self containsContextWithIdentifier:entityType];
}

- (BOOL)shouldProcessJSONObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    // if we don't have a _parentModule, and the push is an update of the current parent, we update it
    // then we continue our normal life.
    if (!_parentModule && aType == NUPushEventTypeUpdate && aJSONObject.ID == [_currentParent ID])
        [_currentParent objectFromJSON:aJSONObject];

    if (anEventType == NUPushEventTypeDelete && (_showsInExternalWindow || _showsInPopover) && [_currentParent genealogyContainsID:aJSONObject.ID])
    {
        if (_showsInExternalWindow)
            [self closeModuleExternalWindow];
        else if (_showsInPopover)
            [self closeModulePopover];

        return NO;
    }

    return aJSONObject.parentID == [_currentParent ID];
}


#pragma mark -
#pragma mark Various Utilities

- (void)showLoading
{
    if (tableView)
        [[NUDataTransferController defaultDataTransferController] showFetchingViewOnView:tableView];
}

- (void)hideLoading
{
    if (tableView)
        [[NUDataTransferController defaultDataTransferController] hideFetchingViewFromView:tableView];
}

- (void)closeAllPopovers
{
    var contexts = [_contextRegistry allValues];

    for (var i = [contexts count] - 1; i >= 0; i--)
        [[contexts[i] popover] close];

    for (var i = [_subModules count] - 1; i >= 0; i--)
        [_subModules[i] closeAllPopovers];

    [[NUAdvancedFilteringViewController defaultController] closePopover];
}

- (void)_flushTableView
{
    if (![self isTableBasedModule])
        return;

    [self flushCategoriesContent];

    [_dataSource removeAllObjects];
    [self tableViewReloadData];
}

- (void)tableViewReloadData
{
    if (![self isTableBasedModule])
        return;

    _inhibitsSelectionUpdate = YES;

    [tableView reloadData];

    if ([_categories count] > 0)
        [tableView expandAll];

    _inhibitsSelectionUpdate = NO;
}

- (BOOL)isChildOfModuleWithClassName:(CPString)aName
{
    if ([_parentModuleHierarchyCache containsKey:aName])
        return [_parentModuleHierarchyCache objectForKey:aName];

    var currentModule = self;

    while (currentModule = [currentModule parentModule])
    {
        if ([currentModule className] == aName)
        {
            [_parentModuleHierarchyCache setObject:YES forKey:aName];
            return YES;
        }
    }

    [_parentModuleHierarchyCache setObject:NO forKey:aName];
    return NO;
}

- (void)flattenedDataSourceContent
{
    var ret = [];
    if ([_categories count])
        for (var i = [_categories count] - 1; i >= 0; i--)
            [ret addObjectsFromArray:[_categories[i] children]];
    else
        ret = [_dataSource content];

    return ret;
}

- (CPTabViewItem)_tabViewItemForProperty:(CPString)aPropertyName tabView:(CPTabView)aTabView
{
    var itemObjects = aTabView._itemObjects;

    for (var i = 0; i < [itemObjects count]; i++)
    {
        var tabViewPrototype    = itemObjects[i],
            tabViewItem         = [tabViewPrototype tabViewItem],
            control             = [[tabViewItem view] subviewWithTag:aPropertyName recursive:YES];

        if (control)
            return tabViewPrototype;
    }

    return nil;
}

- (void)showValidationErrors:(NUValidation)aValidation OnTabView:(CPTabView)aTabView
{
    var errors      = [[aValidation errors] allKeys],
        counter     = @{};

    for (var i = 0; i < [errors count] ; i++)
    {
        var propertyName    = errors[i],
            countValue      = 0,
            tabViewItem     = nil;

        if ([tabViewPropertiesCache containsKey:propertyName])
            tabViewItem = [tabViewPropertiesCache objectForKey:propertyName];
        else
        {
            tabViewItem = [self _tabViewItemForProperty:propertyName tabView:aTabView];
            if (!tabViewItem)
                return;

            [tabViewPropertiesCache setObject:tabViewItem forKey:propertyName];
        }

        if ([counter containsKey:tabViewItem])
            countValue = [counter objectForKey:tabViewItem];

        [counter setObject:countValue + 1 forKey:tabViewItem];
    }

    var tabItems = [counter allKeys];

    for (var i = 0; i < [tabItems count] ; i++)
    {
        var tabItem     = tabItems[i],
            countValue  = [counter objectForKey:tabItem];

        [tabItem setErrorColor:NUSkinColorRed];
        [tabItem setErrorsNumber:countValue];
    }
}

- (void)hideValidationErrorsForTabView:(CPTabView)aTabView
{
    var itemObjects = aTabView._itemObjects;

    for (var i = 0; i < [itemObjects count] ; i++)
        [itemObjects[i] setErrorsNumber:0];
}



#pragma mark -
#pragma mark Cucapp

- (void)configureCucappIDs
{
    [self setCuccapPrefix:@"add" forAction:NUModuleActionAdd];
    [self setCuccapPrefix:@"edit" forAction:NUModuleActionEdit];
    [self setCuccapPrefix:@"delete" forAction:NUModuleActionDelete];
    [self setCuccapPrefix:@"instantiate" forAction:NUModuleActionInstantiate];
    [self setCuccapPrefix:@"import" forAction:NUModuleActionImport];
    [self setCuccapPrefix:@"export" forAction:NUModuleActionExport];
}

- (void)setCuccapPrefix:(CPString)aPrefix forAction:(CPString)anAction
{
    [_cuccapPrefixesRegistry setObject:aPrefix forKey:anAction];
}

- (CPString)cuccapPrefixForAction:(CPString)anAction
{
    return [_cuccapPrefixesRegistry objectForKey:anAction];
}

- (void)updateCucappIDsAccordingToContext:(NUModuleContext)aContext
{
    if (filterField)
    {
        _cucappID(filterField, @"field_search_" + [aContext identifier]);
        _cucappID([filterField searchButton], @"button_search_" + [aContext identifier]);
    }

    if (_buttonFirstCreate)
        _cucappID(_buttonFirstCreate, @"button_" + [self cuccapPrefixForAction:NUModuleActionAdd] + @"_" + [aContext identifier]);

    if (_buttonFirstImport)
        _cucappID(_buttonFirstImport, @"button_" + [self cuccapPrefixForAction:NUModuleActionImport] + @"_" + [aContext identifier]);

    _cucappID(_buttonAddObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionAdd] + @"_" + [aContext identifier]);
    _cucappID(_buttonEditObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionEdit] + @"_" + [aContext identifier]);
    _cucappID(_buttonDeleteObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionDelete] + @"_" + [aContext identifier]);
    _cucappID(_buttonInstantiateObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionInstantiate] + @"_" + [aContext identifier]);
    _cucappID(_buttonImportObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionImport] + @"_" + [aContext identifier]);
    _cucappID(_buttonExportObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionExport] + @"_" + [aContext identifier]);
}


#pragma mark -
#pragma mark Masking Views

- (void)displayMaskingView
{
    if (!maskingView || [maskingView superview])
        return;

    [maskingView setFrameSize:[viewEditObject frameSize]];
    [viewEditObject addSubview:maskingView];

    [self didShowMaskingView];
}

- (void)hideMaskingView
{
    if (!maskingView || ![maskingView superview])
        return;

    [maskingView removeFromSuperview];
    [self didHideMaskingView];
}

- (void)displayMultipleSelectedObjectsMaskingView
{
    if (!multipleSelectedObjectsMaskingView || [multipleSelectedObjectsMaskingView superview])
        return;

    [multipleSelectedObjectsMaskingView setFrameSize:[viewEditObject frameSize]];
    [viewEditObject addSubview:multipleSelectedObjectsMaskingView];

    [self didShowMultipleSelectionMaskingView];
}

- (void)hideMultipleSelectedObjectsMaskingView
{
    if (!multipleSelectedObjectsMaskingView || ![multipleSelectedObjectsMaskingView superview])
        return;

    [multipleSelectedObjectsMaskingView removeFromSuperview];
    [self didHideMultipleSelectionMaskingView];
}

- (void)displayCurrentMaskingView
{
    if (!viewEditObject)
        return;

    if (multipleSelectedObjectsMaskingView && [tableView numberOfSelectedRows] >= _multipleSelectionMaskingViewTrigger)
    {
        if ([self shouldShowMultipleSelectionMaskingView])
        {
            [self displayMultipleSelectedObjectsMaskingView];
            return;
        }
    }

    if ([self shouldShowMaskingView])
        [self displayMaskingView]
}

- (void)hideCurrentMaskingView
{
    [self hideMultipleSelectedObjectsMaskingView];
    [self hideMaskingView];
}

#pragma mark Masking Views Internal API

- (BOOL)shouldShowMaskingView
{
    return YES;
}

- (void)didShowMaskingView
{
}

- (void)didHideMaskingView
{
}

- (BOOL)shouldShowMultipleSelectionMaskingView
{
    return YES;
}

- (void)didShowMultipleSelectionMaskingView
{
}

- (void)didHideMultipleSelectionMaskingView
{
}


#pragma mark -
#pragma mark Getting Started View

- (void)_manageGettingStartedVisibility
{
    // CS 04-09-2015 Added verification on active transactions:
    // When using multiple categories, _manageGettingStartedVisibility is called several times with
    // different responses which cause the CPSearchField to hide and show, and so to lost his focus.
    if (!viewGettingStarted || !tableView || _disableViewGettingStarted || [_activeTransactionsIDs count] > 0)
        return;

    var shouldShow = YES;
    if ([_dataSource isKindOfClass:NUOutlineViewDataSource])
    {
        for (var i = [_dataSource count] - 1; i >= 0; i--)
        {
            var object = [_dataSource objectAtIndex:i];

            if (![object isKindOfClass:NUCategory])
            {
                shouldShow = NO;
                break;
            }
            else if ([[object children] count])
            {
                shouldShow = NO;
                break;
            }
        }
    }
    else
    {
        if ([_dataSource count])
            shouldShow = NO;
    }

    if (shouldShow && ![[filterField stringValue] length] && !_paginationSynchronizing)
    {
        var scrollView = [tableView enclosingScrollView],
            frame = [scrollView frame];

        frame.size.height += 25;
        [viewGettingStarted setFrame:frame];
        [viewGettingStarted setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [[scrollView superview] addSubview:viewGettingStarted positioned:CPWindowAbove relativeTo:nil];
        [filterField setHidden:YES];
        [buttonBarMain setHidden:YES];
        [self didShowGettingStartedView:YES];
    }
    else
    {
        if ([viewGettingStarted superview])
            [viewGettingStarted removeFromSuperview];

        [filterField setHidden:NO];
        [buttonBarMain setHidden:NO];
        [self didShowGettingStartedView:NO];
    }
}

- (BOOL)isGettingViewStartedVisible
{
    return !![viewGettingStarted superview];
}

#pragma mark Getting Started View Internal API

- (void)didShowGettingStartedView:(BOOL)isVisible
{

}


#pragma mark -
#pragma mark Split View Management

- (void)adjustSplitViewSize
{
    if (splitViewMain && _autoResizeSplitViewSize)
    {
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
        [splitViewMain setPosition:_autoResizeSplitViewSize ofDividerAtIndex:0];
    }
}


#pragma mark -
#pragma mark Selection Management

- (void)setCurrentSelection:(CPArray)someObjects
{
    var indexSet = [[CPIndexSet alloc] init];

    switch ([tableView className])
    {
        case @"CPTableView":
            for (var i = [someObjects count] - 1; i >= 0; i--)
            {
                if ([someObjects[i] isDirty])
                    continue;

                var index = [_dataSource indexOfObject:someObjects[i]];

                if (index != CPNotFound)
                    [indexSet addIndex:index];
            }
            break;

        case @"CPOutlineView":
            for (var i = [someObjects count] - 1; i >= 0; i--)
            {
                if ([someObjects[i] isDirty])
                    continue;

                var index = [tableView rowForItem:someObjects[i]];

                if (index != CPNotFound)
                    [indexSet addIndex:index];
            }
            break;
    }

    if ([indexSet count] > 0)
    {
        [tableView selectRowIndexes:indexSet byExtendingSelection:NO];

        if (_scrollToSelectedRows)
            [tableView scrollRowToVisible:[indexSet firstIndex]];
    }
    else
        [tableView deselectAll];
}

- (BOOL)_standardShouldSelectRowIndexes:(CPIndexSet)someIndexes
{
    if (_overrideShouldHide)
    {
        _overrideShouldHide = NO;
        return YES;
    }

    var shouldSelect = YES;

    if (![self moduleShouldChangeSelection])
    {
        shouldSelect = NO;
    }
    else
    {
        for (var i = [_subModules count] - 1; i >= 0; i--)
        {
            if (![_subModules[i] shouldHide])
            {
                shouldSelect = NO;
                break;
            }
        }
    }

    if (!shouldSelect)
        [self _showPendingChangeWithDiscardSelector:@selector(_continueTableViewSelectionChange:) nextSelection:someIndexes];

    return shouldSelect;
}

- (void)_saveCurrentSelection
{
    if (![self isTableBasedModule])
        return;

    _previousSelectedObjects = [_currentSelectedObjects copy];
}

- (void)_restorePreviousSelection
{
    if (![self isTableBasedModule])
        return;

    [self setCurrentSelection:_previousSelectedObjects];
}

- (void)_updateCurrentSelection
{
    if (_inhibitsSelectionUpdate)
        return;

    var numberOfSelectedRows = [tableView numberOfSelectedRows],
        initialSet = [CPSet setWithArray:_currentSelectedObjects],
        previousSelection = [_currentSelectedObjects copy],
        finalSet;

    [_currentSelectedObjects removeAllObjects];

    if (numberOfSelectedRows != 0)
    {
        switch ([tableView className])
        {
            case @"CPTableView":
                _currentSelectedObjects = [_dataSource objectsAtIndexes:[tableView selectedRowIndexes]];
                break;

            case @"CPOutlineView":
                _currentSelectedObjects = [tableView itemsAtRows:[tableView selectedRowIndexes]];
                break;
        }
    }

    finalSet = [CPSet setWithArray:_currentSelectedObjects];

    // if sets are the identical we don't need to do anything
    if ([initialSet isEqualToSet:finalSet])
        return;

    _selectionDidChanged = NO; // reset
    CPLog.debug("SELECTION: %@: selected objects: %@", [self className], _currentSelectedObjects);

    var firstObject = [_currentSelectedObjects firstObject];

    [self hideAllSubModules];
    [_currentContext setSelectedObjects:_currentSelectedObjects];

    if ([self editorController])
        [self updateEditorControllerWithObjects:_currentSelectedObjects];

    // now if if we have one single selected object
    if ([_currentSelectedObjects count] == 1)
    {
        [self hideCurrentMaskingView];
        [self moduleDidSelectObjects:_currentSelectedObjects];
        [self refreshActiveSubModules];
        [self updateModuleSubtitle];
    }
    else
    {
        [self moduleDidSelectObjects:_currentSelectedObjects];
        [self displayCurrentMaskingView];
    }

    [self updatePermittedActions];

    [previousSelection makeObjectsPerformSelector:@selector(discardAllFetchers)];
}

- (void)archiveCurrentSelection
{
    if (![self isTableBasedModule] || ![[self class] automaticSelectionSaving] || !_currentParent || [_currentParent isDirty])
        return;

    [_selectionArchive setObject:[_currentSelectedObjects valueForKey:@"ID"] forKey:[_currentParent ID]];
}

- (void)restoreArchivedSelection
{
    if (![self isTableBasedModule] || ![[self class] automaticSelectionSaving] || !_currentParent || [_currentParent isDirty])
        return;

    var key = [_currentParent ID];

    if (![_selectionArchive containsKey:key])
        return;

    var IDs          = [_selectionArchive objectForKey:key],
        isTableView  = [tableView className] == @"CPTableView",
        dummyObjects = [];

    for (var i = [IDs count] - 1; i >= 0; i--)
    {
        // we create a dummy object for table view because it will be faster.
        // wiht outline view, it's not working because of the item cache.

        var dummyObject = isTableView ? [NUKitObject RESTObjectWithID:IDs[i]] : [_dataSource objectWithID:IDs[i]];
        [dummyObjects addObject:dummyObject];
    }

    _scrollToSelectedRows = YES;
    [self setCurrentSelection:dummyObjects];
    _scrollToSelectedRows = NO;

    [_selectionArchive removeObjectForKey:key];
}

- (void)cleanOutdatedArchivedSelection
{
    if (![self isTableBasedModule])
        return;

    if ([_selectionArchive count] <= NUModuleArchiveMaxSize)
        return;

    var count = 0,
        keys = [_selectionArchive allKeys],
        cleanedArchive = @{};

    for (var i = [keys count] - 1; i >= 0; i--)
    {
        var key = keys[i];

        [cleanedArchive setObject:[_selectionArchive objectForKey:key] forKey:key];

        if (++count > NUModuleArchiveMaxSize)
            break;
    }

    _selectionArchive = cleanedArchive;
}

#pragma mark Selection Management Internal API

- (void)moduleDidSelectObjects:(CPArray)someObjects
{
}

- (BOOL)moduleShouldChangeSelection
{
    if (editorController)
        return [editorController checkIfEditorAgreeToHide];

    return YES;
}


#pragma mark -
#pragma mark Category Management

- (NUCategory)categoryForObject:(id)anObject
{
}

- (void)setCategories:(CPArray)someCategories
{
    [self flushCategoriesContent];

    [self willChangeValueForKey:@"categories"];
    _categories = someCategories;
    [self didChangeValueForKey:@"categories"];

    _usesPagination = ![_categories count];
}

- (void)flushCategoriesContent
{
    for (var i = [_categories count] - 1; i >= 0; i--)
        [[_categories[i] children] removeAllObjects];
}


#pragma mark -
#pragma mark Content Management

- (void)_cleanChildren:(CPArray)someChildren ofObject:(id)anObject fetcher:(NURESTFetcher)aFetcher
{
    if (!someChildren)
        return nil;

    for (var i = [_removedObjectsIDs count] - 1; i >= 0; i--)
    {
        var ID = _removedObjectsIDs[i],
            index = [someChildren indexOfObjectPassingTest:function(obj, index){ return [obj ID] == ID; }];

        if (index == CPNotFound)
            continue;

        CPLog.info("We received an object from the server that has already been deleted. ID: " + ID);

        var obj = [someChildren objectAtIndex:index];
        [someChildren removeObject:obj];
        [aFetcher removeObject:obj];
    }

    return someChildren;
}

- (void)__fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didFetchContent:(CPArray)someContents
{
    var transactionID = [aFetcher transactionID];

    if (![_activeTransactionsIDs containsObject:transactionID])
        return;

    [_activeTransactionsIDs removeObject:transactionID];

    if (_usesPagination)
    {
        // We need to do this to ensure that we don't add any already deleted objects
        someContents = [self _cleanChildren:someContents ofObject:anObject fetcher:aFetcher];
    }

    [self fetcher:aFetcher ofObject:anObject didFetchContent:someContents];
}

- (void)fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didFetchContent:(CPArray)someContents
{
    if (!someContents)
    {
        [self errorWhileFetchingWithFetcher:aFetcher ofObject:anObject fetchContent:someContents];
        return;
    }

    [self performPreFetchOperation:someContents];
    [self _saveCurrentSelection];
    [self _updateGrandTotal];

    _latestSortDescriptors = [aFetcher currentSortDescriptors];
    _numberOfRemainingContextsToLoad--;

    if ([_categories count] > 0)
    {
        var categorizedContent = [_categories copy];

        for (var i = [someContents count] - 1; i >= 0; i--)
        {
            var object = someContents[i],
                currentCategory = [self categoryForObject:object];

            if (currentCategory && ![[currentCategory children] containsObject:object])
                [[currentCategory children] addObject:object];
        }

        [self setDataSourceContent:categorizedContent];
    }
    else
    {
        if (_usesPagination)
        {
            [someContents removeObjectsInArray:[_dataSource content]];
            var content = [someContents arrayByAddingObjectsFromArray:[_dataSource content]];

            [self setDataSourceContent:content];
        }
        else
            [self setDataSourceContent:someContents];
    }

    if (_usesPagination)
    {
        [self _synchronizePagination];
        [self _addScrollViewObservers];
        [self _restorePreviousSelection];
    }

    if ([self isTableBasedModule] && ![tableView numberOfSelectedRows] && !_numberOfRemainingContextsToLoad)
        [self restoreArchivedSelection];

    [self performPostFetchOperation];
}

- (void)sortDataSourceContent
{
    if (![self isTableBasedModule])
        return;

    switch ([tableView className])
    {
        case @"CPTableView":
            [_dataSource sortUsingDescriptors:_latestSortDescriptors];
            break;

        case @"CPOutlineView":
            if ([_categories count])
                [[_dataSource content] makeObjectsPerformSelector:@selector(sortUsingDescriptors:) withObject:_latestSortDescriptors];
            else
                [_dataSource sortUsingDescriptors:_latestSortDescriptors];
            break;
    }
}

- (void)setDataSourceContent:(CPArray)contents
{
    [self hideLoading];

    [_dataSource setContent:contents];
    [self sortDataSourceContent];
    [self tableViewReloadData];
    [self _manageGettingStartedVisibility];
}

- (id)createObjectWithRESTName:(CPString)anIdenfier
{
    var context = [self contextWithIdentifier:anIdenfier],
        keyPath = [context fetcherKeyPath],
        fetcher = [_currentParent valueForKeyPath:keyPath];

    if (!context)
        [CPException raise:CPInternalInconsistencyException reason:[self class] + ": Cannot find context with identifier " + anIdenfier];

    if (!fetcher)
        [CPException raise:CPInternalInconsistencyException reason:[self class] + ": Cannot find fetcher with keypath '" + keyPath + "' in current parent of type " + [_currentParent RESTName]];

    return [fetcher newManagedObject];
}

#pragma mark Contents Internal API

- (void)errorWhileFetchingWithFetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject fetchContent:(CPArray)someContents
{
    [NURESTConnection handleResponseForConnection:[aFetcher currentConnection] postErrorMessage:YES];
}

- (void)performPreFetchOperation:(CPArray)someContents
{

}

- (void)performPostFetchOperation
{

}

- (void)performPostRefetchOperation
{

}


#pragma mark -
#pragma mark Should Hide Management

- (void)_showPendingChangeWithDiscardSelector:(SEL)aSelector nextSelection:(id)aNextSelection
{
    var confirmAlert = [[TNAlert alloc] initWithMessage:@"Unsaved Changes"
                                            informative:@"You have some unsaved changes pending. Are you sure you want to continue?"
                                                 target:self
                                                actions:[["Cancel", @selector(_discardPendingChanges:)], ["Continue", aSelector]]];

    [confirmAlert setAlertStyle:CPWarningAlertStyle];
    [confirmAlert setUserInfo:aNextSelection];
    [confirmAlert runModal];

    [[confirmAlert._window contentView] setBackgroundColor:NUSkinColorWindowBody];
    confirmAlert._window._windowView._DOMElement.style.WebkitAnimationName = "scaleIn";
    confirmAlert._window._windowView._DOMElement.style.WebkitBackfaceVisibility = "hidden";
    confirmAlert._window._windowView._DOMElement.style.WebkitAnimationDuration = "0.1s";
    confirmAlert._window._windowView._DOMElement.style.WebkitAnimationFillMode = "forwards";

    confirmAlert._window._windowView._DOMElement.style.MozAnimationName = "scaleIn";
    confirmAlert._window._windowView._DOMElement.style.MozBackfaceVisibility = "hidden";
    confirmAlert._window._windowView._DOMElement.style.MozAnimationDuration = "0.1s";

    confirmAlert._window._windowView._DOMElement.style.animationName = "scaleIn";
    confirmAlert._window._windowView._DOMElement.style.backfaceVisibility = "hidden";
    confirmAlert._window._windowView._DOMElement.style.animationDuration = "0.1s";
    confirmAlert._window._windowView._DOMElement.style.animationFillMode = "forwards";

    confirmAlert._window._windowView._DOMElement.style.boxShadow = "0 0 20px " + [NUSkinColorGreyDark cssString];
    confirmAlert._window._windowView._DOMElement.style.MozBoxShadow = "0 0 20px " + [NUSkinColorGreyDark cssString];
    confirmAlert._window._windowView._DOMElement.style.WebkitBoxShadow = "0 0 20px" + [NUSkinColorGreyDark cssString];

    [confirmAlert._window._windowView setBorderRadius:3];
    [confirmAlert._window._windowView setBorderColor:NUSkinColorGreyDark];
}

- (void)_discardPendingChanges:(id)someUserInfo
{
    // pass
}

- (void)_continueTableViewSelectionChange:(CPIndexSet)selectionIndexes
{
    _overrideShouldHide = YES;

    if (!selectionIndexes || ![selectionIndexes count])
    {
        [tableView deselectAll];
        return;
    }

    [tableView selectRowIndexes:selectionIndexes byExtendingSelection:NO];

    if ([self editorController])
        [self updateEditorControllerWithObjects:_currentSelectedObjects];
}

- (void)_continueTabChange:(CPTabViewItem)aTabViewItem
{
    _overrideShouldHide = YES;
    [tabViewContent selectTabViewItem:aTabViewItem];
}


#pragma mark -
#pragma mark Data View Management

- (void)registerDataViewWithName:(CPString)aName forClass:(Class)aClass
{
    var dataView = [[[NUKit kit] registeredDataViewWithIdentifier:aName] duplicate];
    [_dataViews setObject:dataView forKey:aClass.name];
}

- (CPView)registeredDataViewForClass:(Class)aClass
{
    return [_dataViews objectForKey:aClass.name]
}

- (CPView)_dataViewForObject:(id)anObject
{
    return [self registeredDataViewForClass:[anObject class]];
}

- (void)setDataViewForObject:(id)anObject highlighted:(BOOL)shouldHighlight
{
    switch ([tableView className])
    {
        case @"CPTableView":
            var index = [_dataSource indexOfObject:anObject];
            break;

        case @"CPOutlineView":
            var index = [tableView rowForItem:anObject];
            break;
    }

    if (index == CPNotFound)
        return;

    var dataView = [tableView viewAtColumn:0 row:index makeIfNecessary:NO];
    [dataView setHighlighted:shouldHighlight];
}

#pragma mark Data View Internal API

- (void)willDisplayDataView:(CPView)aView
{
}


#pragma mark -
#pragma mark Responder Chain Management

- (CPResponder)initialFirstResponder
{
    var module = [self visibleSubModule];

    if (module)
        return [module initialFirstResponder];

    return tableView || tabViewContent;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}


#pragma mark -
#pragma mark Inspector Management

- (@action)openInspector:(id)aSender
{
    [[NUKit kit] openInspectorForSelectedObject];
}


#pragma mark -
#pragma mark Editor Management

- (void)showModuleEditor:(BOOL)shouldShow
{
    if (!editorController || !viewEditorContainer)
        return;

    if (shouldShow && [self moduleEditorShouldShow])
    {
        var frame = [[self view] bounds];
        frame.size.width -= [viewEditorContainer frameSize].width;

        [splitViewMain setFrame:frame];
        [viewEditorContainer setHidden:NO];
        [self moduleEditorDidShow];
    }
    else
    {
        [splitViewMain setFrame:[[self view] bounds]];
        [self moduleEditorWillHide];
        [viewEditorContainer setHidden:YES];
        [editorController setCurrentParent:nil];
    }

    [self adjustSplitViewSize];
    [[self visibleSubModule] adjustSplitViewSize];
}

- (void)updateEditorControllerWithObjects:(CPArray)someObjects
{
    var singleSelection         = [someObjects count] == 1,
        multipleSelection       = [someObjects count] > 1,
        firstObject             = singleSelection ? [someObjects firstObject] : nil,
        editorTitleKeyPath      = singleSelection ? [self moduleEditorTitleKeyPathForObject:firstObject] : @"",
        editorTitleTransformer  = [self moduleEditorTitleTransformer],
        editorImage             = singleSelection ? [self moduleEditorImageTitleForObject:firstObject] : nil;

    [editorController setCurrentParent:firstObject];
    [editorController setTitleFromKeyPath:editorTitleKeyPath ofObject:firstObject transformer:editorTitleTransformer];
    [editorController setImage:editorImage];

    [editorController showMultipleSelectionView:multipleSelection];

    [self showModuleEditor:_stickyEditor || singleSelection || multipleSelection];
}

- (@action)tableViewDidClick:(id)aSender
{
    if (!_selectionDidChanged && [self editorController] && [[self editorController] currentParent] != [_currentSelectedObjects firstObject] && [self _standardShouldSelectRowIndexes:[tableView selectedRowIndexes]])
        [self updateEditorControllerWithObjects:_currentSelectedObjects];
}


#pragma mark Editor Management Internal API

- (BOOL)moduleEditorShouldShow
{
    return YES;
}

- (void)moduleEditorDidShow
{
}

- (void)moduleEditorWillHide
{
}

- (id)moduleEditorTitleTransformer
{
    return nil;
}

- (CPString)moduleEditorTitleKeyPathForObject:(id)anObject
{
    return @"name"
}

- (CPImage)moduleEditorImageTitleForObject:(id)anObject
{
    return [anObject icon];
}

- (void)interpretKeyEvents:(CPArray)someEvents
{
    var event    = [someEvents firstObject],
        modifier = [event modifierFlags] & CPControlKeyMask;

    if (modifier && [event charactersIgnoringModifiers] == 'f')
    {
        [[[self view] window] makeFirstResponder:filterField];
    }
    else if (modifier && [event charactersIgnoringModifiers] == 'n')
    {
        [self openNewObjectPopover:[_buttonAddObject isHidden] ? _buttonFirstCreate : _buttonAddObject];
    }
    else if ([event keyCode] == CPReturnKeyCode)
    {
        [self openEditObjectPopover:self];
    }
}

- (void)keyDown:(CPEvent)anEvent
{
    [self interpretKeyEvents:[anEvent]];
}


#pragma mark -
#pragma mark KVO Observers

- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(id)aContext
{
    if (_latestPageLoaded >= _maxPossiblePage)
        return;

    var scrollPosition = CGRectGetMaxY([object bounds]);

    if (scrollPosition + NUModuleRESTPageLoadingTrigger >= [tableView frame].size.height)
    {
        CPLog.debug("PAGINATION: Reached trigger for scroll view. Loading next page.");

        // close any deletion in process if we are loading something to avoid incoherency
        [[[NUKit kit] registeredDataViewWithIdentifier:@"popoverConfirmation"] close];

        // do not observe bounds change until we receive the next page
        [self _removeScrollViewObservers];

        [self loadNextPage];
    }
}


#pragma mark -
#pragma mark Outline View Delegates

- (void)outlineViewSelectionDidChange:(CPNotification)aNotification
{
    _selectionDidChanged = YES;
    [[CPRunLoop mainRunLoop] performBlock:function()
    {
        [self _updateCurrentSelection];
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    } argument:nil order:0 modes:[CPDefaultRunLoopMode]];
}

- (int)outlineView:(CPOutlineView)anOutlineView heightOfRowByItem:(id)anItem
{
    var dataView = [self _dataViewForObject:anItem];

    if ([dataView respondsToSelector:@selector(computedHeightForObjectValue:)])
        return [dataView computedHeightForObjectValue:anItem];
    else
        return [dataView frameSize].height;
}

- (CPView)outlineView:(CPOutlineView)anOutlineView viewForTableColumn:(CPTableColumn)aColumn item:(id)anItem
{
    var dataView = [self _dataViewForObject:anItem],
        key = _dataViewIdentifierPrefix + @"_" + ([anItem isKindOfClass:NUKitObject] ? [anItem RESTName] : [anItem UID]),
        view = [anOutlineView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        view = [dataView duplicate];
        [view setIdentifier:key];
    }

    return view;
}

- (CPIndexSet)outlineView:(CPOutlineView)anOutlineView selectionIndexesForProposedSelection:(CPIndexSet)proposedIndexes
{
    var indexesToRemove = [CPIndexSet new],
        currentIndex = [proposedIndexes firstIndex],
        didRemoveIndexes = NO;

    while (currentIndex != CPNotFound)
    {
        if ([[tableView itemAtRow:currentIndex] isKindOfClass:NUCategory])
        {
            [indexesToRemove addIndex:currentIndex];
            didRemoveIndexes = YES;
        }

        currentIndex = [proposedIndexes indexGreaterThanIndex:currentIndex];
    }

    [proposedIndexes removeIndexes:indexesToRemove];

    // oh yeah!
    // note: this is to actually keep the selection as it is if user clicks on a category
    // but if it's a key up/down, we don't want to keep that selection
    if ([[CPApp currentEvent] clickCount] > 0 && ![proposedIndexes count] && didRemoveIndexes)
        return [tableView selectedRowIndexes];

    currentIndex = [proposedIndexes firstIndex];

    if (![self _standardShouldSelectRowIndexes:proposedIndexes])
        return [tableView selectedRowIndexes];

    return proposedIndexes;
}

- (void)outlineView:(CPOutlineView)anOutlineView willDisplayView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn item:(id)anItem
{
    [self willDisplayDataView:aView];
}

- (void)outlineView:(CPOutlineView)anOutlineView willRemoveView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn item:(id)anItem
{
    if ([aView respondsToSelector:@selector(setObjectValue:)])
        [aView setObjectValue:nil];
}

- (BOOL)outlineView:(CPOutlineView)anOutlineView shouldCollapseItem:(id)anItem
{
    return NO;
}

- (BOOL)outlineView:(CPOutlineView)anOutlineView shouldSelectItem:(id)anItem
{
    return ![anItem isKindOfClass:NUCategory];
}

- (void)outlineViewDeleteKeyPressed:(CPTableView)aTableView
{
    if ([_currentSelectedObjects count] && ([self isActionPermitted:NUModuleActionDelete]))
        [self openDeleteObjectPopover:aTableView];
}

- (CPMenu)outlineView:(CPOutlineView)anOutlineView menuForTableColumn:(CPTableColumn)aColumn item:(is)anItem
{
    return [self _currentContextualMenu];
}


#pragma mark -
#pragma mark Table View Delegates

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    _selectionDidChanged = YES;
    [[CPRunLoop mainRunLoop] performBlock:function(){
        [self _updateCurrentSelection];
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    } argument:nil order:0 modes:[CPDefaultRunLoopMode]];
}

- (int)tableView:(CPTableView)aTableView heightOfRow:(int)aRow
{
    var dataView = [self _dataViewForObject:[_dataSource objectAtIndex:aRow]];

    if ([dataView respondsToSelector:@selector(computedHeightForObjectValue:)])
        return [dataView computedHeightForObjectValue:[_dataSource objectAtIndex:aRow]];
    else
        return [dataView frameSize].height;
}

- (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    var item = [_dataSource objectAtIndex:aRow],
        key  = _dataViewIdentifierPrefix + @"_" + ([item isKindOfClass:NUKitObject] ? [item RESTName] : [item UID]),
        view = [aTableView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        view = [[self _dataViewForObject:item] duplicate];
        [view setIdentifier:key];
    }

    return view;
}

- (CPIndexSet)tableView:(CPTableView)aTableView selectionIndexesForProposedSelection:(CPIndexSet)proposedIndexes
{
    return [self _standardShouldSelectRowIndexes:proposedIndexes] ? proposedIndexes : [tableView selectedRowIndexes];
}

- (void)tableView:(CPTableView)aTableView willDisplayView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    [self willDisplayDataView:aView];
}

- (void)tableView:(CPTableView)aTableView willRemoveView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    if ([aView respondsToSelector:@selector(setObjectValue:)])
        [aView setObjectValue:nil];
}

- (void)tableViewDeleteKeyPressed:(CPTableView)aTableView
{
    if ([_currentSelectedObjects count] && ([self isActionPermitted:NUModuleActionDelete]))
        [self openDeleteObjectPopover:aTableView];
}

- (CPMenu)tableView:(CPTableView)aTableView menuForTableColumn:(CPTableColumn)aColumn row:(CPInteger)aRow
{
    return [self _currentContextualMenu];
}


#pragma mark -
#pragma mark TabView Delegates

- (BOOL)tabView:(TNTabView)aTabView shouldSelectTabViewItem:(CPTabViewItem)anItem
{
    if (_overrideShouldHide)
    {
        _overrideShouldHide = NO;
        return YES;
    }

    var controller = [self _subModuleWithIdentifier:[[aTabView selectedTabViewItem] identifier]];

    if (controller && [controller isVisible] && ![controller shouldHide])
    {
        var pendingController = [self _subModuleWithIdentifier:[anItem identifier]];
        [self _showPendingChangeWithDiscardSelector:@selector(_continueTabChange:) nextSelection:[pendingController tabViewItem]];
        return NO;
    }

    return YES;
}

- (void)tabView:(TNTabView)aTabView willSelectTabViewItem:(CPTabViewItem)anItem
{
    var previousModule = [self _subModuleWithIdentifier:[[aTabView selectedTabViewItem] identifier]];
    [previousModule willHide];
    [previousModule setCurrentParent:nil];

    var nextModule = [self _subModuleWithIdentifier:[anItem identifier]];
    if (![anItem view])
        [anItem setView:[nextModule view]];
}

- (void)tabView:(TNTabView)aTabView didSelectTabViewItem:(CPTabViewItem)anItem
{
    [self _setCurrentParentForSubModules];

    var module = [self _subModuleWithIdentifier:[anItem identifier]];

    [module willShow];
    [tabViewContent setNextKeyView:[module initialFirstResponder]];

    [self moduleDidChangeVisibleSubmodule];
}


#pragma mark -
#pragma mark SplitView Delegates

- (float)splitView:(CPSplitView)aSplitView constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)subviewIndex
{
    if (splitViewEditor && aSplitView == splitViewEditor)
        return [aSplitView frameSize].width - NUModuleSplitViewEditorMinSize;

    if (_splitViewMaxX)
        return _splitViewMaxX;

    if (_autoResizeSplitViewSize === nil)
        return proposedMax;

    if (proposedMax >= 500)
        return 500;

    return (_autoResizeSplitViewSize === 0) ? 0 : proposedMax;
}

- (float)splitView:(CPSplitView)aSplitView constrainMinCoordinate:(float)proposedMax ofSubviewAt:(int)subviewIndex
{
    if (splitViewEditor && aSplitView == splitViewEditor)
        return [aSplitView frameSize].width - NUModuleSplitViewEditorMaxSize;

    if (_splitViewMinX)
        return _splitViewMinX;

    if (_autoResizeSplitViewSize === nil)
        return proposedMax;

    if (_autoResizeSplitViewSize === 0)
        return 0;

    return (proposedMax <= _autoResizeSplitViewSize) ? _autoResizeSplitViewSize : proposedMax;
}

- (void)splitView:(CPSplitView)aSplitView resizeSubviewsWithOldSize:(CGSize)oldSize
{
    [aSplitView adjustSubviews];

    if (aSplitView != splitViewMain)
        return;

    [aSplitView setPosition:[[[aSplitView subviews] firstObject] frameSize].width ofDividerAtIndex:0];
}


#pragma mark -
#pragma mark Popover Delegate

- (void)popoverDidClose:(CPPopover)aPopover
{
    if (aPopover != _modulePopover)
        return;

    [self willHide];
}

- (void)popoverWillShow:(CPPopover)aPopover
{
    if (aPopover != _modulePopover)
        return;

    [self willShow];
    [_modulePopover setContentSize:_modulePopoverBaseSize];
    [[self visibleSubModule] willShow];
}


#pragma mark -
#pragma mark CPWindow Delegate

- (void)windowWillClose:(CPWindow)aWindow
{
    if (aWindow !== [self externalWindow])
        return;

    [self didCloseFromExternalWindow];
}

#pragma mark -
#pragma mark Editor Management Internal API

- (void)configureEditor:(NUEditorsViewController)anEditorController
{
}

@end
