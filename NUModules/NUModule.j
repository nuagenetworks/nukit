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
@import <Bambou/Bambou.j>
@import <TNKit/TNTableViewDataSource.j>
@import <TNKit/TNTabView.j>

@import "NUAdvancedFilteringViewController.j"
@import "NUCategory.j"
@import "NUDataTransferController.j"
@import "NUEditorsViewController.j"
@import "NUExpandableSearchField.j"
@import "NUJobExport.j"
@import "NUJobImport.j"
@import "NUModuleContext.j"
@import "NUOutlineViewDataSource.j"
@import "NUSkin.j"
@import "NUTabViewItemPrototype.j"
@import "NUTotalNumberValueTransformer.j"

@class NUKit

@global CPApp
@global NUKitUserLoggedOutNotification
@global NUPermissionLevelRoot
@global NUPermissionLevelAdmin
@global _CPWindowDidChangeFirstResponderNotification

var NUModuleRESTPageLoadingTrigger     = 500,
    NUModuleArchiveMaxSize             = 100,
    NUModuleSplitViewEditorMaxSize     = 300,
    NUModuleSplitViewEditorMinSize     = 100;

NUModuleRESTPageSize                   = 50;

NUModuleAutoValidation                 = NO;
NUModuleUpdateMechanismRefetch         = @"REFETCH";
NUModuleUpdateMechanismRefetchHierachy = @"REFETCH_HIERARCHY";


NUModuleActionAdd                      = 1;
NUModuleActionDelete                   = 2;
NUModuleActionEdit                     = 3;
NUModuleActionExport                   = 4;
NUModuleActionImport                   = 5;
NUModuleActionInstantiate              = 6;
NUModuleActionInspect                  = 7;

NUModuleTabViewModeText                = 1;
NUModuleTabViewModeIcon                = 2;


/*! NUModule is the basic class that is used to show and manipulate ReSTObjects
*/
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
    CPNumber                        _currentPaginatedCategoryIndex          @accessors(property=currentPaginatedCategoryIndex)
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

/*! Returns the state of the auto confirmation global configuration
*/
+ (BOOL)autoConfirm
{
    return NUModuleAutoValidation;
}

/*! Sets the state of the global auto confirmation. When this is set,
    no user input validation will be required for actions like delete.
*/
+ (void)setAutoConfirm:(BOOL)isEnabled
{
    NUModuleAutoValidation = isEnabled;
}

/*! Overrides this method to make the module table less.
    A table less module will skip the loading of entities, and will
    directly set the submodule's currentParent to be its own
    currentParent.
*/
+ (BOOL)isTableBasedModule
{
    return YES;
}

/*! Override this method to provide a human readable name.
    This will be used in multiple places, like for instance
    as the label of an itemized module, or the title the CPTabViewItem
    that will contain the module's view.
*/
+ (CPString)moduleName
{
    return [self className];
}

/*! Returns the module tab view mode
    It can be on the following:

    - NUModuleTabViewModeText: the tab view will use the text from + (CPString)moduleName
    - NUModuleTabViewModeIcon: the tab view will use the icon defined in + (CPImage)moduleIcon
*/
+ (BOOL)moduleTabViewMode
{
    return NUModuleTabViewModeText;
}

/*! Overrides this set a unique identifier for the module tab.
*/
+ (CPString)moduleTabIconIdentifier
{
    return nil;
}

/*! Override this to provide a custom icon that will be used in the
    module's CPTabViewItem.
*/
+ (CPImage)moduleIcon
{
    return nil;
}

/*! Module unique identifier. You should not need to touch this.
*/
+ (CPString)moduleIdentifier
{
    return @"net.nuagenetworks.vsd." + [[self className] lowercaseString];
}

/*! Overrides this and return NO to disable to automatic context management.
    Automatic context management allows the NUModule to automatically switch
    the current NUModuleContext to be used according to the currentParent RESTName.
    In most of the cases, you don't need to change this.
*/
+ (BOOL)automaticContextManagement
{
    return YES;
}

/*! Overrides this and return NO to disable the auto matic selection saving.
    When a module is hidden, it will remember the last selected item.
*/
+ (BOOL)automaticSelectionSaving
{
    return YES;
}

/*! Overrides this and return NO to disable the auto memory management.
    You should not have to use this unless you are using very specific pattern that needs the
    parent's object fetcher to not be cleared when the module is hidden.
    If you disable this, you are responsible to discarding the children when needed. If you forget to
    do so, you'll encounter big memory leaks.
*/
+ (BOOL)automaticChildrenListsDiscard
{
    return YES;
}

/*! Overrides this and return NO to disable the automatic commit in fetchers.
    When a NUModule fetches the list of currentParent's children, this list will be automatically
    added as the content of the fetcher. If you disable this, the fetched children will be only cached in
    the NUModule DataSource.
*/
+ (BOOL)commitFetchedObjects
{
    return YES;
}


#pragma mark -
#pragma mark Initialization

/*! Called when the view is loaded from a xib.
    Override this to add additional initialization.
    DO NOT FORGET to call [super viewDidLoad].
*/
- (void)viewDidLoad
{
    [[self view] setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"main-view-background"]];

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
    _currentPaginatedCategoryIndex                      = -1;
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
        [tableView setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"tableview-view-background"]]; // white
        [tableView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleRegular];

        if ([[tableView tableColumns] count])
            [[[tableView tableColumns] firstObject] setMaxWidth:1000000];

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
        [maskingView setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"masking-view-background"]];

    if (multipleSelectedObjectsMaskingView)
        [multipleSelectedObjectsMaskingView setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"masking-view-background"]];

    if (viewTitleContainer)
        [viewTitleContainer setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"title-container-view-background"]];

    if (viewSubtitleContainer)
        [viewSubtitleContainer setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"subtitle-container-view-background"]];

    if (splitViewMain)
    {
        [splitViewMain setButtonBar:buttonBarMain forDividerAtIndex:0];
        [splitViewMain setDelegate:self];
    }

    if (fieldTotalEntities)
    {
        var opts = @{CPValueTransformerNameBindingOption: NUTotalNumberValueTransformerName};
        [fieldTotalEntities bind:CPValueBinding toObject:self withKeyPath:"formatedTotalNumberOfEntities" options:opts];
        [fieldTotalEntities setTextColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"total-entities-field-foreground"]];

        [[fieldTotalEntities superview] setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"total-entities-field-background"]];

        _cucappID(fieldTotalEntities, @"field_total_" + [self className]);
    }

    if (fieldModuleTitle)
    {
        [self setModuleTitle:[fieldModuleTitle stringValue]];
        [fieldModuleTitle setTextColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"title-field-foreground"]];
        [fieldModuleTitle bind:CPValueBinding toObject:self withKeyPath:@"moduleTitle" options:nil];
    }

    if (fieldModuleSubtitle)
    {
        [self setModuleSubtitle:[fieldModuleSubtitle stringValue]];
        [fieldModuleSubtitle setTextColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"subtitle-field-foreground"]];
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
        [fieldModuleTitle setTextColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"moddule-popover-title-field-foreground"]];
        [viewPopoverModuleTitleContainer setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"module-popover-title-view-background"]];
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
            [editorController setDelegate:self];
            [viewEditorContainer setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"editor-container-view-background"]];

            if (splitViewEditor)
                [splitViewEditor setDelegate:self];

            if (viewEditorContainer)
                viewEditorContainer._DOMElement.style.boxShadow = "0 0 10px " + [[[[NUKit kit] moduleColorConfiguration] objectForKey:@"editor-container-shadow-color"] cssString];
        }
    }

    [self displayCurrentMaskingView];

    [self configureAdditionalControls];
    [self configureCucappIDs];
    [self configureContexts];

    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_userLoggedOut:) name:NUKitUserLoggedOutNotification object:nil];
}

