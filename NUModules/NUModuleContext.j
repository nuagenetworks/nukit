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
@import <AppKit/CPCheckBox.j>
@import <AppKit/CPOutlineView.j>
@import <AppKit/CPPopover.j>
@import <AppKit/CPProgressIndicator.j>
@import <AppKit/CPTableView.j>
@import <Bambou/NURESTObject.j>
@import <Bambou/NURESTConnection.j>
@import <Bambou/NURESTFetcher.j>
@import <Bambou/NURESTError.j>
@import <TNKit/TNAlert.j>

@import "NUCheckboxStateToBooleanValueTransformer.j"
@import "NUCompoundTransformer.j"
@import "NUDataTransferController.j"
@import "NUSkin.j"
@import "NUUtilities.j"
@import "NUValidation.j"

@global CPApp
@global NUModuleActionEdit
@global NUModuleActionInstantiate

var NUValidationActive = nil,
    NUModuleContextAutoValidation = NO,

    NUModuleContextCommonControlTagsAsFirstResponder = [@"privateIP", @"minAddress", @"MAC", @"virtualIP", @"description", @"value", @"lastName", @"firstName", @"address", @"CIDR", @"name"],

    NUModuleContextDelegate_moduleContext_willManageObject_                         = 1 << 1,
    NUModuleContextDelegate_moduleContext_didManageObject_                          = 1 << 2,

    NUModuleContextDelegate_moduleContext_willSaveObject_                           = 1 << 3,
    NUModuleContextDelegate_moduleContext_didSaveObject_connection_                 = 1 << 4,
    NUModuleContextDelegate_moduleContext_didFailToSaveObject_connection_           = 1 << 5,

    NUModuleContextDelegate_moduleContext_willCreateObject_                         = 1 << 6,
    NUModuleContextDelegate_moduleContext_didCreateObject_connection_               = 1 << 7,
    NUModuleContextDelegate_moduleContext_didFailToCreateObject_connection_         = 1 << 8,

    NUModuleContextDelegate_moduleContext_willUpdateObject_                         = 1 << 9,
    NUModuleContextDelegate_moduleContext_didUpdateObject_connection_               = 1 << 10,
    NUModuleContextDelegate_moduleContext_didFailToUpdateObject_connection_         = 1 << 11,

    NUModuleContextDelegate_moduleContext_willDeleteObject_                         = 1 << 12,
    NUModuleContextDelegate_moduleContext_didDeleteObject_connection_               = 1 << 13,
    NUModuleContextDelegate_moduleContext_didFailToDeleteObject_connection_         = 1 << 14,

    NUModuleContextDelegate_moduleContextShouldEnableSaving_                        = 1 << 15,

    NUModuleContextDelegate_moduleContext_validateObject_attribute_validation_      = 1 << 16,
    NUModuleContextDelegate_moduleContext_didFailValidateObject_validation_         = 1 << 17,

    NUModuleContextDelegate_moduleContext_didUpdateEditedObject_                    = 1 << 18,

    NUModuleContextDelegate_moduleContext_templateForInstantiationOfObject_         = 1 << 19,

    NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectCreate_       = 1 << 20,
    NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectSave_         = 1 << 21,
    NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectDelete_       = 1 << 22,
    NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectInstantiate_  = 1 << 23,

    NUModuleContextDelegate_moduleContext_bindTableView_forProperty_ofObject_       = 1 << 24,
    NUModuleContextDelegate_moduleContext_unbindTableView_forProperty_ofObject_     = 1 << 25,

    NUModuleContextDelegate_moduleContext_didFailWithValidationErrors_              = 1 << 26,
    NUModuleContextDelegate_moduleContext_didClearAllValidationErrors_              = 1 << 27;


computeRelativeRectOfSelectedRow = function(tableView)
{
    var scrollView = [tableView enclosingScrollView],
        rect = [scrollView convertRect:[tableView rectOfRow:[tableView selectedRow]] fromView:tableView];

    if (rect.origin.y > [scrollView frameSize].height)
        rect.origin.y = [scrollView frameSize].height;
    else if (rect.origin.y < 0)
        rect.origin.y = 0;

    rect.origin.y += rect.size.height / 2;
    rect.origin.x += rect.size.width / 2;
    return CGRectMake(rect.origin.x, rect.origin.y, 1, 1);
}

var _isCPArrayControllerKind = function(object, keyPath)
{
    var ret = NO;
    try  { ret = [[object valueForKeyPath:keyPath] isKindOfClass:CPArrayController]; } catch(e) {};
    return ret;
}

/*! NUModuleContext is responsible for CRUD operation on a single object
*/
@implementation NUModuleContext : CPObject
{
    BOOL            _modified                       @accessors(property=modified);
    BOOL            _searchForTagsRecursively       @accessors(getter=searchForTagsRecursively, setter=setSearchForTagsRecursively:);
    BOOL            _usesAutoValidatation           @accessors(getter=isUsingAutoValidation, setter=setUsesAutoValidation:);
    BOOL            _validationUsesAlert            @accessors(getter=isValidationUsesAlert, setter=setValidationUsesAlert:);
    Class           _managedObjectClass             @accessors(property=managedObjectClass);
    CPArray         _additionalEditionViews         @accessors(property=additionalEditionViews);
    CPArray         _selectedObjects                @accessors(property=selectedObjects);
    CPButton        _buttonSave                     @accessors(property=buttonSave);
    CPPopover       _popover                        @accessors(property=popover);
    CPString        _fetcherKeyPath                 @accessors(property=fetcherKeyPath);
    CPString        _identifier                     @accessors(property=identifier);
    CPString        _buttonCreateLabel              @accessors(property=buttonCreateLabel);
    CPString        _buttonEditLabel                @accessors(property=buttonEditLabel);
    CPString        _buttonInstantiateLabel         @accessors(property=buttonInstantiateLabel);
    CPString        _name                           @accessors(property=name);
    CPView          _editionView                    @accessors(property=editionView);
    id              _delegate                       @accessors(property=delegate);
    id              _preferedPopoverEdge            @accessors(property=preferedPopoverEdge);
    NURESTObject    _editedObject                   @accessors(property=editedObject);
    NURESTObject    _parentObject                   @accessors(property=parentObject);
    NUValidation    _currentValidation              @accessors(getter=currentValidation);
    SEL             _createAction                   @accessors(property=createAction);
    SEL             _deleteAction                   @accessors(property=deleteAction);
    SEL             _instantiateAction              @accessors(property=instantiateAction);
    SEL             _updateAction                   @accessors(property=updateAction);

    BOOL            _bindingsDirty;
    CGSize          _basePopoverSize;
    CPDictionary    _bindedControlsCache;
    CPString        _currentTransactionID;
    CPTextField     _fieldTitle;
    CPView          _viewSpinner;
    id              _initialFirstResponder;
    int             _implementedDelegateMethods;
    NURESTObject    _editedObjectPristine;
}


