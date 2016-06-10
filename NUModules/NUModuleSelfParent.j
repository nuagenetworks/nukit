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
@import <AppKit/CPButton.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPView.j>

@import "NUModule.j"
@import "NUOverlayTextField.j"
@import "NUStackView.j"

/*! NUModuleSelfParent is a module used to edit a single object.
    It is often used as an editor. It doesn't use a popover to edit the object,
    but rather a set of views that the context will use to bind and
    edit the currentParent directly.
*/
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

/*! @ignore
*/
+ (BOOL)isTableBasedModule
{
    return NO;
}

/*! @ignore
*/
+ (BOOL)automaticChildrenListsDiscard
{
    return NO;
}

/*! @ignore
*/
+ (BOOL)automaticSelectionSaving
{
    return NO;
}

/*! @ignore
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (BOOL)moduleShouldHide
{
    return ![_currentContext modified];
}

/*! @ignore
*/
- (void)moduleDidSetCurrentParent:(id)aParent
{
    [super moduleDidSetCurrentParent:aParent];
    [self setCurrentContextWithIdentifier:[aParent RESTName]];
}

/*! @ignore
*/
- (CPResponder)initialFirstResponder
{
    return [[self view] subviewWithTag:@"name" recursive:YES];
}


#pragma mark -
#pragma mark NUModuleSelfParent API

/*! Internal API that you can override to give the list of active edition view.
    By default, NUModuleSelfParent will use only one edition view: viewEditionMain.
    If you use more, you'll need to override this.
*/
- (CPArray)moduleCurrentVisibleEditionViews
{
    if (viewEditionMain)
        return [viewEditionMain];
}

/*! Internal API that is called when the user interface
    may need to be updated (after setting a current parent, or after a push)
*/
- (void)moduleUpdateEditorInterface
{
}


#pragma mark -
#pragma mark Utilities

/*! @ignore
*/
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

/*! Set the UI to be readonly. If readonly tje labelReadOnlyReason will be shown
    and the save button will be disabled.
*/
- (void)setReadOnly:(BOOL)isReadOnly
{
    _readOnly = isReadOnly;
    [labelReadOnlyReason setHidden:!_readOnly];
}

/*! Reload the stack view containing the edition views.
*/
- (void)reloadStackView
{
    if (_stackViewMain)
        [_stackViewMain setSubviews:[self moduleCurrentVisibleEditionViews]];

    [_stackViewMain setNeedsLayout];
}


#pragma mark -
#pragma mark Actions

/*! Saves the current edited object.
*/
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

/*! @ignore
*/
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

/*! @ignore
*/
- (id)createObjectWithRESTName:(CPString)anIdenfier
{
    return [[_currentParent class] new];
}


#pragma mark -
#pragma mark Delegates

/*! @ignore
*/
- (void)overlayTextFieldDidHide:(NUOverlayTextField)anOverlayTextField
{
    var currentValidation = [_currentContext currentValidation],
        context           = [self currentContext];

    if (currentValidation)
        [currentValidation removeErrorForProperty:@"serverError"];

    if (context)
        [context setSavingEnabled:YES];
}

@end