/*! Mirror of the class method + (BOOL)isTableBasedModule. never override this.
*/
- (BOOL)isTableBasedModule
{
    return [[self class] isTableBasedModule];
}


#pragma mark -
#pragma mark Notification Handlers

/*! @ignore
*/
- (void)_userLoggedOut:(CPNotification)aNotification
{
    [self closeAllPopovers];

    if (_modulePopover)
        [_modulePopover close];

    _selectionArchive = @{};
    _previousSelectedObjects = [];
    [self moduleLoggingOut];
}

/*! Internal API you can override.
    This message will be sent when the user is logging out of the application
*/
- (void)moduleLoggingOut
{

}


#pragma mark -
#pragma mark Context Management

/*! Register a NUModuleContext responsible for managing the given model class.
*/
- (void)registerContext:(NUModuleContext)aContext forClass:(Class)aClass
{
    [aContext setManagedObjectClass:aClass];
    [aContext setDelegate:self];

    [_contextRegistry setObject:aContext forKey:[aClass RESTName]];

    [self setCurrentContext:aContext];
}

/*! Checks if the module contains a NUModuleContext for the given identifier.
*/
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

/*! Returns the registered NUModuleContext for the given identifier.
*/
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

/*! Returns the registered NUModuleContext for the given identifier.
*/
- (NUModuleContext)_contextForCategory:(NUCategory)aCategory
{
    return [self contextWithIdentifier:[aCategory contextIdentifier]];
}

/*! Sets the current active module context.
*/
- (void)setCurrentContext:(NUModuleContext)aContext
{
    if (aContext == _currentContext)
        return;

    _currentContext = aContext;
    [_currentContext setParentObject:_currentParent];
    [_currentContext setSelectedObjects:_currentSelectedObjects];

    [self updateCucappIDsAccordingToContext:aContext];
}

/*! Sets the current active module context using its identifier.
    The given context must be already registered.
*/
- (void)setCurrentContextWithIdentifier:(CPString)anIdentifier
{
    if ([_currentContext identifier] == anIdentifier)
        return;

    [self setCurrentContext:[self contextWithIdentifier:anIdentifier]];
}
/*! @ignore
*/
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

/*! Context initialization. If your NUModule subclass needs to manage some objects,
    You MUST override this method and register the context inside.
*/
- (void)configureContexts
{
}

/*! Returns a the context to use for a particular NUModuleAction
*/
- (NUModuleContext)defaultContextForAction:(id)anAction
{
    return _currentContext;
}

/*! Returns an array of current active contexts
*/
- (CPArray)moduleCurrentActiveContexts
{
    return _currentContext ? [_currentContext]: [];
}


#pragma mark -
#pragma mark Module Popover Embededed Management

/*! Defines if the module must be shown in a Popover instead of in a classic view.
    You should not need to set this manually, it will be set automatically when needed.
*/
- (void)setShowsInPopover:(BOOL)shoulShowInPopover
{
    _showsInPopover = shoulShowInPopover;

    if (!_showsInPopover)
        return;

    _modulePopover = [CPPopover new];
    [_modulePopover setContentViewController:self];
    [_modulePopover setBehavior:CPPopoverBehaviorTransient];
    [_modulePopover setDelegate:self];

    [viewMainTableViewContainer setBorderColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"main-table-view-container-background"]];
}

/*! See - (void)showOnView:(CPView)aView relativeToRect:(CGRect)aRect forParentObject:(id)aParentObject
*/
- (void)showOnView:(CPView)aView forParentObject:(id)aParentObject
{
    [self showOnView:aView relativeToRect:nil forParentObject:aParentObject];
}

/*! Makes the module to be shown in a popover.
    When doing this, you must pass the currentParent yourself.
*/
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

/*! Close the module's popover
*/
- (void)closeModulePopover
{
    if (!_showsInPopover)
        return;

    [[_modulePopover contentViewController] view]._DOMElement.style.borderRadius = "";
    [_modulePopover close];
}


#pragma mark -
#pragma mark Parent Management

/*! Set the current parent.
    This will be automatically done by the parent module.
    The only place where you need to manually pass the current parent is if the module
    is the NUKit Core Module.
*/
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

/*! Internal API that you can override to perform action once the module recieved a current parent.
*/
- (void)moduleDidSetCurrentParent:(id)aParent
{
}


#pragma mark -
#pragma mark Menu Management

/*! You can override this if you need additional NUModuleActions.
    You must create a register a new CPMenuItem for each custom action,
    Then return the list of action in the order you want them to appear in the CPMenu.
*/
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

/*! Registers a new CPMenuItem for the given action
*/
- (void)registerMenuItem:(CPMenuItem)aMenuItem forAction:(int)anAction
{
    if (![_controlsForActionRegistry containsKey:anAction])
        [_controlsForActionRegistry setObject:[] forKey:anAction];

    [_contextualMenuItemRegistry setObject:aMenuItem forKey:anAction];
    [aMenuItem setTarget:self];
}

/*! Returns the action for the given CPMenuItem
*/
- (id)actionForMenuItem:(CPMenuItem)aMenuItem
{
    return [[_contextualMenuItemRegistry allKeysForObject:aMenuItem] firstObject];
}

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! Internal API you can override to give a CPControl that will be used
    to open a NUModuleContext Popover when the user click on CPMenuItem.
    By default, the tableView is used. If your module is table less, but still have
    some CPMenu, be sure to override this.
*/
- (CPControl)defaultPopoverTargetForMenuItem
{
    return tableView;
}


#pragma mark -
#pragma mark Visibility Management

/*! Called by the parent module when the module becomes visible
    You should not override this. To do additional initialization,
    use the internal API - (void)moduleDidShow
*/
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

/*! Returns if the modules agrees on hiding.
    You should not override this. To do additional computation,
    use the internal API - (void)moduleShouldHide
*/
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

/*! Called by the parent module when the module is about to become hidden.
    You should not override this. To do additional deinitialization,
    use the internal API - (void)moduleWillHide.
*/
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

/*! Internal API you can override to perform additional things when
    a module just showed. When this is called, the module is already visible.
*/
- (void)moduleDidShow
{

}

/*! Internal API you can override to perform computation to decide if the
    module should hide.
*/
- (BOOL)moduleShouldHide
{
    return YES;
}

/*! Internal API you can override to perform additional things when
    a module is about to become hidden. When this is called, the module is still visible.
*/
- (void)moduleWillHide
{

}


#pragma mark -
#pragma mark Memory Management

/*! @ignore
*/
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

/*! Called to tell the module to start getting information from the server.
    You should never have to override this method.
*/
- (void)reload
{
    _latestPageLoaded                = -1;
    _maxPossiblePage                 = -1;
    _removedObjectsIDs               = [];
    _numberOfRemainingContextsToLoad = [[self moduleCurrentActiveContexts] count];

    [self _removeScrollViewObservers];

    [_activeTransactionsIDs removeAllObjects];
    [self setTotalNumberOfEntities:-1];
    [self _setPaginationSynchronizing:NO];
    [self _flushTableView];
    [self updateModuleTitle];

    if (!_currentParent)
        return;

    [self _flushCategoriesContent];

    if (!_isProcessingPush)
        [self showLoading];

    if ([[self class] automaticContextManagement])
    {
        if ([_categories count])
        {
            _currentPaginatedCategoryIndex = 0;

            var currentCategory = _categories[_currentPaginatedCategoryIndex],
                context         = [self _contextForCategory:currentCategory];

            [self _reloadUsingContext:context];
        }
        else
        {
            var contexts = [self moduleCurrentActiveContexts];

            // Doing a for loop in case the user defines multiple contexts
            // without defining categories
            for (var i = [contexts count] - 1; i >= 0; i--)
                [self _reloadUsingContext:contexts[i]];
        }
    }

    [self moduleDidReload];
}