#pragma mark -
#pragma mark Class Methods

+ (void)initialize
{
    if (window.location.search && window.location.search.indexOf("disablevalidation") != -1)
        NUValidationActive = NO;
    else
        NUValidationActive = YES;
}

/*! Sets the default responder tags.
    Give a revert array.
*/
+ (void)setDefaultFirstResponderTags:(CPArray)anArray
{
    NUModuleContextCommonControlTagsAsFirstResponder = anArray;
}

/*! Returns the list of first responder tags.
*/
+ (CPArray)defaultFirstResponderTags
{
    return NUModuleContextCommonControlTagsAsFirstResponder;
}


#pragma mark -
#pragma mark Initialization

/*! Initializes a new context.
*/
- (NUModuleContext)initWithName:(CPString)aName identifier:(CPString)anIdentifier
{
    if (self = [super init])
    {
        _identifier                     = anIdentifier;
        _name                           = aName;
        _usesAutoValidatation           = YES;
        _bindingsDirty                  = YES;
        _searchForTagsRecursively       = NO;
        _validationUsesAlert            = NO;
        _preferedPopoverEdge            = CPMaxYEdge;
        _bindedControlsCache            = @{};
        _additionalEditionViews         = [];
        _buttonCreateLabel              = @"Create";
        _buttonEditLabel                = @"Update";
        _buttonInstantiateLabel         = @"Instantiate";
        _createAction                   = @selector(createChildObject:andCallSelector:ofObject:);
        _instantiateAction              = @selector(instantiateChildObject:fromTemplate:andCallSelector:ofObject:);
        _updateAction                   = @selector(saveAndCallSelector:ofObject:);
        _deleteAction                   = @selector(deleteAndCallSelector:ofObject:);
        _viewSpinner                    = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];

        [_viewSpinner setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
    }

    return self;
}


#pragma mark -
#pragma mark Custom Getters and Setters

/*! Sets the popover to use
*/
- (void)setPopover:(CPPopover)aPopover
{
    if (_popover == aPopover)
        return;

    _popover = aPopover;

    [self _resetPopoverCache];

    [_popover setDelegate:self];

    if (!_editionView)
        [self setEditionView:[[_popover contentViewController] view]];

    _basePopoverSize = [_editionView frameSize];
}

/*! Set the main edition view.
    EditionView will be used to look for controls with tags for autobinding.
*/
- (void)setEditionView:(CPView)aView
{
    if (aView == _editionView)
        return;

    _editionView = aView;

    var buttonHelp = [self _controlForProperty:@"button-help"];

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

    if (!_fieldTitle)
        _fieldTitle = [self _controlForProperty:@"title"];

    if (_fieldTitle)
        [_fieldTitle setTextColor:NUSkinColorBlueDark];

    if (!_buttonSave)
        [self setButtonSave:[self _controlForProperty:@"save"]];
}

/*! Sets the current edited object.
    A copy will be created and used when user is modifying it.
    A pristine copy will be kept to perform some comparison and validation
*/
- (void)setEditedObject:(NURESTObject)anObject
{
    if (anObject == _editedObject)
        return;

    [self _removeObservers];
    [self _unbindControls];

    _editedObject         = anObject ? [anObject duplicate] : nil;
    _editedObjectPristine = anObject ? [anObject duplicate] : nil;
    _currentValidation    = [NUValidation new];

    [self showLoading:NO];
    [self setModified:NO];
    [self setSavingEnabled:NO];

    [self _addObservers];
    [self _bindControls];
}

/*! Sets the button that will be used to save the object
*/
- (void)setButtonSave:(CPButton)aButton
{
    if (_buttonSave == aButton)
        return;

    [self willChangeValueForKey:@"buttonSave"];
    _buttonSave = aButton;
    [self didChangeValueForKey:@"buttonSave"];

    if ([_viewSpinner superview])
        [_viewSpinner removeFromSuperview];

    if (!_buttonSave)
        return;

    var frame = CGRectMakeCopy([aButton frame]),
        size = [_viewSpinner frameSize];

    frame.origin.x = frame.origin.x - [_viewSpinner frameSize].width - 5;
    frame.origin.y = frame.origin.y + (frame.size.height / 2 - size.height / 2) - 1;
    frame.size = size;

    [_viewSpinner setFrame:frame];
    [[_buttonSave superview] addSubview:_viewSpinner];
}

/*! Set if saving is enabled or not. If disabled,
    the save button will also be disabled.
*/
- (void)setSavingEnabled:(BOOL)shouldEnable
{
    if ((!NUValidationActive || shouldEnable) && [self _sendDelegateShouldEnableSaving])
    {
        [[_editionView window] setDefaultButton:_buttonSave];
        [_buttonSave setEnabled:YES];
    }
    else
    {
        [[_editionView window] setDefaultButton:nil];
        [_buttonSave setEnabled:NO];
    }
}

/*! Update the current edited object with a new version of itself.
    This is used to update the field in case of push notification.
*/
- (void)updateEditedObjectWithNewVersion:(NURESTObject)anObject
{
    var JSONData = [anObject objectToJSON];

    // always do this first for validation to work
    [_editedObjectPristine objectFromJSON:JSONData];

    // then update the edited object
    [_editedObject objectFromJSON:JSONData];

    // then call the delegate
    [self _sendDelegateUpdateEditedObject];
}

/*! Shows the loading spinner.
*/
- (void)showLoading:(BOOL)shouldShow
{
    if ([_viewSpinner superview] && shouldShow)
        [[NUDataTransferController defaultDataTransferController] showFetchingViewOnView:_viewSpinner];
    else
        [[NUDataTransferController defaultDataTransferController] hideFetchingViewFromView:_viewSpinner];
}


