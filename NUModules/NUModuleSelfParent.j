/*
*   Filename:         NUModuleSelfParent.j
*   Created:          Fri Jun 21 14:51:58 PDT 2013
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
@import <AppKit/CPButton.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPView.j>

@import "NUModule.j"
@import "NUOverlayTextField.j"
@import "NUStackView.j"


@implementation NUModuleSelfParent : NUModule
{
    @outlet CPButton        buttonSave;
    @outlet CPScrollView    scrollViewMain;
    @outlet CPTextField     labelReadOnlyReason;
    @outlet CPView          viewBottom;
    @outlet CPView          viewEditionMain;

    BOOL                    _readOnly;
    NUStackView             _stackViewMain;
    NUOverlayTextField      _overlayFieldError;
}


#pragma mark -
#pragma mark Initialization

+ (BOOL)isTableBasedModule
{
    return NO;
}

+ (BOOL)automaticChildrenListsDiscard
{
    return NO;
}

+ (BOOL)automaticSelectionSaving
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self view] setBackgroundColor:NUSkinColorWhite];

    if (buttonSave)
    {
        [buttonSave setTarget:self];
        [buttonSave setAction:@selector(saveCurrentParent:)];
        _cucappID(buttonSave, @"editor-button-save");
    }

    [labelReadOnlyReason setTextColor:NUSkinColorGreyDark];
    _cucappID(labelReadOnlyReason, @"label-readonly-reason");

    [viewBottom setBorderTopColor:NUSkinColorGreyLight];

    if (scrollViewMain)
    {
        _stackViewMain = [[NUStackView alloc] initWithFrame:CGRectMakeZero()];
        [_stackViewMain setMargin:CGInsetMake(0, 0, 5, 0)];

        var documentViewFrame = [_stackViewMain frame],
            contentSize = [scrollViewMain contentSize];

        documentViewFrame.size.width = contentSize.width;
        documentViewFrame.origin.x = 0;
        documentViewFrame.origin.y = 0;
        [_stackViewMain setAutoresizingMask:CPViewWidthSizable];
        [_stackViewMain setFrame:documentViewFrame];
        [scrollViewMain setDocumentView:_stackViewMain];
        [scrollViewMain setAutohidesScrollers:YES];
    }
}


#pragma mark -
#pragma mark NUModule API

- (void)moduleDidShow
{
    [super moduleDidShow];

    if (scrollViewMain)
        [[scrollViewMain contentView] scrollToPoint:CGPointMakeZero()];

    if (![self currentContext])
        return;

    [_currentContext setDelegate:self];
    [_currentContext setEditedObject:_currentParent];
    [_currentContext clearAllValidationFields];

    [self reloadStackView];

    [self moduleUpdateEditorInterface];

    [self _installOverlayFieldError];
}

- (BOOL)moduleShouldHide
{
    return ![_currentContext modified];
}

- (void)moduleDidSetCurrentParent:(id)aParent
{
    [super moduleDidSetCurrentParent:aParent];
    [self setCurrentContextWithIdentifier:[aParent RESTName]];
}

- (CPResponder)initialFirstResponder
{
    return [[self view] subviewWithTag:@"name" recursive:YES];
}


#pragma mark -
#pragma mark NUModuleSelfParent API

- (CPArray)moduleCurrentVisibleEditionViews
{
    if (viewEditionMain)
        return [viewEditionMain];
}

- (void)moduleUpdateEditorInterface
{
}


#pragma mark -
#pragma mark Utilities

- (void)_installOverlayFieldError
{
    if (_overlayFieldError)
        return;

    var errorField = [[self view] subviewWithTag:@"validation_serverError" recursive:YES];

    if (errorField)
    {
        var frameSize = [[self view] frameSize];

        _overlayFieldError = [[NUOverlayTextField alloc] initWithFrame:CGRectMake(0, 0, frameSize.width, frameSize.height)];
        [_overlayFieldError setTargetView:[self view]];
        [_overlayFieldError setTargetTextField:errorField];
        [_overlayFieldError setDelegate:self];
    }

    _cucappID([self view], @"editor-" + [[self class] moduleIdentifier]);
}

- (void)setReadOnly:(BOOL)isReadOnly
{
    _readOnly = isReadOnly;
    [labelReadOnlyReason setHidden:!_readOnly];
}

- (void)reloadStackView
{
    if (_stackViewMain)
        [_stackViewMain setSubviews:[self moduleCurrentVisibleEditionViews]];

    [_stackViewMain setNeedsLayout];
}


#pragma mark -
#pragma mark Actions

- (@action)saveCurrentParent:(id)aSender
{
    if (_currentContext && [[_currentContext currentValidation] success])
        [_currentContext updateEditedObject:self];
}


#pragma mark -
#pragma mark Overrides

- (void)reload
{
    // we do nothing here
}


#pragma mark -
#pragma mark Custom Push

- (BOOL)shouldProcessJSONObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    if (aJSONObject.ID == [_currentParent ID])
    {
        var obj = [self createObjectWithRESTName:nil];
        [obj objectFromJSON:aJSONObject];
        [self _updateCurrentEditedObjectWithObjectIfNeeded:obj];

        [self updatePermittedActions];
        [self moduleUpdateEditorInterface];
        [self performPostPushOperation];
    }

    return NO;
}

- (id)createObjectWithRESTName:(CPString)anIdenfier
{
    return [[_currentParent class] new];
}


#pragma mark -
#pragma mark Delegates

- (void)overlayTextFieldDidHide:(NUOverlayTextField)anOverlayTextField
{
    var currentValidation = [_currentContext currentValidation];

    if (currentValidation)
        [currentValidation removeErrorForProperty:@"serverError"];
}

@end