/*! @ignore
*/
- (void)_reloadUsingContext:(NUModuleContext)aContext
{
    var fetcherKeyPath = [aContext fetcherKeyPath],
        fetcher = [_currentParent valueForKeyPath:fetcherKeyPath];

    if (!fetcherKeyPath)
        [CPException raise:CPInternalInconsistencyException reason:"Context has no defined fetcherKeyPath in module " + self];

    if (!fetcher)
        [CPException raise:CPInternalInconsistencyException reason:"Context cannot find fetcher " + fetcherKeyPath  + " in currentParent  " + _currentParent + " of module "+ self];

    if (_usesPagination)
        [self _loadFirstPageUsingFetcher:fetcher];
    else
        [self _loadEverythingUsingFetcher:fetcher];
}

/*! @ignore
*/
- (id)_filterForCategory:(NUCategory)aCategory
{
    if (!aCategory || ![aCategory filter])
        return [self filter];

    var userFilter        = [self filter],
        categoryPredicate = [aCategory filter],
        userPredicate,
        resultPredicate;

    if (!userFilter)
        return categoryPredicate;

    // try to make a predicate from the given filter
    if ([userFilter isKindOfClass:CPPredicate])
        userPredicate = userFilter
    else
        userPredicate = [CPPredicate predicateWithFormat:userFilter];

    // if it didn't work, create full text search predicate
    if (!userPredicate)
    {
        var context = [self _contextForCategory:aCategory],
            fetcher = [_currentParent valueForKeyPath:[context fetcherKeyPath]];

        userPredicate = [[fetcher newManagedObject] fullTextSearchPredicate:userFilter];
    }


    resultPredicate = [[CPCompoundPredicate alloc] initWithType:CPAndPredicateType
                                                  subpredicates:[userPredicate, categoryPredicate]];

    return resultPredicate;
}

/*! @ignore
*/
- (void)_loadPage:(CPNumber)aPage usingFetcher:(NURESTFetcher)aFetcher
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

    var currentCategory = [_categories count] ? _categories[_currentPaginatedCategoryIndex] : nil,
        filter          = [self _filterForCategory:currentCategory];

    var ID = [aFetcher fetchWithMatchingFilter:filter
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

/*! @ignore
*/
- (void)_loadEverythingUsingFetcher:(NURESTFetcher)aFetcher
{
    [aFetcher flush];
    [self _loadPage:nil usingFetcher:aFetcher];
}

/*! @ignore
*/
- (void)_loadFirstPageUsingFetcher:(NURESTFetcher)aFetcher
{
    [aFetcher flush];
    [self _loadPage:0 usingFetcher:aFetcher];
}

/*! @ignore
*/
- (void)_loadNextPageUsingFetcher:(NURESTFetcher)aFetcher
{
    [self _loadPage:(_latestPageLoaded + 1) usingFetcher:aFetcher];
}

/*! @ignore
*/
- (void)__reloadLatestPageUsingFetcher:(NURESTFetcher)aFetcher
{
    [self _loadPage:_latestPageLoaded usingFetcher:aFetcher];
}

/*! @ignore
*/
- (BOOL)_isResourceAlreadyFetched
{
    var currentCategory   = _categories[_currentPaginatedCategoryIndex],
        currentFilter     = [[currentCategory filter] isKindOfClass:CPPredicate] ? [[currentCategory filter] predicateFormat] : [currentCategory filter],
        currentIdentifier = [currentCategory contextIdentifier];

    for (var i = 0; i < _currentPaginatedCategoryIndex; i++)
    {
        var category   = _categories[i],
            filter     = [[category filter] isKindOfClass:CPPredicate] ? [[category filter] predicateFormat] : [category filter],
            identifier = [category contextIdentifier];

        if (filter == currentFilter && identifier == currentIdentifier)
            return YES;
    }

    return NO;
}

/*! @ignore
*/
- (void)_loadNextPage
{
    var fetcher;

    if ([_categories count])
    {
        if (_maxPossiblePage != -1 && _latestPageLoaded >= _maxPossiblePage)
        {
            _currentPaginatedCategoryIndex++;

            if (![self _shouldLoadNextCategory])
                return;

            if ([self _isResourceAlreadyFetched])
                return [self _loadNextPage]

            _maxPossiblePage = -1;
            _latestPageLoaded = -1;
        }

        var category       = _categories[_currentPaginatedCategoryIndex],
            context        = [_contextRegistry valueForKey:[category contextIdentifier]],
            fetcherKeyPath = [context fetcherKeyPath];

        fetcher = [_currentParent valueForKeyPath:fetcherKeyPath];

        // when switching category flush the fetcher in case it was used in a previous category
        if (_maxPossiblePage == -1 && _latestPageLoaded == -1)
            [fetcher flush];
    }
    else
    {
        var contexts       = [self moduleCurrentActiveContexts],
            fetcherKeyPath = [[contexts firstObject] fetcherKeyPath];

        fetcher = [_currentParent valueForKeyPath:fetcherKeyPath];
    }

    if (fetcher)
        [self _loadNextPageUsingFetcher:fetcher];
    else
        [CPException raise:CPInternalInconsistencyException reason:"Cannot find fetcher to load next page in module " + self];
}

/*! @ignore
*/
- (void)_reloadLatestPage
{
    if (_timerReloadLatestPage)
    {
        [self _setPaginationSynchronizing:NO];
        [_timerReloadLatestPage invalidate];
    }

    [self _setPaginationSynchronizing:YES];

    _timerReloadLatestPage = [CPTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_performReloadLatestPage:) userInfo:nil repeats:NO];
}

/*! @ignore
*/
- (void)_performReloadLatestPage:(CPTimer)aTimer
{
    var contexts = [self moduleCurrentActiveContexts];
    _totalNumberOfEntities = 0;

    for (var i = [contexts count] - 1 ; i >= 0 ; i --)
    {
        var context        = contexts[i],
            fetcherKeyPath = [context fetcherKeyPath],
            fetcher        = [_currentParent valueForKeyPath:fetcherKeyPath];

        if (fetcher)
            [fetcher countWithMatchingFilter:[self filter]
                                   masterFilter:[self masterFilter]
                                      groupedBy:[self masterGrouping]
                                andCallSelector:@selector(_fetcher:ofObject:didCountChildren:)
                                       ofObject:self
                                          block:nil];
        else
            [self _setPaginationSynchronizing:NO];
    }
}

/*! @ignore
*/
- (void)_fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didCountChildren:(int)aCount
{
    [self _setPaginationSynchronizing:NO];
    [self setTotalNumberOfEntities:(_totalNumberOfEntities + aCount)];
    [self _synchronizePagination];

    if (![_categories count])
        [self __reloadLatestPageUsingFetcher:aFetcher];
}

/*! ignore
*/
- (void)_synchronizePagination
{
    if (_latestPageLoaded == -1)
        return;

    if ([_categories count])
    {
        if (_currentPaginatedCategoryIndex >= [_categories count])
            return;

        var category       = _categories[_currentPaginatedCategoryIndex],
            context        = [_contextRegistry valueForKey:[category contextIdentifier]],
            fetcher        = [_currentParent valueForKeyPath:[context fetcherKeyPath]];

        _maxPossiblePage    = MAX(Math.ceil([fetcher currentTotalCount] / NUModuleRESTPageSize) - 1, 0);
        _latestPageLoaded   = MAX(Math.ceil([[fetcher array] count] / NUModuleRESTPageSize) - 1, 0);
    }
    else
    {
        var context = [self moduleCurrentActiveContexts][0],
            fetcher = fetcher = [_currentParent valueForKeyPath:[context fetcherKeyPath]];

        _maxPossiblePage    = MAX(Math.ceil(_totalNumberOfEntities / NUModuleRESTPageSize) - 1, 0);
        _latestPageLoaded   = MAX(Math.ceil([[fetcher array] count] / NUModuleRESTPageSize) - 1, 0);
    }
    CPLog.debug("PAGINATION: Synchronized pagination is now %@/%@ (objects: %@/%@)", _latestPageLoaded, _maxPossiblePage, [_dataSource count], _totalNumberOfEntities);
}