#pragma mark -
#pragma mark Property Binding Management

/*! @ignore
*/
- (void)_resetPopoverCache
{
    _editionView           = nil;
    _buttonSave            = nil;
    _fieldTitle            = nil;
    _initialFirstResponder = nil;

    [_popover setDelegate:nil];
    _bindedControlsCache = @{};
}

/*! @ignore
*/
- (CPControl)_controlForProperty:(CPString)aName
{
    if (![_bindedControlsCache containsKey:aName])
    {
        var control = [_editionView subviewWithTag:aName recursive:_searchForTagsRecursively];

        if (!control)
            for (var i = [_additionalEditionViews count] - 1; i >= 0; i--)
                if (control = [_additionalEditionViews[i] subviewWithTag:aName recursive:_searchForTagsRecursively])
                    break;

        if (control)
        {
            [_bindedControlsCache setObject:control forKey:aName];

            if ([control isKindOfClass:CPTextField] && ![control isEditable] && [control lineBreakMode] == CPLineBreakByClipping)
                [control setLineBreakMode:CPLineBreakByTruncatingTail];
        }
    }

    return [_bindedControlsCache objectForKey:aName];
}
/*! @ignore
*/
- (void)_bindControls
{
    if (!_bindingsDirty || !_editedObject)
        return;

    // we'll need it anyway so load it if needed
    if (_popover)
        [[_popover contentViewController] view];

    var attributes = [_editedObject bindableAttributes];

    for (var i = [attributes count] - 1; i >= 0; i--)
    {
        var keyPath = attributes[i],
            control = [self _controlForProperty:keyPath],
            value   = [_editedObject valueForKeyPath:keyPath];

        if (control)
        {
            _cucappID(control, keyPath);

            if ([control isKindOfClass:CPPopUpButton])
            {
                [control bind:CPSelectedTagBinding toObject:_editedObject withKeyPath:keyPath options:nil];
            }
            else if ([control isKindOfClass:CPCheckBox])
            {
                var opts = @{CPValueTransformerNameBindingOption: NUCheckboxStateToBooleanValueTransformerName};
                [control bind:CPValueBinding toObject:_editedObject withKeyPath:keyPath options:opts];
            }
            else if ([control isKindOfClass:CPProgressIndicator])
            {
                [control bind:CPValueBinding toObject:_editedObject withKeyPath:keyPath options:nil];
            }
            else if ([control isKindOfClass:CPTableView])
            {
                [self _sendDelegateBindTableView:control forProperty:keyPath];

                var addButton = [self _controlForProperty:keyPath + @"_add:"];
                if (addButton)
                {
                    var image    = [NUSkinImageButtonPlus duplicate],
                        altImage = [NUSkinImageButtonPlusAlt duplicate],
                        size     = [addButton frameSize];

                    [image setSize:size];
                    [altImage setSize:size];

                    [addButton setTarget:value];
                    [addButton setAction:@selector(add:)];
                    [addButton setImage:image];
                    [addButton setAlternateImage:altImage];
                    [addButton setButtonType:CPMomentaryChangeButton];
                }

                var deleteButton = [self _controlForProperty:keyPath + @"_remove:"];
                if (deleteButton)
                {
                    var image    = [NUSkinImageButtonMinus duplicate],
                        altImage = [NUSkinImageButtonMinusAlt duplicate],
                        size     = [addButton frameSize];

                    [image setSize:size];
                    [altImage setSize:size];

                    [deleteButton setTarget:value];
                    [deleteButton setAction:@selector(remove:)];
                    [deleteButton setImage:image];
                    [deleteButton setAlternateImage:altImage];
                    [deleteButton setButtonType:CPMomentaryChangeButton];
                }
            }
            else if ([control isKindOfClass:CPImageView])
            {
                var opts = @{},
                    declaredTransformerName = [control valueTransformerName];

                if (declaredTransformerName)
                    [opts setObject:declaredTransformerName forKey:CPValueTransformerNameBindingOption];

                [control bind:CPValueBinding toObject:_editedObject withKeyPath:keyPath options:opts];
            }
            else if ([control isKindOfClass:CPTextField])
            {
                var opts = @{CPContinuouslyUpdatesValueBindingOption: YES},
                    declaredTransformerName = [control valueTransformerName];

                if (declaredTransformerName)
                {
                    if (declaredTransformerName.split(",").length > 1)
                    {
                        var compoundTransformerName = "CompoundTransformer-" + declaredTransformerName,
                            eventualTransformer = [CPValueTransformer valueTransformerForName:compoundTransformerName];

                        if (!eventualTransformer)
                        {
                            eventualTransformer = [NUCompoundTransformer new];
                            [eventualTransformer setTransformers:declaredTransformerName.split(",")];

                            [CPValueTransformer setValueTransformer:eventualTransformer forName:compoundTransformerName];
                        }

                        declaredTransformerName = compoundTransformerName;
                    }

                    [opts setObject:declaredTransformerName forKey:CPValueTransformerNameBindingOption];
                }

                if ([control placeholderString])
                    [opts setObject:[control placeholderString] forKey:CPNullPlaceholderBindingOption];

                if (![control isEditable] && [control lineBreakMode] == CPLineBreakByClipping)
                    [control setLineBreakMode:CPLineBreakByTruncatingTail];

                [control setSelectable:YES];

                if (NUValidationActive)
                    [control setDelegate:self];

                [control bind:CPValueBinding toObject:_editedObject withKeyPath:keyPath options:opts];
            }
            else
                [CPException raise:CPInternalInconsistencyException reason:"NUModuleContext doesn't support binding for control class: " + [control class]];
        }
    }

    _bindingsDirty = NO;
}

