/*
*   Filename:         NUModuleContext.j
*   Created:          Tue Oct  9 11:54:23 PDT 2012
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
@import <AppKit/CPPopover.j>
@import <AppKit/CPOutlineView.j>
@import <AppKit/CPCheckBox.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPProgressIndicator.j>
@import <RESTCappuccino/NURESTObject.j>
@import <RESTCappuccino/NURESTConnection.j>
@import <RESTCappuccino/NURESTFetcher.j>
@import <RESTCappuccino/NURESTError.j>
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
    NUModuleContextAutoValidation = NO;

// reversed for optim
NUModuleContextCommonControlTagsAsFirstResponder = [@"privateIP", @"virtualIP", @"minAddress", @"MAC", @"description", @"value", @"lastName", @"firstName", @"address", @"CIDR", @"name"];

var NUModuleContextDelegate_moduleContext_willManageObject_                        = 1 << 1,
    NUModuleContextDelegate_moduleContext_didManageObject_                         = 1 << 2,

    NUModuleContextDelegate_moduleContext_willSaveObject_                          = 1 << 3,
    NUModuleContextDelegate_moduleContext_didSaveObject_connection_                = 1 << 4,
    NUModuleContextDelegate_moduleContext_didFailToSaveObject_connection_          = 1 << 5,

    NUModuleContextDelegate_moduleContext_willCreateObject_                        = 1 << 6,
    NUModuleContextDelegate_moduleContext_didCreateObject_connection_              = 1 << 7,
    NUModuleContextDelegate_moduleContext_didFailToCreateObject_connection_        = 1 << 8,

    NUModuleContextDelegate_moduleContext_willUpdateObject_                        = 1 << 9,
    NUModuleContextDelegate_moduleContext_didUpdateObject_connection_              = 1 << 10,
    NUModuleContextDelegate_moduleContext_didFailToUpdateObject_connection_        = 1 << 11,

    NUModuleContextDelegate_moduleContext_willDeleteObject_                        = 1 << 12,
    NUModuleContextDelegate_moduleContext_didDeleteObject_connection_              = 1 << 13,
    NUModuleContextDelegate_moduleContext_didFailToDeleteObject_connection_        = 1 << 14,

    NUModuleContextDelegate_moduleContextShouldEnableSaving_                       = 1 << 15,

    NUModuleContextDelegate_moduleContext_validateObject_attribute_validation_     = 1 << 16,
    NUModuleContextDelegate_moduleContext_didFailValidateObject_validation_        = 1 << 17,

    NUModuleContextDelegate_moduleContext_didUpdateEditedObject_                   = 1 << 18,

    NUModuleContextDelegate_moduleContext_templateForInstantiationOfObject_        = 1 << 19,

    NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectCreate_      = 1 << 20,
    NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectSave_        = 1 << 21,
    NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectDelete_      = 1 << 22,
    NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectInstantiate_ = 1 << 23;



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


#pragma mark -
#pragma mark Initialization

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

- (void)showLoading:(BOOL)shouldShow
{
    if ([_viewSpinner superview] && shouldShow)
        [[NUDataTransferController defaultDataTransferController] showFetchingViewOnView:_viewSpinner];
    else
        [[NUDataTransferController defaultDataTransferController] hideFetchingViewFromView:_viewSpinner];
}


#pragma mark -
#pragma mark Property Binding Management

- (void)_resetPopoverCache
{
    _editionView           = nil;
    _buttonSave            = nil;
    _fieldTitle            = nil;
    _initialFirstResponder = nil;

    [_popover setDelegate:nil];
    _bindedControlsCache = @{};
}

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
            [_bindedControlsCache setObject:control forKey:aName];
    }

    return [_bindedControlsCache objectForKey:aName];
}

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
            relatedField = [self _controlForProperty:keyPath],
            value = [_editedObject valueForKeyPath:keyPath];

        if (relatedField)
        {
            _cucappID(relatedField, keyPath);

            if ([relatedField isKindOfClass:CPPopUpButton])
            {
                [relatedField bind:CPSelectedTagBinding toObject:_editedObject withKeyPath:keyPath options:nil];
            }
            else if ([relatedField isKindOfClass:CPCheckBox])
            {
                var opts = @{CPValueTransformerNameBindingOption: NUCheckboxStateToBooleanValueTransformerName};
                [relatedField bind:CPValueBinding toObject:_editedObject withKeyPath:keyPath options:opts];
            }
            else if ([relatedField isKindOfClass:CPProgressIndicator])
            {
                [relatedField bind:CPValueBinding toObject:_editedObject withKeyPath:keyPath options:nil];
            }
            else if ([relatedField isKindOfClass:CPImageView])
            {
                var opts = @{},
                    declaredTransformerName = [relatedField valueTransformerName];

                if (declaredTransformerName)
                    [opts setObject:declaredTransformerName forKey:CPValueTransformerNameBindingOption];

                [relatedField bind:CPValueBinding toObject:_editedObject withKeyPath:keyPath options:opts];
            }
            else if ([relatedField isKindOfClass:CPTextField])
            {
                var opts = @{CPContinuouslyUpdatesValueBindingOption: YES},
                    declaredTransformerName = [relatedField valueTransformerName];

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

                if ([relatedField placeholderString])
                    [opts setObject:[relatedField placeholderString] forKey:CPNullPlaceholderBindingOption];

                if (![relatedField isEditable])
                    [relatedField setLineBreakMode:CPLineBreakByTruncatingTail];

                [relatedField setSelectable:YES];

                if (NUValidationActive)
                    [relatedField setDelegate:self];

                [relatedField bind:CPValueBinding toObject:_editedObject withKeyPath:keyPath options:opts];
            }
            else
                [CPException raise:CPInternalInconsistencyException reason:"NUModuleContext doesn't support binding for control class: " + [relatedField class]];
        }
    }

    _bindingsDirty = NO;
}

- (void)_unbindControls
{
    if (!_editedObject)
        return;

    var attributes = [_editedObject bindableAttributes];

    for (var i = [attributes count] - 1; i >= 0; i--)
    {
        var keyPath      = attributes[i],
            relatedField = [self _controlForProperty:keyPath],
            value        = [_editedObject valueForKeyPath:keyPath];

        if ([relatedField isKindOfClass:CPPopUpButton])
            [relatedField unbind:CPSelectedTagBinding];
        else
            [relatedField unbind:CPValueBinding];

        if (NUValidationActive && [relatedField isKindOfClass:CPTextField])
            [relatedField setDelegate:nil];
    }

    _bindingsDirty = YES;
}

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


#pragma mark -
#pragma mark Delegate Management

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
}

- (void)_sendDelegateWillSaveObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willSaveObject_)
        [_delegate moduleContext:self willSaveObject:_editedObject];
}

- (void)_sendDelegateDidSaveObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didSaveObject_connection_)
        [_delegate moduleContext:self didSaveObject:anObject connection:aConnection];
}

- (void)_sendDelegateDidFailToSaveObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailToSaveObject_connection_)
        [_delegate moduleContext:self didFailToSaveObject:anObject connection:aConnection];
}

- (void)_sendDelegateWillCreateObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willCreateObject_)
        [_delegate moduleContext:self willCreateObject:_editedObject];
}

- (void)_sendDelegateDidCreateObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didCreateObject_connection_)
        [_delegate moduleContext:self didCreateObject:anObject connection:aConnection];
}

- (void)_sendDelegateDidFailToCreateObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailToCreateObject_connection_)
        [_delegate moduleContext:self didFailToCreateObject:anObject connection:aConnection];
}

- (void)_sendDelegateWillUpdateObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willUpdateObject_)
        [_delegate moduleContext:self willUpdateObject:_editedObject];
}

- (void)_sendDelegateDidUpdateObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didUpdateObject_connection_)
        [_delegate moduleContext:self didUpdateObject:anObject connection:aConnection];
}

- (void)_sendDelegateDidFailToUpdateObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailToUpdateObject_connection_)
        [_delegate moduleContext:self didFailToUpdateObject:anObject connection:aConnection];
}

- (void)_sendDelegateWillDeleteObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willDeleteObject_)
        [_delegate moduleContext:self willDeleteObject:_editedObject];
}

- (void)_sendDelegateDidDeleteObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didDeleteObject_connection_)
        [_delegate moduleContext:self didDeleteObject:anObject connection:aConnection];
}

- (void)_sendDelegateDidFailToDeleteObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailToDeleteObject_connection_)
        [_delegate moduleContext:self didFailToDeleteObject:anObject connection:aConnection];
}

- (void)_sendDelegateValidateObjectWithAttribute:(CPString)anAttribute
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_validateObject_attribute_validation_)
        [_delegate moduleContext:self validateObject:_editedObject attribute:anAttribute validation:_currentValidation];
}

- (BOOL)_sendDelegateShouldEnableSaving
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContextShouldEnableSaving_)
        return [_delegate moduleContextShouldEnableSaving:self];

    return YES;
}

- (void)_sendDelegateUpdateEditedObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didUpdateEditedObject_)
        [_delegate moduleContext:self didUpdateEditedObject:_editedObject];
}

- (void)_sendDelegateWillManageObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_willManageObject_)
        [_delegate moduleContext:self willManageObject:_editedObject];
}

- (void)_sendDelegateDidManageObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didManageObject_)
        [_delegate moduleContext:self didManageObject:_editedObject];
}

- (NURESTObject)_sendDelegateTemplateForInstantiationOfObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_templateForInstantiationOfObject_)
        return [_delegate moduleContext:self templateForInstantiationOfObject:_editedObject];

    return nil;
}

- (void)_sendDelegateDidServerValidationOfObject
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_didFailValidateObject_validation_)
        [_delegate moduleContext:self didFailValidateObject:_editedObject validation:_currentValidation];
}

- (void)_sendDelegateAdditionalArgumentsForObjectCreate
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectCreate_)
        return [_delegate moduleContext:self additionalArgumentsForObjectCreate:_editedObject];
}

- (void)_sendDelegateAdditionalArgumentsForObjectSave
{
    if (_implementedDelegateMethods & NUModuleContextDelegate_moduleContext_additionalArgumentsForObjectSave_)
        return [_delegate moduleContext:self additionalArgumentsForObjectSave:_editedObject];
}

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



#pragma mark -
#pragma mark Popover Management

- (void)openPopoverForAction:(int)anAction sender:(id)aSender
{
    if (!_popover)
        return;

    switch (anAction)
    {
        case NUModuleActionEdit:
            [_fieldTitle setStringValue:@"Edit " + _name];
            [_buttonSave setTitle:@"Update"];
            [_buttonSave setTarget:self];
            [_buttonSave setAction:@selector(updateEditedObject:)];
            break;

        case NUModuleActionInstantiate:
            [_fieldTitle setStringValue:@"Instantiate " + _name];
            [_buttonSave setTitle:@"Instantiante"];
            [_buttonSave setTarget:self];
            [_buttonSave setAction:@selector(instantiateEditedObject:)];
            break;

        default:
            [_fieldTitle setStringValue:@"New " + _name];
            [_buttonSave setTitle:@"Create"];
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

- (void)_makeRelatedFieldFirstResponderAccordingToCurrentValidation
{
    var property           = [[[_currentValidation errors] allKeys] firstObject],
        relatedField       = [_editionView subviewWithTag:property recursive:_searchForTagsRecursively],
        relatedEditionView = _editionView;

    if (!relatedField)
    {
        for (var i = [_additionalEditionViews count] - 1; i >= 0; i--)
        {
            var editionView = _additionalEditionViews[i],
                field       = [editionView subviewWithTag:property recursive:_searchForTagsRecursively];

            if (field)
            {
                relatedField = field;
                relatedEditionView = editionView;
                break;
            }
        }
    }

    if (_popover)
        [_popover makeFirstResponder:relatedField];
    else
        [[relatedEditionView window] makeFirstResponder:relatedField];
}

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
                var error = serverErrors[i],
                    propertyName = error.property,
                    errorDescription = error.descriptions[0].description,
                    errorTitle = error.descriptions[0].title;

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
            [labelView setStringValue:title];
            [labelView setToolTip:description];
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
}

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
}


#pragma mark -
#pragma mark Modification Management

- (void)_addObservers
{
    if (!_editedObject)
        return;

    var properties = [_editedObject bindableAttributes];

    for (var i = [properties count] - 1; i >= 0; i--)
        [_editedObject addObserver:self forKeyPath:properties[i] options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
}

- (void)_removeObservers
{
    if (!_editedObject)
        return;

    var properties = [_editedObject bindableAttributes];

    for (var i = [properties count] - 1; i >= 0; i--)
        [_editedObject removeObserver:self forKeyPath:properties[i]];
}

- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    var oldValue = [change objectForKey:CPKeyValueChangeOldKey],
        newValue = [change objectForKey:CPKeyValueChangeNewKey];

    if (oldValue == newValue)
        return;

    [self _sendDelegateValidateObjectWithAttribute:keyPath];
    [self _updateValidationFields];

    [self setModified:![_editedObjectPristine isRESTEqual:_editedObject]];
    [self setSavingEnabled:_modified && [_currentValidation success]];
}


#pragma mark -
#pragma mark REST Management

- (void)_invokeRESTActionWithArguments:(CPArray)someArguments additionalArguments:(CPArray)someAdditionalArguments
{
    someArguments = someAdditionalArguments ? [someArguments arrayByAddingObjectsFromArray:someAdditionalArguments] : someArguments;

    var invocation = [CPInvocation invocationWithMethodSignature:@"RESTInvocation"];
    [invocation setArguments:someArguments];
    [invocation invoke];
}

- (void)createRESTObject:(NURESTObject)anObject
{
    [self _sendDelegateWillSaveObject];
    [self _sendDelegateWillCreateObject];

    [self setSavingEnabled:NO];
    [self showLoading:YES];

    [self _invokeRESTActionWithArguments:[_parentObject, _createAction, anObject, @selector(_didParent:createChildObject:connection:), self]
                     additionalArguments:[self _sendDelegateAdditionalArgumentsForObjectCreate]];
}

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

- (void)updateRESTObject:(NURESTObject)anObject
{
    [self _sendDelegateWillSaveObject];
    [self _sendDelegateWillUpdateObject];

    [self setSavingEnabled:NO];
    [self showLoading:YES];

    [self _invokeRESTActionWithArguments:[anObject, _updateAction, @selector(_didParent:updateChildObject:connection:), self]
                     additionalArguments:[self _sendDelegateAdditionalArgumentsForObjectSave]];
}

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

- (void)deleteRESTObject:(NURESTObject)anObject
{
    [self _sendDelegateWillDeleteObject];

    [self setSavingEnabled:NO];
    [self showLoading:NO];

    [self _invokeRESTActionWithArguments:[anObject, _deleteAction, @selector(_didParent:instantiateChildObject:connection:), self]
                     additionalArguments:[self _sendDelegateAdditionalArgumentsForObjectDelete]];
}

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

- (void)instantiateRESTObject:(NURESTObject)anObject
{
    var template = [self _sendDelegateTemplateForInstantiationOfObject];

    if (!template)
        [CPException raise:CPInternalInconsistencyException reason:"moduleContext:templateForInstantiationOfObject: must be implemented when using instantiateRESTObject:"];

    [self setSavingEnabled:NO];

    [self _invokeRESTActionWithArguments:[_parentObject, _instantiateAction, anObject, template, @selector(_didParent:instantiateChildObject:connection:), self]
                     additionalArguments:[self _sendDelegateAdditionalArgumentsForObjectInstantiate]];
}

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

- (IBAction)openHelpWindow:(id)aSender
{
    window.open([[CPURL URLWithString:@"Resources/Help/popover-" + _identifier + @".html"] absoluteString], "_new", "width=800,height=600");
}

- (IBAction)createEditedObject:(id)aSender
{
    [self clearAllValidationFields];

    [_popover makeFirstResponder:nil];

    if (_usesAutoValidatation && ![self _performClientValidation])
        return;

    [self createRESTObject:_editedObject];
}

- (IBAction)updateEditedObject:(id)aSender
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

- (IBAction)deleteSelectedObjects:(id)aSender
{
    for (var i = [_selectedObjects count] - 1; i >= 0; i--)
        [self deleteRESTObject:_selectedObjects[i]];
}

- (IBAction)instantiateEditedObject:(id)aSender
{
    [self clearAllValidationFields];

    [_popover makeFirstResponder:nil];

    if (_usesAutoValidatation && ![self _performClientValidation])
        return;

    [self instantiateRESTObject:_editedObject];
}


#pragma mark -
#pragma mark Delegates

- (void)controlTextDidEndEditing:(CPNotification)aNotification
{
    [self _sendDelegateValidateObjectWithAttribute:[[aNotification object] tag]];
    [self _updateValidationFields];
}


#pragma mark -
#pragma mark Popover Delegate

- (void)popoverWillShow:(CPPopover)aPopover
{
    [self setSavingEnabled:NO];

    [self clearAllValidationFields];
    [self _bindControls];

    [self _sendDelegateWillManageObject];
}

- (void)popoverDidShow:(CPPopover)aPopover
{
    [self _setCurrentInitialFirstResponder];
}

- (void)popoverDidClose:(CPPopover)aPopover
{
    [self _sendDelegateDidManageObject];

    // we resign the first responder here, or some weird
    // shit is happening with the bindings.
    [_popover makeFirstResponder:nil];
    [self setModified:NO];
    [self setSavingEnabled:NO];
}

@end