/*! ignore
*/
- (void)_setPaginationSynchronizing:(BOOL)isSycing
{
    [self willChangeValueForKey:@"formatedTotalNumberOfEntities"];
    _paginationSynchronizing = isSycing;
    [self didChangeValueForKey:@"formatedTotalNumberOfEntities"];
}

/*! ignore
*/
- (void)_addScrollViewObservers
{
    if (![self isTableBasedModule] || _isObservingScrollViewBounds)
        return;

    _isObservingScrollViewBounds = YES;

    var scrollViewClipView = [[[tableView superview] superview] contentView];
    [scrollViewClipView addObserver:self forKeyPath:@"bounds" options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
}

/*! ignore
*/
- (void)_removeScrollViewObservers
{
    if (![self isTableBasedModule] || !_isObservingScrollViewBounds)
        return;

    _isObservingScrollViewBounds = NO;

    var scrollViewClipView = [[[tableView superview] superview] contentView];
    [scrollViewClipView removeObserver:self forKeyPath:@"bounds"];
}

#pragma mark Reloading Internal API

/*! Internal API you can override to perform additional things after the module
    has reloaded.
*/
- (void)moduleDidReload
{

}


#pragma mark -
#pragma mark Object Counting

/*! @ignore
*/
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

/*! @ignore
*/
- (void)setTotalNumberOfEntities:(CPNumber)aTotal
{
    [self willChangeValueForKey:@"totalNumberOfEntities"];
    [self willChangeValueForKey:@"formatedTotalNumberOfEntities"];
    _totalNumberOfEntities = aTotal;
    [self didChangeValueForKey:@"totalNumberOfEntities"];
    [self didChangeValueForKey:@"formatedTotalNumberOfEntities"];
}

/*! @ignore
*/
- (void)_updateGrandTotal
{
    if ([_categories count])
        [self _updateGrandTotalWithCategories];
    else
        [self _updateGrandTotalWithNoCategories];
}

/*! @ignore
*/
- (void)_updateGrandTotalWithCategories
{
    var grandTotal      = 0,
        managedIdentifiers = [];

    for (var i = 0; i < [_categories count]; i++)
    {
        var category = _categories[i],
            context  = [self _contextForCategory:category];

        if ([category filter])
        {
            grandTotal += [category currentTotalCount];
            continue;
        }

        if  ([managedIdentifiers containsObject:[context identifier]])
            continue;

        grandTotal += [[_currentParent valueForKeyPath:[context fetcherKeyPath]] currentTotalCount];
        [managedIdentifiers addObject:[context identifier]];
    }

    [self setTotalNumberOfEntities:grandTotal];
}

/*! @ignore
*/
- (void)_updateGrandTotalWithNoCategories
{
    var grandTotal  = 0,
        contexts    = [self moduleCurrentActiveContexts];

    for (var i = [contexts count] - 1; i >= 0; i--)
        grandTotal += [[_currentParent valueForKeyPath:[contexts[i] fetcherKeyPath]] currentTotalCount];

    [self setTotalNumberOfEntities:grandTotal];
}


#pragma mark -
#pragma mark  Module Titles

/*! Internal API you can override to change the module title.
    This is called during the reloading phase.
*/
- (void)updateModuleTitle
{
}

/*! Internal API you can override to change the module title.
    This is called during the submodule selection phase.
*/
- (void)updateModuleSubtitle
{
}


#pragma mark -
#pragma mark Permitted Actions

/*! Update the permitted actions list.
    Call this is you want the list of available action to be updated at anytime.
    This is normally done automatically during the reloading phase.
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! Override if you want to change the different permitted action for a particular object.
*/
- (CPSet)permittedActionsForObject:(id)anObject
{
    var conditionAdministrator  = _currentUserHasRoles([NUPermissionLevelRoot, NUPermissionLevelAdmin]),
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

/*! set if the given action is permitted.
    you should not need to use this.
*/
- (void)setAction:(CPString)anAction permitted:(BOOL)isPermitted
{
    if (isPermitted && ![_currentPermittedActions containsObject:anAction])
        [_currentPermittedActions addObject:anAction];

    if (!isPermitted && [_currentPermittedActions containsObject:anAction])
        [_currentPermittedActions removeObject:anAction];

    [[self controlsForAction:anAction] makeObjectsPerformSelector:@selector(setHidden:) withObject:!isPermitted];
}

/*! Check if the given action is currently permitted.
*/
- (BOOL)isActionPermitted:(int)anAction
{
    return [_currentPermittedActions containsObject:anAction];
}

/*! Register a particular control for a given action.
    This control will later be enabled/disabled according to the current permitted actions.
*/
- (void)registerControl:(CPControl)aControl forAction:(CPString)anAction
{
    if (![_controlsForActionRegistry containsKey:anAction])
        [_controlsForActionRegistry setObject:[] forKey:anAction];

    [[_controlsForActionRegistry objectForKey:anAction] addObject:aControl];
}

/*! Returns all the controls registred for a particular action
*/
- (CPArray)controlsForAction:(CPString)anAction
{
    return [_controlsForActionRegistry objectForKey:anAction];
}

/*! Return the action of by a particular registerer control.
*/
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

/*! Returns the action of a sender. This can be a control or a CPMenuItem.
*/
- (void)actionForSender:(id)aSender
{
    if ([aSender isKindOfClass:CPMenuItem])
        return [self actionForMenuItem:aSender];
    else
        return [self actionForControl:aSender];
}

#pragma mark Additional Action

/*! Internal API you can override to register additional action for custom controls.
*/
- (void)configureAdditionalControls
{
}


#pragma mark -
#pragma mark CRUD Operations

/*! Open the popover used to create a new object
*/
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

/*! Open the popover used to edit an existing object
*/
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

/*! Opens the popover to delete an existing object.
*/
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

/*! @ignore
*/
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

/*! Internal API you can override if you want to perform additional information just before
    the actual deletion of the given objects.
*/
- (CPArray)modulePerformSelectionCleanupBeforeDeletion:(CPArray)someSelectedObjects
{
    return someSelectedObjects;
}


#pragma mark -
#pragma mark Import and Export

/*! @ignore
    do not use this
*/
- (void)exportObject:(id)anObject usingAction:(id)anAction
{
    [[NURESTJobsController defaultController] postJob:[self moduleExportJobForAction:anAction]
                                         toEntity:anObject
                                  andCallSelector:@selector(_didExport:)
                                         ofObject:self];
}

/*! @ignore
    do not use this
*/
- (@action)exportSelectedObjects:(id)aSender
{
    for (var i = [_currentSelectedObjects count] - 1; i >= 0; i--)
        [self exportObject:_currentSelectedObjects[i] usingAction:[self actionForSender:aSender]];
}

/*! @ignore
    do not use this
*/
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

/*! @ignore
    do not use this
*/
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

/*! @ignore
    do not use this
*/
- (@action)import:(id)aSender
{
    [self importInObject:_currentParent usingAction:[self actionForSender:aSender]];
}

/*! @ignore
    do not use this
*/
- (void)_didImport:(NUJobImport)aJob
{
    if ([aJob status] != NURESTJobStatusSUCCESS)
        [NURESTError postRESTErrorWithName:@"Import Failed" description:[aJob result] connection:nil];
}

#pragma mark Import and Export Internal API

/*! @ignore
    do not use this
*/
- (NURESTJob)moduleImportJobForAction:(id)anAction
{
    return [NUJobImport new];
}

/*! @ignore
    do not use this
*/
- (NURESTJob)moduleExportJobForAction:(id)anAction
{
    return [NUJobExport new];
}


#pragma mark -
#pragma mark Help Window

/*! @ignore
    do not use this. This will be removed
*/
- (@action)openHelpWindow:(id)aSender
{
    window.open([[CPURL URLWithString:@"Resources/Help/" + [[self class] moduleIdentifier] + @".html"] absoluteString], "_new", "width=800,height=600");
}


#pragma mark -
#pragma mark Filtering

/*! @ignore
*/
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

/*! Sets the current filter, and perform a reload.
*/
- (@action)filterObjects:(id)aSender
{
    var filterString = [aSender stringValue];

    [self setFilter:[filterString length] ? filterString : nil];

    [self reload];
}

/*! Apply the advanced given filers.
Date filters will return the default date toString in format Mon May 21 2018 10:59:06 GMT-0700 (PDT)
We need to intercept predicates and translate dates to format: MM/DD/YYYY HH:MIN:SS timezoneoffset
*/
- (void)applyAdvancedFilters:(CPPredicate)aPredicate
{
    var subpredicates = [aPredicate subpredicates];
    var isModified = false;
    var predicateSubPredicates = [];
    for (var i = 0; i < [subpredicates count]; i++) {
      var predicate = subpredicates[i];
      var lhs = [predicate leftExpression];
      var valueForKeyPath = [[predicate rightExpression] expressionValueWithObject:nil context:nil];
      var date = new Date(valueForKeyPath);
      if ( (typeof valueForKeyPath === 'string') && !isNaN(date) ) {
          var dateString = [CPString stringWithFormat:@"%02d/%02d/%04d %02d:%02d:%02d %s", date.getMonth() + 1, date.getDate(), date.getFullYear(), date.getHours(), date.getMinutes(), date.getSeconds(), [CPDate timezoneOffsetString:date.getTimezoneOffset()]];
          var rhs = [CPExpression expressionForConstantValue:dateString];
          predicate = [CPComparisonPredicate predicateWithLeftExpression:lhs
                                                         rightExpression:rhs
                                                          modifier:[predicate comparisonPredicateModifier]
                                                          type: [predicate predicateOperatorType]
                                                          options: [predicate options]
                       ];
          isModified = true;
      }
      predicateSubPredicates.push(predicate);
    }
    var compoundPredicate = isModified ? [[CPCompoundPredicate alloc] initWithType:[aPredicate compoundPredicateType] subpredicates:predicateSubPredicates] : aPredicate;
    var aString = [compoundPredicate predicateFormat];
    [filterField setStringValue:aString];
    [filterField _updateCancelButtonVisibility];
    [self filterObjects:filterField];
}


#pragma mark -
#pragma mark External Windows

/*! Clones the module and opens it in a new CPPlatformWindow.
*/
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

/*! Close the module if opened in an external CPPlatformWindow
*/
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

/*! Internal API you can override to perform additional things when a module
    has just been cloned and opened in an external window.
*/
- (void)didOpenCloneModule:(NUModule)aCloneModule
{
}

/*! Internal API you can override in order to perform additional things when the cloned
    module has just been opened.
*/
- (void)didOpenAsCloneOfModule:(NUModule)aParentModule
{
    [[[self view] window] setTitle:[self moduleTitle]];

    [buttonOpenInExternalWindow setHidden:YES];
}

/*! @ignore
*/
- (void)didCloseFromExternalWindow
{
    [self willHide];
}


#pragma mark -
#pragma mark TabView Management

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! Sets the list of the submodule for the current module.
    This is usually done in viewDidLoad.
*/
- (void)setSubModules:(CPArray)someModules
{
    for (var i = [_subModules count] - 1; i >= 0; i--)
        [self removeSubModule:_subModules[i]];

    for (var i = 0, c = [someModules count]; i < c; i++)
        [self addSubModule:someModules[i]];

    [self moduleDidSetSubModules:someModules];
}

/*! Add a single submodule.
*/
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

/*! Removes a single submodule.
*/
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

/*! Returns the list of visible submodules.
*/
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

/*! Refresh the list of active submodules.
*/
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

/*! Call willHide and resets the currentParent of all submodules
*/
- (void)hideAllSubModules
{
    for (var i = [_activeSubModules count] - 1; i >= 0; i--)
    {
        var controller = _activeSubModules[i];
        [controller willHide];
        [controller setCurrentParent:nil];
    }
}

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_setCurrentParentForSubModules
{
    var parentObject = [[self class] isTableBasedModule] ? [_currentSelectedObjects firstObject] : _currentParent;

    if (tabViewContent)
        [[self _subModuleWithIdentifier:[[tabViewContent selectedTabViewItem] identifier]] setCurrentParent:parentObject];
    else
        [_activeSubModules makeObjectsPerformSelector:@selector(setCurrentParent:) withObject:parentObject];
}


#pragma mark  Sub Modules Internal API

/*! Internal API you can override to perform additional things when a module just
    set its submodules
*/
- (void)moduleDidSetSubModules:(CPArray)someModules
{
}

/*! Internal API you can override to perform additional things when a module just
    set one submodule.
*/
- (void)moduleDidAddSubModule:(NUModule)aSubModule
{
}

/*! Internal API you can override to perform additional things when a module just
    removed one submodule
*/
- (void)moduleWillRemoveSubModule:(NUModule)aSubModule
{
}

/*! Returns the list of current active submodules.
    You can overrides this to update the list of active submodules according to some properties
    of a parent of instance.
*/
- (CPArray)currentActiveSubModules
{
    return _subModules;
}

/*! internal API called when the list of visible submodule just changed.
*/
- (void)moduleDidChangeVisibleSubmodule
{

}


#pragma mark -
#pragma mark  Push Management

/*! Starts listening for push notifications
*/
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

/*! Stops listening for push notifications
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_reloadUIAfterPush
{
    if (![self isTableBasedModule])
        return;

    [self tableViewReloadData];

    if (_usesPagination)
    {
        [self _synchronizePagination];
        [self _reloadLatestPage];
    }
}

/*! @ignore
*/
- (void)_insertCreatedObject:(id)anObject updateTotal:(BOOL)shouldUpdateTotal
{
    if (_filter)
        return;

    [anObject setParentObject:_currentParent];

    var array = [_categories count] > 0 ? [[self categoryForObject:anObject] children] : _dataSource;

    if (![[array filteredArrayUsingPredicate:[CPPredicate predicateWithFormat:@"ID == %@", [anObject ID]]] count])
    {
        [array addObject:anObject];

        if (shouldUpdateTotal)
            [self setTotalNumberOfEntities:(_totalNumberOfEntities + 1)];
    }

    [self _manageGettingStartedVisibility];
}

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_refetchObject:(id)anObject hierarchy:(BOOL)shouldRefreshHierarchy
{
    _reloadHierarchyAfterRefetch = shouldRefreshHierarchy;

    if (anObject)
        [anObject fetchAndCallSelector:@selector(_didRefetchObject:connection:) ofObject:self];
}

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_updateCurrentEditedObjectWithObjectIfNeeded:(id)anObject
{
    if (![[_currentContext editedObject] isEqual:anObject])
        return;

    [_currentContext updateEditedObjectWithNewVersion:anObject];
}

#pragma mark Push Management Internal API

/*! Internal API you can override to perform additional operations
    just before the module processed one or more push notifications.
*/
- (void)performPrePushOperation
{
}

/*! Internal API you can override to perform additional operations
    just after the module processed one or more push notifications.
*/
- (void)performPostPushOperation
{
    if ([tableView isKindOfClass:CPOutlineView])
        [tableView expandAll];
}

/*! Decides if the module should manage a push notification.
    This is just high level.
    You can override this, but once your custom logic is done,
    and if it didn't match anything you want, be sure to return the super return.
*/
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

/*! Decides if the module should process a push notification.
    You can override this, but once your custom logic is done,
    and if it didn't match anything you want, be sure to return the super return.
*/
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

/*! Shows the loading indicator on the table view
*/
- (void)showLoading
{
    if (tableView)
        [[NUDataTransferController defaultDataTransferController] showFetchingViewOnView:tableView];
}

/*! Hides the loading indicator on the table view
*/
- (void)hideLoading
{
    if (tableView)
        [[NUDataTransferController defaultDataTransferController] hideFetchingViewFromView:tableView];
}

/*! Close all popovers.
*/
- (void)closeAllPopovers
{
    var contexts = [_contextRegistry allValues];

    for (var i = [contexts count] - 1; i >= 0; i--)
        [[contexts[i] popover] close];

    for (var i = [_subModules count] - 1; i >= 0; i--)
        [_subModules[i] closeAllPopovers];

    [[NUAdvancedFilteringViewController defaultController] closePopover];
}

/*! @ignore
*/
- (void)_flushTableView
{
    if (![self isTableBasedModule])
        return;

    [self _flushCategoriesContent];

    [_dataSource removeAllObjects];
    [self tableViewReloadData];
}

/*! @ignore
*/
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

/*! Check if the module is a child of any parent with a given class name
*/
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

/*! Returns the content of the Datasource, with the categories removed, if any
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (void)hideValidationErrorsForTabView:(CPTabView)aTabView
{
    var itemObjects = aTabView._itemObjects;

    for (var i = 0; i < [itemObjects count] ; i++)
        [itemObjects[i] setErrorsNumber:0];
}



#pragma mark -
#pragma mark Cucapp

/*! Overrides this to define more cucappIDs.
    You should use - (void)setCuccapPrefix:(CPString)aPrefix forAction:(CPString)anAction
*/
- (void)configureCucappIDs
{
    [self setCuccapPrefix:@"add" forAction:NUModuleActionAdd];
    [self setCuccapPrefix:@"edit" forAction:NUModuleActionEdit];
    [self setCuccapPrefix:@"delete" forAction:NUModuleActionDelete];
    [self setCuccapPrefix:@"instantiate" forAction:NUModuleActionInstantiate];
    [self setCuccapPrefix:@"import" forAction:NUModuleActionImport];
    [self setCuccapPrefix:@"export" forAction:NUModuleActionExport];
}

/*! set the cucapp prefix for a given action
*/
- (void)setCuccapPrefix:(CPString)aPrefix forAction:(CPString)anAction
{
    [_cuccapPrefixesRegistry setObject:aPrefix forKey:anAction];
}

/*! Returns the cucapp prefix for the given action
*/
- (CPString)cuccapPrefixForAction:(CPString)anAction
{
    return [_cuccapPrefixesRegistry objectForKey:anAction];
}

/*! Update the cucapp IDs when the current active context changes.
*/
- (void)updateCucappIDsAccordingToContext:(NUModuleContext)aContext
{
    if (filterField)
    {
        _cucappID(filterField, @"field_search_" + [aContext identifier]);
        _cucappID([filterField searchButton], @"button_search_" + [aContext identifier]);
    }

    if (_buttonFirstCreate && ![_buttonFirstCreate cucappIdentifier])
        _cucappID(_buttonFirstCreate, @"button_" + [self cuccapPrefixForAction:NUModuleActionAdd] + @"_" + [aContext identifier]);

    if (_buttonFirstImport)
        _cucappID(_buttonFirstImport, @"button_" + [self cuccapPrefixForAction:NUModuleActionImport] + @"_" + [aContext identifier]);

    if (![_buttonAddObject cucappIdentifier])
        _cucappID(_buttonAddObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionAdd] + @"_" + [aContext identifier]);

    _cucappID(_buttonEditObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionEdit] + @"_" + [aContext identifier]);
    _cucappID(_buttonDeleteObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionDelete] + @"_" + [aContext identifier]);
    _cucappID(_buttonInstantiateObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionInstantiate] + @"_" + [aContext identifier]);
    _cucappID(_buttonImportObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionImport] + @"_" + [aContext identifier]);
    _cucappID(_buttonExportObject, @"button_" + [self cuccapPrefixForAction:NUModuleActionExport] + @"_" + [aContext identifier]);
}