/*! @ignore
*/
- (void)_unbindControls
{
    if (!_editedObject)
        return;

    var attributes = [_editedObject bindableAttributes];

    for (var i = [attributes count] - 1; i >= 0; i--)
    {
        var keyPath = attributes[i],
            control = [self _controlForProperty:keyPath],
            value   = [_editedObject valueForKeyPath:keyPath];

        if ([control isKindOfClass:CPPopUpButton])
        {
            [control unbind:CPSelectedTagBinding];
        }
        else if ([control isKindOfClass:CPTableView])
        {
            [self _sendDelegateUnbindTableView:control forProperty:keyPath];

            var addButton = [self _controlForProperty:keyPath + @"_add:"];
            if (addButton)
            {
                [addButton setTarget:nil];
                [addButton setAction:nil];
            }

            var deleteButton = [self _controlForProperty:keyPath + @"_remove:"];
            if (deleteButton)
            {
                [deleteButton setTarget:nil];
                [deleteButton setAction:nil];
            }
        }
        else
            [control unbind:CPValueBinding];

        if (NUValidationActive && [control isKindOfClass:CPTextField])
            [control setDelegate:nil];
    }

    _bindingsDirty = YES;
}

/*! @ignore
*/
- (void)_setCurrentInitialFirstResponder
{
    if (_initialFirstResponder && _popover)
    {
        [_popover makeFirstResponder:_initialFirstResponder];
        return;
    }

    for (var i = [NUModuleContextCommonControlTagsAsFirstResponder count] - 1; i >= 0; i--)
    {
        var tag = NUModuleContextCommonControlTagsAsFirstResponder[i],
            control = [self _controlForProperty:tag];

        if (control)
        {
            _initialFirstResponder = control;
            break;
        }
    }

    [_popover makeFirstResponder:_initialFirstResponder];
}

/*! Returns the list of all bound controls.
*/
- (CPArray)boundControls
{
    return [[_bindedControlsCache allValues] copy];
}

/*! Enable or disable all the bound controls.
*/
- (void)setBoundControlsEnabled:(BOOL)shouldEnable
{
    for (var i = [[_bindedControlsCache allValues] count] - 1; i >= 0; i--)
        [[_bindedControlsCache allValues][i] setEnabled:shouldEnable];
}


#pragma mark -
#pragma mark Delegate Management