#pragma mark -
#pragma mark Masking Views

/*! Display the masking view.
*/
- (void)displayMaskingView
{
    if (!maskingView || [maskingView superview])
        return;

    [maskingView setFrameSize:[viewEditObject frameSize]];
    [viewEditObject addSubview:maskingView];

    [self didShowMaskingView];
}

/*! Hides the masking view.
*/
- (void)hideMaskingView
{
    if (!maskingView || ![maskingView superview])
        return;

    [maskingView removeFromSuperview];
    [self didHideMaskingView];
}

/*! Display the masking view for multiple selected objects.
*/
- (void)displayMultipleSelectedObjectsMaskingView
{
    if (!multipleSelectedObjectsMaskingView || [multipleSelectedObjectsMaskingView superview])
        return;

    [multipleSelectedObjectsMaskingView setFrameSize:[viewEditObject frameSize]];
    [viewEditObject addSubview:multipleSelectedObjectsMaskingView];

    [self didShowMultipleSelectionMaskingView];
}

/*! Hides the masking view for multiple selected objects.
*/
- (void)hideMultipleSelectedObjectsMaskingView
{
    if (!multipleSelectedObjectsMaskingView || ![multipleSelectedObjectsMaskingView superview])
        return;

    [multipleSelectedObjectsMaskingView removeFromSuperview];
    [self didHideMultipleSelectionMaskingView];
}