/*! Set the delegate.

    - (void)moduleContext:(NUModuleContext)aContext willManageObject:(NURESTObject)anObject
    - (void)moduleContext:(NUModuleContext)aContext didManageObject:(NURESTObject)anObject

    - (void)moduleContext:(NUModuleContext)aContext willSaveObject:(NURESTObject)anObject
    - (void)moduleContext:(NUModuleContext)aContext didSaveObject:(NURESTObject)anObject connection:(NURESTConnection)aConnection
    - (void)moduleContext:(NUModuleContext)aContext didFailToSaveObject:(NURESTObject)anObject connection:(NURESTConnection)aConnection

    - (void)moduleContext:(NUModuleContext)aContext willCreateObject:(NURESTObject)anObject
    - (void)moduleContext:(NUModuleContext)aContext didCreateObject:(NURESTObject)anObject connection:(NURESTConnection)aConnection
    - (void)moduleContext:(NUModuleContext)aContext didFailToCreateObject:(NURESTObject)anObject connection:(NURESTConnection)aConnection

    - (void)moduleContext:(NUModuleContext)aContext willUpdateObject:(NURESTObject)anObject
    - (void)moduleContext:(NUModuleContext)aContext didUpdateObject:(NURESTObject)anObject connection:(NURESTConnection)aConnection
    - (void)moduleContext:(NUModuleContext)aContext didFailToUpdateObject:(NURESTObject)anObject connection:(NURESTConnection)aConnection

    - (void)moduleContext:(NUModuleContext)aContext willDeleteObject:(NURESTObject)anObject
    - (void)moduleContext:(NUModuleContext)aContext didDeleteObject:(NURESTObject)anObject connection:(NURESTConnection)aConnection
    - (void)moduleContext:(NUModuleContext)aContext didFailToDeleteObject:(NURESTObject)anObject connection:(NURESTConnection)aConnection

    - (CPArray)moduleContext:(NUModuleContext)aContext additionalArgumentsForObjectCreate:(NURESTObject)anObject
    - (CPArray)moduleContext:(NUModuleContext)aContext additionalArgumentsForObjectSave:(NURESTObject)anObject
    - (CPArray)moduleContext:(NUModuleContext)aContext additionalArgumentsForObjectDelete:(NURESTObject)anObject
    - (CPArray)moduleContext:(NUModuleContext)aContext additionalArgumentsForObjectInstantiate:(NURESTObject)anObject

    - (void)moduleContext:(NUModuleContext)aContext validateObject:(NURESTObject)anObject attribute:(CPString)anAttribute validation:(NUValidation)aValidation
    - (void)moduleContext:(NUModuleContext)aContext didFailValidateObject:(NURESTObject)anObject validation:(NUValidation)aValidation
    - (void)didFailWithValidationErrors:(NUValidation)aValidation
    - (void)moduleContextDidClearAllValidationErrors:(NUValidation)aValidation

    - (void)moduleContextShouldEnableSaving:(NUModuleContext)aContext

    - (void)moduleContext:(NUModuleContext)aContext didUpdateEditedObject:(NURESTObject)anObject

    - (NURESTObject)moduleContext:(NUModuleContext)aContext templateForInstantiationOfObject:(NURESTObject)anObject

    - (void)moduleContext:(NUModuleContext)aContext bindTableView:(CPTableView)aTableView forProperty:(CPString)aPropertu ofObject:(NURESTObject)anObject
    - (void)moduleContext:(NUModuleContext)aContext unbindTableView:(CPTableView)aTableView forProperty:(CPString)aPropertu ofObject:(NURESTObject)anObject
    - (void)moduleContext:(NUModuleContext)aContext additionalArgumentsForObjectInstantiate:(NURESTObject)anObject
*/
- (void)setDelegate:(id)aDelegate
{
    if (aDelegate == _delegate)
        return;

    _delegate = aDelegate;
    _implementedDelegateMethods = 0;

    if ([_delegate respondsToSelector:@selector(moduleContext:willSaveObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_willSaveObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didSaveObject:connection:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didSaveObject_connection_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didFailToSaveObject:connection:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didFailToSaveObject_connection_;

    if ([_delegate respondsToSelector:@selector(moduleContext:willCreateObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_willCreateObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didCreateObject:connection:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didCreateObject_connection_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didFailToCreateObject:connection:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didFailToCreateObject_connection_;

    if ([_delegate respondsToSelector:@selector(moduleContext:willUpdateObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_willUpdateObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didUpdateObject:connection:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didUpdateObject_connection_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didFailToUpdateObject:connection:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didFailToUpdateObject_connection_;

    if ([_delegate respondsToSelector:@selector(moduleContext:willDeleteObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_willDeleteObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didDeleteObject:connection:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didDeleteObject_connection_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didFailToDeleteObject:connection:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didFailToDeleteObject_connection_;

    if ([_delegate respondsToSelector:@selector(moduleContext:validateObject:attribute:validation:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_validateObject_attribute_validation_;

    if ([_delegate respondsToSelector:@selector(moduleContextShouldEnableSaving:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContextShouldEnableSaving_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didUpdateEditedObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didUpdateEditedObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:willManageObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_willManageObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didManageObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didManageObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:templateForInstantiationOfObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_templateForInstantiationOfObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didFailValidateObject:validation:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didFailValidateObject_validation_;

    if ([_delegate respondsToSelector:@selector(moduleContext:additionalArgumentsForObjectCreate:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectCreate_;

    if ([_delegate respondsToSelector:@selector(moduleContext:additionalArgumentsForObjectSave:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectSave_;

    if ([_delegate respondsToSelector:@selector(moduleContext:additionalArgumentsForObjectDelete:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectDelete_;

    if ([_delegate respondsToSelector:@selector(moduleContext:additionalArgumentsForObjectInstantiate:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectInstantiate_;

    if ([_delegate respondsToSelector:@selector(moduleContext:bindTableView:forProperty:ofObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_bindTableView_forProperty_ofObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:unbindTableView:forProperty:ofObject:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_unbindTableView_forProperty_ofObject_;

    if ([_delegate respondsToSelector:@selector(moduleContext:didFailWithValidationErrors:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didFailWithValidationErrors_;

    if ([_delegate respondsToSelector:@selector(moduleContextDidClearAllValidationErrors:)])
        _implementedDelegateMethods |= NUModuleContextDelegate_moduleContext_didClearAllValidationErrors_;
}

/*! @ignore
*/
- (void)_sendDelegateWillSaveObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willSaveObject_)
        [_delegate moduleContext:self willSaveObject:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateDidSaveObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didSaveObject_connection_)
        [_delegate moduleContext:self didSaveObject:anObject connection:aConnection];
}

/*! @ignore
*/
- (void)_sendDelegateDidFailToSaveObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailToSaveObject_connection_)
        [_delegate moduleContext:self didFailToSaveObject:anObject connection:aConnection];
}

/*! @ignore
*/
- (void)_sendDelegateWillCreateObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willCreateObject_)
        [_delegate moduleContext:self willCreateObject:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateDidCreateObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didCreateObject_connection_)
        [_delegate moduleContext:self didCreateObject:anObject connection:aConnection];
}

/*! @ignore
*/
- (void)_sendDelegateDidFailToCreateObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailToCreateObject_connection_)
        [_delegate moduleContext:self didFailToCreateObject:anObject connection:aConnection];
}

/*! @ignore
*/
- (void)_sendDelegateWillUpdateObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willUpdateObject_)
        [_delegate moduleContext:self willUpdateObject:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateDidUpdateObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didUpdateObject_connection_)
        [_delegate moduleContext:self didUpdateObject:anObject connection:aConnection];
}

/*! @ignore
*/
- (void)_sendDelegateDidFailToUpdateObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailToUpdateObject_connection_)
        [_delegate moduleContext:self didFailToUpdateObject:anObject connection:aConnection];
}

/*! @ignore
*/
- (void)_sendDelegateWillDeleteObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willDeleteObject_)
        [_delegate moduleContext:self willDeleteObject:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateDidDeleteObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didDeleteObject_connection_)
        [_delegate moduleContext:self didDeleteObject:anObject connection:aConnection];
}

/*! @ignore
*/
- (void)_sendDelegateDidFailToDeleteObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailToDeleteObject_connection_)
        [_delegate moduleContext:self didFailToDeleteObject:anObject connection:aConnection];
}

/*! @ignore
*/
- (void)_sendDelegateValidateObjectWithAttribute:(CPString)anAttribute
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_validateObject_attribute_validation_)
        [_delegate moduleContext:self validateObject:_editedObject attribute:anAttribute validation:_currentValidation];
}

/*! @ignore
*/
- (BOOL)_sendDelegateShouldEnableSaving
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContextShouldEnableSaving_)
        return [_delegate moduleContextShouldEnableSaving:self];

    return YES;
}

/*! @ignore
*/
- (void)_sendDelegateUpdateEditedObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didUpdateEditedObject_)
        [_delegate moduleContext:self didUpdateEditedObject:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateWillManageObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willManageObject_)
        [_delegate moduleContext:self willManageObject:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateDidManageObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didManageObject_)
        [_delegate moduleContext:self didManageObject:_editedObject];
}

/*! @ignore
*/
- (NURESTObject)_sendDelegateTemplateForInstantiationOfObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_templateForInstantiationOfObject_)
        return [_delegate moduleContext:self templateForInstantiationOfObject:_editedObject];

    return nil;
}

/*! @ignore
*/
- (void)_sendDelegateDidServerValidationOfObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailValidateObject_validation_)
        [_delegate moduleContext:self didFailValidateObject:_editedObject validation:_currentValidation];
}

/*! @ignore
*/
- (void)_sendDelegateAdditionalArgumentsForObjectCreate
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectCreate_)
        return [_delegate moduleContext:self additionalArgumentsForObjectCreate:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateAdditionalArgumentsForObjectSave
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectSave_)
        return [_delegate moduleContext:self additionalArgumentsForObjectSave:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateAdditionalArgumentsForObjectDelete
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectDelete_)
        return [_delegate moduleContext:self additionalArgumentsForObjectDelete:_editedObject];
}

- (void)_sendDelegateAdditionalArgumentsForObjectInstantiate
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectInstantiate_)
        return [_delegate moduleContext:self additionalArgumentsForObjectInstantiate:_editedObject];
}

/*! @ignore
*/
- (void)_sendDelegateBindTableView:(CPTableView)aTableView forProperty:(CPString)aPropertyName
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_bindTableView_forProperty_ofObject_)
        [_delegate moduleContext:self bindTableView:aTableView forProperty:aPropertyName ofObject:_editedObject];
    else
        [[[aTableView tableColumns] firstObject] bind:CPValueBinding toObject:_editedObject withKeyPath:aPropertyName + @".arrangedObjects.value" options:nil];
}

/*! @ignore
*/
- (void)_sendDelegateUnbindTableView:(CPTableView)aTableView forProperty:(CPString)aPropertyName
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_unbindTableView_forProperty_ofObject_)
        [_delegate moduleContext:self unbindTableView:aTableView forProperty:aPropertyName ofObject:_editedObject];
    else
        [[[aTableView tableColumns] firstObject] unbind:CPValueBinding];

    // the 2 following lines is a workaround for a bug in the binding of the CPTableColumn bindings
    [aTableView unbind:@"content"];
    [aTableView reloadData];
}

/*! @ignore
*/
- (void)_sendDelegateDidFailWithValidationErrors:(NUValidation)aValidation
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailWithValidationErrors_)
        [_delegate moduleContext:self didFailWithValidationErrors:aValidation];
}