/*! Display the current masking view, either the one for single or for multiple selections.
*/
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

/*! Hides the current masking view, either the one for single or for multiple selection.
*/
- (void)hideCurrentMaskingView
{
    [self hideMultipleSelectedObjectsMaskingView];
    [self hideMaskingView];
}

#pragma mark Masking Views Internal API

/*! Internal API you can override to block the showing of a the single selection masking view
*/
- (BOOL)shouldShowMaskingView
{
    return YES;
}

/*! Internal API you can override to perform additional operations when the single selection masking view becomes visible
*/
- (void)didShowMaskingView
{
}

/*! Internal API you can override to perform additional operations when the single selection masking view becomes hidden
*/
- (void)didHideMaskingView
{
}

/*! Internal API you can override to block the showing of a the multiple selection masking view
*/
- (BOOL)shouldShowMultipleSelectionMaskingView
{
    return YES;
}

/*! Internal API you can override to perform additional operations when the multiple selection masking view becomes visible
*/
- (void)didShowMultipleSelectionMaskingView
{
}

/*! Internal API you can override to perform additional operations when the multiple selection masking view becomes hidden
*/
- (void)didHideMultipleSelectionMaskingView
{
}


#pragma mark -
#pragma mark Getting Started View

/*! @ignore
*/
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

/*! Checks if the getting started view is visible.
*/
- (BOOL)isGettingViewStartedVisible
{
    return !![viewGettingStarted superview];
}

#pragma mark Getting Started View Internal API

/*! Internal API you can override to perform additional operations
    when the getting started view becomes visible
*/
- (void)didShowGettingStartedView:(BOOL)isVisible
{

}


#pragma mark -
#pragma mark Split View Management

/*! adjust the sizing of the split views.
*/
- (void)adjustSplitViewSize
{
    if (splitViewMain && [[splitViewMain subviews] count] > 1 && _autoResizeSplitViewSize)
    {
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
        [splitViewMain setPosition:_autoResizeSplitViewSize ofDividerAtIndex:0];
    }
}


#pragma mark -
#pragma mark Selection Management

/*! Sets the current selection. This is called automatically when the Selection
    of the main table view is changing.
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_saveCurrentSelection
{
    if (![self isTableBasedModule])
        return;

    _previousSelectedObjects = [_currentSelectedObjects copy];
}

/*! @ignore
*/
- (void)_restorePreviousSelection
{
    if (![self isTableBasedModule])
        return;

    [self setCurrentSelection:_previousSelectedObjects];
}