/*! @ignore
*/
- (void)_sendDelegateDidClearAllValidationErrors
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didClearAllValidationErrors_)
        [_delegate moduleContextDidClearAllValidationErrors:self];
}


#pragma mark -
#pragma mark Popover Management

/*! Open the popover for the given action
*/
- (void)openPopoverForAction:(int)anAction sender:(id)aSender
{
    if (!_popover)
        return;

    switch (anAction)
    {
        case NUModuleActionEdit:
            [_fieldTitle setStringValue:@"Edit " + _name];
            [_buttonSave setTitle:_buttonEditLabel];
            [_buttonSave setTarget:self];
            [_buttonSave setAction:@selector(updateEditedObject:)];
            break;

        case NUModuleActionInstantiate:
            [_fieldTitle setStringValue:@"Instantiate " + _name];
            [_buttonSave setTitle:_buttonInstantiateLabel];
            [_buttonSave setTarget:self];
            [_buttonSave setAction:@selector(instantiateEditedObject:)];
            break;

        default:
            [_fieldTitle setStringValue:@"New " + _name];
            [_buttonSave setTitle:_buttonCreateLabel];
            [_buttonSave setTarget:self];
            [_buttonSave setAction:@selector(createEditedObject:)];
            break;
    }

    var relativeRect;
    if ([aSender isKindOfClass:CPTableView])
    {
        relativeRect = computeRelativeRectOfSelectedRow(aSender);
        aSender = [aSender enclosingScrollView];
    }

    if ([_popover delegate] != self)
    {
        var oldPopover = _popover;
        [self setPopover:nil];
        [self setPopover:oldPopover];
    }

    [_popover showRelativeToRect:relativeRect ofView:aSender preferredEdge:_preferedPopoverEdge];
}


#pragma mark -
#pragma mark Validation System

/*! @ignore
*/
- (CPArray)_allValidationFields
{
    var fields = [_editionView subviewsWithTagLike:"validation_" recursive:_searchForTagsRecursively];

    for (var i = [_additionalEditionViews count] - 1; i >= 0; i--)
    {
        var additionalView = _additionalEditionViews[i],
            additionalFields = [additionalView subviewsWithTagLike:"validation_" recursive:_searchForTagsRecursively];

        if ([additionalFields count])
            [fields addObjectsFromArray:additionalFields];
    }

    return fields;
}

/*! @ignore
*/
- (void)_makeRelatedFieldFirstResponderAccordingToCurrentValidation
{
    var property    = [[[_currentValidation errors] allKeys] firstObject],
        control     = [self _controlForProperty:property];

    if (!control && (property == @"address" || property == @"netmask"))
        control = [self _controlForProperty:@"CIDR"];

    if (_popover)
        [_popover makeFirstResponder:control];
    else
        [[control window] makeFirstResponder:control];
}

/*! @ignore
*/
- (BOOL)_performServerValidation:(NURESTConnection)aConnection
{
    var ret = YES;
    switch ([aConnection responseCode])
    {
        case NURESTConnectionResponseCodeConflict:
            if (_validationUsesAlert) // in this case, we simply show push a NURESTError
            {
                var responseObject = [[aConnection responseData] JSONObject],
                    errorName = responseObject.errors[0].descriptions[0].title,
                    errorDescription = responseObject.errors[0].descriptions[0].description;

                [NURESTError postRESTErrorWithName:errorName description:errorDescription connection:aConnection];
                return NO;
            }

            var serverErrors = [[aConnection responseData] JSONObject].errors;
            [_currentValidation flush];

            for (var i = [serverErrors count] - 1; i >= 0; i--)
            {
                var error            = serverErrors[i],
                    propertyName     = [_editedObject localKeyPathForRESTKeyPath:error.property],
                    errorDescription = error.descriptions[0].description,
                    errorTitle       = error.descriptions[0].title;

                if (propertyName == @"" || !propertyName)
                    propertyName = @"serverError";

                [_currentValidation setErrorTitle:errorTitle description:errorDescription forProperty:propertyName];
                ret = NO;
            }
            [self _updateValidationFields];

            [self _makeRelatedFieldFirstResponderAccordingToCurrentValidation];
            [self _sendDelegateDidServerValidationOfObject];

            // Now we remove the server validation from the validation in order to allow user
            // to try again.
            [_currentValidation flush];
            break;

        default:
            if ([NURESTConnection handleResponseForConnection:aConnection postErrorMessage:YES])
                [_popover close];
            else
                [self updateEditedObjectWithNewVersion:_editedObjectPristine];
    }

    return ret;
}

/*! @ignore
*/
- (BOOL)_performClientValidation
{
    if (!NUValidationActive)
        return YES;

    [self _sendDelegateValidateObjectWithAttribute:nil];

    if (![_currentValidation success])
    {
        [self _updateValidationFields];

        [self _makeRelatedFieldFirstResponderAccordingToCurrentValidation];

        return NO;
    }

    return YES;
}