/*! @ignore
*/
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
        var currentSelectedObject = _currentSelectedObjects[0];

        [self hideCurrentMaskingView];
        [self moduleDidSelectObjects:_currentSelectedObjects];
        [self refreshActiveSubModules];
        [self updateModuleSubtitle];
        [self setCurrentContextWithIdentifier:[currentSelectedObject RESTName]];
        [_currentContext setEditedObject:currentSelectedObject];
    }
    else
    {
        [self moduleDidSelectObjects:_currentSelectedObjects];
        [self displayCurrentMaskingView];
    }

    [self updatePermittedActions];

    [previousSelection makeObjectsPerformSelector:@selector(discardAllFetchers)];
}

/*! Archive the current selection for later restoration
*/
- (void)archiveCurrentSelection
{
    if (![self isTableBasedModule] || ![[self class] automaticSelectionSaving] || !_currentParent || [_currentParent isDirty])
        return;

    [_selectionArchive setObject:[_currentSelectedObjects valueForKey:@"ID"] forKey:[_currentParent ID]];
}

/*! Retore previously archived selection if possible
*/
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

        var dummyObject = isTableView ? [NURESTObject RESTObjectWithID:IDs[i]] : [_dataSource objectWithID:IDs[i]];
        [dummyObjects addObject:dummyObject];
    }

    _scrollToSelectedRows = YES;
    [self setCurrentSelection:dummyObjects];
    _scrollToSelectedRows = NO;

    [_selectionArchive removeObjectForKey:key];
}

/*! Clean up selection archive cache.
*/
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

/*! Internal API you can override to peform additional operations when the user changed the selection
*/
- (void)moduleDidSelectObjects:(CPArray)someObjects
{
}

/*! Internal API you can override to decide if the user can change the current selection
*/
- (BOOL)moduleShouldChangeSelection
{
    if (editorController)
        return [editorController checkIfEditorAgreeToHide];

    return YES;
}


#pragma mark -
#pragma mark Category Management

/*! Returns the NUCategory to be used for the given objects.
*/
- (NUCategory)categoryForObject:(id)anObject
{
}

/*! Sets the list of NUCategories to be used.
*/
- (void)setCategories:(CPArray)someCategories
{
    [self _flushCategoriesContent];

    [self willChangeValueForKey:@"categories"];
    _categories = someCategories;
    [self didChangeValueForKey:@"categories"];

    // Use pagination only if all categories specify a context
    _usesPagination = YES;
    for (var i = 0; i < [_categories count]; i++)
    {
        if (![_categories[i] contextIdentifier])
        {
            _usesPagination = NO;
            break;
        }
    }

    if ([_categories count] && _usesPagination)
        _currentPaginatedCategoryIndex = 0;
}

/*! @ignore
*/
- (void)_shouldLoadNextCategory
{
    return [_categories count] && _currentPaginatedCategoryIndex <= [_categories count] - 1;
}

/*! @ignore
*/
- (void)_flushCategoriesContent
{
    for (var i = [_categories count] - 1; i >= 0; i--)
        [[_categories[i] children] removeAllObjects];
}