/*! @ignore
*/
- (void)_updateValidationFields
{
    [self clearAllValidationFields];

    var errors = [[_currentValidation errors] allKeys];

    for (var i = [errors count] - 1; i >= 0; i--)
    {
        var propertyName = errors[i],
            title = [[_currentValidation errors] objectForKey:propertyName],
            description = [[_currentValidation descriptions] objectForKey:propertyName],
            labelView = [self _controlForProperty:@"validation_" + propertyName],
            fieldView = [self _controlForProperty:propertyName];

        if (!labelView && [[@"address", @"netmask"] containsObject:propertyName])
            labelView = [self _controlForProperty:@"validation_CIDR"];

        if (!labelView)
            labelView = [self _controlForProperty:@"validation_serverError"];

        if (labelView)
        {
            [labelView setStringValue:description];
            [labelView setToolTip:title];
        }

        // if we don't have a field view and we are checking for "address" or "netmask" then
        // look for a CIDR field. this is kind of dirty, I know but that's it.
        if (!fieldView && [[@"address", @"netmask"] containsObject:propertyName])
            fieldView = [self _controlForProperty:@"CIDR"];

        if (fieldView && [fieldView isKindOfClass:CPTextField])
        {
            var toolTip = title + (description ?  @"\n" + description : @"");
            [fieldView setInvalid:YES reason:toolTip];
        }
    }

    [self _sendDelegateDidFailWithValidationErrors:_currentValidation];
}

/*! Clears all validation fields if any.
*/
- (void)clearAllValidationFields
{
    var matchingSubviews = [self _allValidationFields];

    for (var i = [matchingSubviews count] - 1; i >= 0; i--)
        [matchingSubviews[i] setStringValue:@""];

    var attributes = [_editedObject bindableAttributes];

    for (var i = [attributes count] - 1; i >= 0; i--)
    {
        var relatedField = [self _controlForProperty:attributes[i]];

        if (relatedField && [relatedField isKindOfClass:CPTextField])
            [relatedField setInvalid:NO reason:nil];
    }

    [self _sendDelegateDidClearAllValidationErrors];
}


#pragma mark -
#pragma mark Modification Management

/*! @ignore
*/
- (void)_addObservers
{
    if (!_editedObject)
        return;

    var properties = [_editedObject bindableAttributes];

    for (var i = [properties count] - 1; i >= 0; i--)
    {
        var propertyName = properties[i];

        if (_isCPArrayControllerKind(_editedObject, propertyName))
        {
            [_editedObject addObserver:self forKeyPath:propertyName + @".arrangedObjects" options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
            [_editedObject addObserver:self forKeyPath:propertyName + @".arrangedObjects.value" options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
        }
        else
            [_editedObject addObserver:self forKeyPath:propertyName options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
    }

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didReceiveRESTConfirmationCancelNotification:)
                                                 name:NURESTConfirmationCancelNotification
                                               object:nil];
}

/*! @ignore
*/
- (void)_removeObservers
{
    if (!_editedObject)
        return;

    var properties = [_editedObject bindableAttributes];

    for (var i = [properties count] - 1; i >= 0; i--)
    {
        var propertyName = properties[i];

        if (_isCPArrayControllerKind(_editedObject, propertyName))
        {
            [_editedObject removeObserver:self forKeyPath:propertyName + @".arrangedObjects"];
            [_editedObject removeObserver:self forKeyPath:propertyName + @".arrangedObjects.value"];
        }
        else
            [_editedObject removeObserver:self forKeyPath:propertyName];
    }

    [[CPNotificationCenter defaultCenter] removeObserver:self
                                                    name:NURESTConfirmationCancelNotification
                                                  object:nil];

}

/*! @ignore
*/
- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    var oldValue = [change objectForKey:CPKeyValueChangeOldKey],
        newValue = [change objectForKey:CPKeyValueChangeNewKey];

    if (newValue == oldValue && !_isCPArrayControllerKind(object, keyPath))
        return;

    [self _sendDelegateValidateObjectWithAttribute:keyPath];
    [self _updateValidationFields];

    [self setModified:![_editedObjectPristine isRESTEqual:_editedObject]];
    [self setSavingEnabled:_modified && [_currentValidation success]];
}

/*! @ignore
*/
- (void)_didReceiveRESTConfirmationCancelNotification:(CPNotification)aNotification
{
    if ([[[aNotification object] connection] transactionID] == _currentTransactionID)
    {
        [self setModified:YES];
        [self setSavingEnabled:YES];
        [self showLoading:NO];
    }
}

#pragma mark -
#pragma mark REST Management

/*! @ignore
*/
- (void)_invokeRESTActionWithArguments:(CPArray)someArguments additionalArguments:(CPArray)someAdditionalArguments
{
    someArguments = someAdditionalArguments ? [someArguments arrayByAddingObjectsFromArray:someAdditionalArguments] : someArguments;

    var invocation = [CPInvocation invocationWithMethodSignature:@"RESTInvocation"];
    [invocation setArguments:someArguments];
    [invocation invoke];

    _currentTransactionID = [invocation returnValue];
}

/*! Creates the given RESTObject
*/
- (void)createRESTObject:(NURESTObject)anObject
{
    [self _sendDelegateWillSaveObject];
    [self _sendDelegateWillCreateObject];

    [self setSavingEnabled:NO];
    [self showLoading:YES];

    [self _invokeRESTActionWithArguments:[_parentObject, _createAction, anObject, @selector(_didParent:createChildObject:connection:), self]
                     additionalArguments:[self _sendDelegateAdditionalArgumentsForObjectCreate]];
}

/*! @ignore
*/
- (void)_didParent:(NURESTObject)aParentObject createChildObject:(NURESTObject)aChildObject connection:(NURESTConnection)aConnection
{
    [self showLoading:NO];

    if (![self _performServerValidation:aConnection])
    {
        [self _sendDelegateDidFailToSaveObject:aChildObject connection:aConnection];
        [self _sendDelegateDidFailToCreateObject:aChildObject connection:aConnection];
        return;
    }

    [self setModified:NO];
    [self setSavingEnabled:NO];

    [aChildObject setParentObject:aParentObject];

    [self _sendDelegateDidSaveObject:aChildObject connection:aConnection];
    [self _sendDelegateDidCreateObject:aChildObject connection:aConnection];
}