#pragma mark -
#pragma mark Content Management

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (void)fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didFetchContent:(CPArray)someContents
{
    if (!someContents)
    {
        [self errorWhileFetchingWithFetcher:aFetcher ofObject:anObject fetchContent:someContents];
        return;
    }

    [self performPreFetchOperation:someContents];
    [self _saveCurrentSelection];

    _latestSortDescriptors = [aFetcher currentSortDescriptors];
    _numberOfRemainingContextsToLoad--;

    if ([_categories count] > 0)
    {
        var currentCategory = _categories[_currentPaginatedCategoryIndex];

        // When categories have no filter, it uses the context to store
        // paginated information. If it has filters, store the total number
        // of entities in the current category.
        if ([currentCategory filter])
        {
            [currentCategory setCurrentPage:[aFetcher currentPage]];
            [currentCategory setCurrentTotalCount:[aFetcher currentTotalCount]];
        }

        var categorizedContent = [_categories copy];

        for (var i = [someContents count] - 1; i >= 0; i--)
        {
            var object = someContents[i];

            if (![currentCategory filter])
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

    [self _updateGrandTotal];

    if (_usesPagination)
    {
        [self _synchronizePagination];

        if ([self _shouldLoadNextCategory] && [someContents count] < NUModuleRESTPageSize)
            [self _loadNextPage];
        else
            [self _addScrollViewObservers];

        [self _restorePreviousSelection];
    }

    if ([self isTableBasedModule] && ![tableView numberOfSelectedRows] && !_numberOfRemainingContextsToLoad)
        [self restoreArchivedSelection];

    [self performPostFetchOperation];
}

/*! Performs the sorting of the data source
*/
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

/*! Sets the content of the data source.
*/
- (void)setDataSourceContent:(CPArray)contents
{
    [self hideLoading];

    [_dataSource setContent:contents];
    [self sortDataSourceContent];
    [self tableViewReloadData];
    [self _manageGettingStartedVisibility];
}

/*! Create a new instance of the object with the given rest name
*/
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

/*! Internal API you can override to decide how to handle a fetching error.
    By default it will post an error.
*/
- (void)errorWhileFetchingWithFetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject fetchContent:(CPArray)someContents
{
    [NURESTConnection handleResponseForConnection:[aFetcher currentConnection] postErrorMessage:YES];
}

/*! internal API you can override to perform additional operations
    just before the module fetches the children
*/
- (void)performPreFetchOperation:(CPArray)someContents
{

}

/*! internal API you can override to perform additional operations
    just after the module fetched the children
*/
- (void)performPostFetchOperation
{

}

/*! internal API you can override to perform additional operations
    just after the module re fetched the children (used for pagination)
*/
- (void)performPostRefetchOperation
{

}


#pragma mark -
#pragma mark Should Hide Management

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_discardPendingChanges:(id)someUserInfo
{
    // pass
}

/*! @ignore
*/
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

/*! @ignore
*/
- (void)_continueTabChange:(CPTabViewItem)aTabViewItem
{
    _overrideShouldHide = YES;
    [tabViewContent selectTabViewItem:aTabViewItem];
}


#pragma mark -
#pragma mark Data View Management

/*! Register data view with the given name to be used for the given class
*/
- (void)registerDataViewWithName:(CPString)aName forClass:(Class)aClass
{
    var dataView = [[[NUKit kit] registeredDataViewWithIdentifier:aName] duplicate];
    [_dataViews setObject:dataView forKey:aClass.name];
}

/*! Returns the data view registered for the given class
*/
- (CPView)registeredDataViewForClass:(Class)aClass
{
    return [_dataViews objectForKey:aClass.name]
}

/*! @ignore
*/
- (CPView)_dataViewForObject:(id)anObject
{
    return [self registeredDataViewForClass:[anObject class]];
}

/*! Set the dataview of the for given object to be highlighted.
    It will call setHighlighted on the corresponding dataview.
    The data view is responsible to show that it is highlighted.
*/
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

/*! Called when a data view will be displayed.
*/
- (void)willDisplayDataView:(CPView)aView
{
}


#pragma mark -
#pragma mark Responder Chain Management

/*! Returns the initial first responder of the module.
*/
- (CPResponder)initialFirstResponder
{
    var module = [self visibleSubModule];

    if (module)
        return [module initialFirstResponder];

    return tableView || tabViewContent;
}

/*! @ignore
*/
- (BOOL)acceptsFirstResponder
{
    return YES;
}


#pragma mark -
#pragma mark Inspector Management

/*! Open the inspect for the selected object.
*/
- (@action)openInspector:(id)aSender
{
    [[NUKit kit] openInspectorForSelectedObject];
}


#pragma mark -
#pragma mark Editor Management

/*! Shows or hide the editor, if any
*/
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

/*! Tells the editor controller to update itself according to the
    given objects.
*/
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

/*! @ignore
*/
- (@action)tableViewDidClick:(id)aSender
{
    if (!_selectionDidChanged && [self editorController] && [[self editorController] currentParent] != [_currentSelectedObjects firstObject] && [self _standardShouldSelectRowIndexes:[tableView selectedRowIndexes]])
        [self updateEditorControllerWithObjects:_currentSelectedObjects];
}


#pragma mark Editor Management Internal API

/*! Configure the given editor. This will be called by initialization.
*/
- (void)configureEditor:(NUEditorsViewController)anEditorController
{
}

/*! Internal API you can override to block the editor for beeing shown.
*/
- (BOOL)moduleEditorShouldShow
{
    return YES;
}

/*! Internal API you can override to perform addition operations
    just after the editor becomes visible
*/
- (void)moduleEditorDidShow
{
}

/*! Internal API you can override to perform addition operations
    just before the editor becomes hidden
*/
- (void)moduleEditorWillHide
{
}

/*! Internal API you can override to return an optional transformer
    that will be used to change the editor title.
*/
- (id)moduleEditorTitleTransformer
{
    return nil;
}

/*! If the editor has a title, you can return a key path
    that will be used on the editor currentParent to update the title.
*/
- (CPString)moduleEditorTitleKeyPathForObject:(id)anObject
{
    return @"name"
}

/*! If the editor has a icon, you can return the image
    to use according to the given object.
*/
- (CPImage)moduleEditorImageTitleForObject:(id)anObject
{
    return [anObject icon];
}


#pragma mark -
#pragma mark Keys Events

/*! @ignore
*/
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

/*! @ignore
*/
- (void)keyDown:(CPEvent)anEvent
{
    [self interpretKeyEvents:[anEvent]];
}


#pragma mark -
#pragma mark KVO Observers

/*! @ignore
*/
- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(id)aContext
{
    if (_latestPageLoaded >= _maxPossiblePage && ![self _shouldLoadNextCategory])
        return;

    var scrollPosition = CGRectGetMaxY([object bounds]);

    if (scrollPosition + NUModuleRESTPageLoadingTrigger >= [tableView frame].size.height)
    {
        CPLog.debug("PAGINATION: Reached trigger for scroll view. Loading next page.");

        // close any deletion in process if we are loading something to avoid incoherency
        [[[NUKit kit] registeredDataViewWithIdentifier:@"popoverConfirmation"] close];

        // do not observe bounds change until we receive the next page
        [self _removeScrollViewObservers];

        [self _loadNextPage];
    }
}


#pragma mark -
#pragma mark Outline View Delegates

/*! @ignore
*/
- (void)outlineViewSelectionDidChange:(CPNotification)aNotification
{
    _selectionDidChanged = YES;
    [[CPRunLoop mainRunLoop] performBlock:function()
    {
        [self _updateCurrentSelection];
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    } argument:nil order:0 modes:[CPDefaultRunLoopMode]];
}

/*! @ignore
*/
- (int)outlineView:(CPOutlineView)anOutlineView heightOfRowByItem:(id)anItem
{
    var dataView = [self _dataViewForObject:anItem];

    if ([dataView respondsToSelector:@selector(computedHeightForObjectValue:)])
        return [dataView computedHeightForObjectValue:anItem];
    else
        return [dataView frameSize].height;
}

/*! @ignore
*/
- (CPView)outlineView:(CPOutlineView)anOutlineView viewForTableColumn:(CPTableColumn)aColumn item:(id)anItem
{
    var dataView = [self _dataViewForObject:anItem],
        key = _dataViewIdentifierPrefix + @"_" + ([anItem isKindOfClass:NURESTObject] ? [anItem RESTName] : [anItem UID]),
        view = [anOutlineView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        view = [dataView duplicate];
        [view setIdentifier:key];
    }

    return view;
}

/*! @ignore
*/
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

/*! @ignore
*/
- (void)outlineView:(CPOutlineView)anOutlineView willDisplayView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn item:(id)anItem
{
    [self willDisplayDataView:aView];
}

/*! @ignore
*/
- (void)outlineView:(CPOutlineView)anOutlineView willRemoveView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn item:(id)anItem
{
    if ([aView respondsToSelector:@selector(setObjectValue:)])
        [aView setObjectValue:nil];
}

/*! @ignore
*/
- (BOOL)outlineView:(CPOutlineView)anOutlineView shouldCollapseItem:(id)anItem
{
    return NO;
}

/*! @ignore
*/
- (BOOL)outlineView:(CPOutlineView)anOutlineView shouldSelectItem:(id)anItem
{
    return ![anItem isKindOfClass:NUCategory];
}

/*! @ignore
*/
- (void)outlineViewDeleteKeyPressed:(CPTableView)aTableView
{
    if ([_currentSelectedObjects count] && ([self isActionPermitted:NUModuleActionDelete]))
        [self openDeleteObjectPopover:aTableView];
}

/*! @ignore
*/
- (CPMenu)outlineView:(CPOutlineView)anOutlineView menuForTableColumn:(CPTableColumn)aColumn item:(is)anItem
{
    return [self _currentContextualMenu];
}


#pragma mark -
#pragma mark Table View Delegates

/*! @ignore
*/
- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
    _selectionDidChanged = YES;
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
        key  = _dataViewIdentifierPrefix + @"_" + ([item isKindOfClass:NURESTObject] ? [item RESTName] : [item UID]),
        view = [aTableView makeViewWithIdentifier:key owner:self];

    if (!view)
    {
        view = [[self _dataViewForObject:item] duplicate];
        [view setIdentifier:key];
    }

    return view;
}

/*! @ignore
*/
- (CPIndexSet)tableView:(CPTableView)aTableView selectionIndexesForProposedSelection:(CPIndexSet)proposedIndexes
{
    return [self _standardShouldSelectRowIndexes:proposedIndexes] ? proposedIndexes : [tableView selectedRowIndexes];
}

/*! @ignore
*/
- (void)tableView:(CPTableView)aTableView willDisplayView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    [self willDisplayDataView:aView];
}

/*! @ignore
*/
- (void)tableView:(CPTableView)aTableView willRemoveView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn row:(int)aRowIndex
{
    if ([aView respondsToSelector:@selector(setObjectValue:)])
        [aView setObjectValue:nil];
}

/*! @ignore
*/
- (void)tableViewDeleteKeyPressed:(CPTableView)aTableView
{
    if ([_currentSelectedObjects count] && ([self isActionPermitted:NUModuleActionDelete]))
        [self openDeleteObjectPopover:aTableView];
}

/*! @ignore
*/
- (CPMenu)tableView:(CPTableView)aTableView menuForTableColumn:(CPTableColumn)aColumn row:(CPInteger)aRow
{
    return [self _currentContextualMenu];
}


#pragma mark -
#pragma mark TabView Delegates

/*! @ignore
*/
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

/*! @ignore
*/
- (void)tabView:(TNTabView)aTabView willSelectTabViewItem:(CPTabViewItem)anItem
{
    var previousModule = [self _subModuleWithIdentifier:[[aTabView selectedTabViewItem] identifier]];
    [previousModule willHide];
    [previousModule setCurrentParent:nil];

    var nextModule = [self _subModuleWithIdentifier:[anItem identifier]];
    if (![anItem view])
        [anItem setView:[nextModule view]];
}

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (void)splitView:(CPSplitView)aSplitView resizeSubviewsWithOldSize:(CGSize)oldSize
{
    [aSplitView adjustSubviews];

    if (aSplitView != splitViewMain)
        return;

    if ([[aSplitView subviews] count] > 1)
        [aSplitView setPosition:[[[aSplitView subviews] firstObject] frameSize].width ofDividerAtIndex:0];
}


#pragma mark -
#pragma mark Popover Delegate

/*! @ignore
*/
- (void)popoverDidClose:(CPPopover)aPopover
{
    if (aPopover != _modulePopover)
        return;

    [self willHide];
}

/*! @ignore
*/
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

/*! @ignore
*/
- (void)windowWillClose:(CPWindow)aWindow
{
    if (aWindow !== [self externalWindow])
        return;

    [self didCloseFromExternalWindow];
}

@end