/*! Updates the given RESTObject
*/
- (void)updateRESTObject:(NURESTObject)anObject
{
    [self _sendDelegateWillSaveObject];
    [self _sendDelegateWillUpdateObject];

    [self setSavingEnabled:NO];
    [self showLoading:YES];

    [self _invokeRESTActionWithArguments:[anObject, _updateAction, @selector(_didParent:updateChildObject:connection:), self]
                     additionalArguments:[self _sendDelegateAdditionalArgumentsForObjectSave]];
}

/*! @ignore
*/
- (void)_didParent:(NURESTObject)aParentObject updateChildObject:(NURESTObject)aChildObject connection:(NURESTConnection)aConnection
{
    [self showLoading:NO];

    if (![self _performServerValidation:aConnection])
    {
        [self _sendDelegateDidFailToSaveObject:aChildObject connection:aConnection];
        [self _sendDelegateDidFailToUpdateObject:aChildObject connection:aConnection];
        return;
    }

    [self setModified:NO];
    [self setSavingEnabled:NO];

    [self _sendDelegateDidSaveObject:aChildObject connection:aConnection];
    [self _sendDelegateDidUpdateObject:aChildObject connection:aConnection];
}

/*! Deletes the given RESTObject
*/
- (void)deleteRESTObject:(NURESTObject)anObject
{
    [self _sendDelegateWillDeleteObject];

    [self setSavingEnabled:NO];
    [self showLoading:NO];

    [self _invokeRESTActionWithArguments:[anObject, _deleteAction, @selector(_didParent:deleteChildObject:connection:), self]
                     additionalArguments:[self _sendDelegateAdditionalArgumentsForObjectDelete]];
}

/*! @ignore
*/
- (void)_didParent:(NURESTObject)aParentObject deleteChildObject:(NURESTObject)aChildObject connection:(NURESTConnection)aConnection
{
    if (![NURESTConnection handleResponseForConnection:aConnection postErrorMessage:YES])
    {
        [self _sendDelegateDidFailToDeleteObject:aChildObject connection:aConnection];
        return;
    }

    [self setModified:NO];
    [self setSavingEnabled:NO];

    [_selectedObjects removeObject:aChildObject];

    [self _sendDelegateDidDeleteObject:aChildObject connection:aConnection];
}

/*! Instantiates the given RESTObject
*/
- (void)instantiateRESTObject:(NURESTObject)anObject
{
    var template = [self _sendDelegateTemplateForInstantiationOfObject];

    if (!template)
        [CPException raise:CPInternalInconsistencyException reason:"moduleContext:templateForInstantiationOfObject: must be implemented when using instantiateRESTObject:"];

    [self setSavingEnabled:NO];

    [self _invokeRESTActionWithArguments:[_parentObject, _instantiateAction, anObject, template, @selector(_didParent:instantiateChildObject:connection:), self]
                     additionalArguments:[self _sendDelegateAdditionalArgumentsForObjectInstantiate]];
}

/*! @ignore
*/
- (void)_didParent:(NURESTObject)aParentObject instantiateChildObject:(NURESTObject)aChildObject connection:(NURESTConnection)aConnection
{
    if (![self _performServerValidation:aConnection])
        return;

    [self setModified:NO];
    [self setSavingEnabled:NO];

    [aChildObject setParentObject:aParentObject];

    [self _sendDelegateDidCreateObject:aChildObject connection:aConnection];
}


#pragma mark -
#pragma mark Actions

/*! @ignore
*/
- (@action)openHelpWindow:(id)aSender
{
    window.open([[CPURL URLWithString:@"Resources/Help/popover-" + _identifier + @".html"] absoluteString], "_new", "width=800,height=600");
}

/*! Action sent to create a new object from the current edited object
*/
- (@action)createEditedObject:(id)aSender
{
    [self clearAllValidationFields];

    [_popover makeFirstResponder:nil];

    if (_usesAutoValidatation && ![self _performClientValidation])
        return;

    [self createRESTObject:_editedObject];
}

/*! Action sent to update the current edited object
*/
- (@action)updateEditedObject:(id)aSender
{
    [self clearAllValidationFields];

    if (_popover)
        [_popover makeFirstResponder:nil];
    else
    {
        if (_editionView)
            [[_editionView window] makeFirstResponder:nil];
        else
            [[_additionalEditionViews[0] window] makeFirstResponder:nil];
    }

    if (_usesAutoValidatation && ![self _performClientValidation])
        return;

    [self updateRESTObject:_editedObject];
}

/*! Action sent to delete all objects set as selectedObjects
*/
- (@action)deleteSelectedObjects:(id)aSender
{
    for (var i = [_selectedObjects count] - 1; i >= 0; i--)
        [self deleteRESTObject:_selectedObjects[i]];
}

/*! Action sent to instantiate the current edited object
*/
- (@action)instantiateEditedObject:(id)aSender
{
    [self clearAllValidationFields];

    [_popover makeFirstResponder:nil];

    if (_usesAutoValidatation && ![self _performClientValidation])
        return;

    [self instantiateRESTObject:_editedObject];
}


#pragma mark -
#pragma mark Delegates

/*! @ignore
*/
- (void)controlTextDidEndEditing:(CPNotification)aNotification
{
    [self _sendDelegateValidateObjectWithAttribute:[[aNotification object] tag]];
    [self _updateValidationFields];
}


#pragma mark -
#pragma mark Popover Delegate

/*! @ignore
*/
- (void)popoverWillShow:(CPPopover)aPopover
{
    [self setSavingEnabled:NO];

    [self clearAllValidationFields];
    [self _bindControls];

    [self _sendDelegateWillManageObject];
}

/*! @ignore
*/
- (void)popoverDidShow:(CPPopover)aPopover
{
    [self _setCurrentInitialFirstResponder];
}

/*! @ignore
*/
- (void)popoverDidClose:(CPPopover)aPopover
{
    [self _sendDelegateDidManageObject];

    // we resign the first responder here, or some weird
    // shit is happening with the bindings.
    [_popover makeFirstResponder:nil];
    [self setModified:NO];
    [self setSavingEnabled:NO];
    [self _unbindControls];
}

@end
