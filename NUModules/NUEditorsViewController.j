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
@import <AppKit/CPViewController.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPView.j>
@import <Bambou/NURESTObject.j>

@import "NUSkin.j"

@class NUModule

@global NUNullDescriptionTransformerName

var NUEditorsViewController_editorController_shouldShowEditor_forObject_ = 1 << 1;

/*! NUEditorsViewController the class responsible for managing
    a set of NUModules that will be shown as editor.
*/
@implementation NUEditorsViewController : CPViewController
{
    @outlet CPImageView     imageTitle;
    @outlet CPTextField     labelTitle                      @accessors(property=labelTitle);
    @outlet CPView          viewMultipleSelection;
    @outlet CPView          viewNoSelection;
    @outlet CPView          viewLabel;

    BOOL                    _isLocked                       @accessors(property=isLocked);
    id                      _delegate                       @accessors(getter=delegate);
    NUModule                _currentController              @accessors(getter=currentController);
    NUModule                _parentModule                   @accessors(property=parentModule);
    NURESTObject            _parentOfEditedObject           @accessors(property=parentOfEditedObject);


    unsigned                _implementedDelegateMethods;
    CPDictionary            _editorsRegistry;
}


#pragma mark -
#pragma mark Initialization

- (void)viewDidLoad
{
    [viewMultipleSelection setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [viewMultipleSelection setBackgroundColor:NUSkinColorWhite];

    [viewNoSelection setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [viewNoSelection setBackgroundColor:NUSkinColorWhite];

    [viewLabel setAutoresizingMask:CPViewWidthSizable];

    [labelTitle setObjectValue:@""];
    [self _showController:nil forEditedObject:nil];
}


#pragma mark -
#pragma mark Custom Getter / Setter

/*! Sets the title image, if any
*/
- (void)setImage:(CPImage)anImage
{
    if (_isLocked || !imageTitle)
        return;

    [imageTitle setImage:anImage];
}

/*! Set the keypath of the given object with the given transformer to use a title.
*/
- (void)setTitleFromKeyPath:(CPString)aKeyPath ofObject:(id)anObject transformer:(id)aTransformer
{
    if (_isLocked)
        return;

    [self resetLabelTitle];

    if (!aKeyPath)
        return;

    if (!anObject)
        return;

    [labelTitle bind:CPValueBinding toObject:anObject withKeyPath:aKeyPath options:aTransformer];
}


#pragma mark -
#pragma mark Utilities

/*! Reset the label title
*/
- (void)resetLabelTitle
{
    [labelTitle unbind:CPValueBinding];
    [labelTitle setObjectValue:@""];
}

/*! Register the given NUModule as an editor for objects with the given RESTName
*/
- (void)registerEditor:(NUModule)anEditor forObjectsWithRESTName:(CPString)aRESTName
{
    if (!_editorsRegistry)
        _editorsRegistry = @{};

    [anEditor setParentModule:self];
    [_editorsRegistry setObject:anEditor forKey:aRESTName];
}

/*! Sets the currentParent that will be given to all root editors.
*/
- (void)setCurrentParent:(NURESTObject)anObject
{
    if (_isLocked || anObject == [self currentParent])
        return;

    if (!anObject)
    {
        [self resetLabelTitle];
        [self _showController:nil forEditedObject:nil];
        return;
    }

    var controller = [_editorsRegistry objectForKey:[anObject RESTName]];

    if ([self _sendDelegateShouldShowEditor:controller forObject:anObject])
        [self _showController:controller forEditedObject:anObject];
    else
        [self _showController:nil forEditedObject:nil];
}

/*! Returns the currentParent
*/
- (void)currentParent
{
    return [_currentController currentParent];
}

/*! Used to check if all editors managed by the controller agree to hide
*/
- (BOOL)checkIfEditorAgreeToHide
{
    return _currentController ? [_currentController shouldHide] : YES;
}

- (void)_showController:(NUModule)aController forEditedObject:(NURESTObject)anObject
{
    [self showMultipleSelectionView:NO];

    var width = [[self view] frameSize].width,
        height = [[self view] frameSize].height;

    if (_currentController)
    {
        [self setDataViewForObject:[_currentController currentParent] highlighted:NO];
        [_currentController willHide];
        [[_currentController view] removeFromSuperview];
    }

    _currentController = aController;

    if (!aController)
    {
        [self setTitle:@""];
        [self setImage:nil];

        [self showNoSelectionView:YES];
        return;
    }

    [self showNoSelectionView:NO];

    [[_currentController view] setFrameSize:CGSizeMake(width, height)];
    [_currentController setCurrentParent:anObject];
    [_currentController willShow];

    [self setDataViewForObject:anObject highlighted:YES];

    [[self view] addSubview:[_currentController view]];
}

/*! @ignore.
    That's weird...
*/
- (void)setDataViewForObject:(id)anObject highlighted:(BOOL)shouldHighlight
{
    var module = [self parentModule];

    while (module)
    {
        if ([module contextWithIdentifier:[anObject RESTName]])
        {
            [module setDataViewForObject:anObject highlighted:shouldHighlight];
            return;
        }
        module = [module visibleSubModule];
    }
}

/*! Shows the no selection view.
*/
- (void)showNoSelectionView:(BOOL)shouldShow
{
    if (!viewNoSelection)
        return;

    if (shouldShow)
    {
        if ([viewNoSelection superview])
            return;

        [viewLabel setBackgroundColor:NUSkinColorWhite];
        [viewNoSelection setFrame:[[self view] bounds]];
        [[self view] addSubview:viewNoSelection];
    }
    else
    {
        if (![viewNoSelection superview])
            return;

        [viewLabel setBackgroundColor:NUSkinColorGreyLight];
        [viewNoSelection removeFromSuperview];
    }
}

/*! Shows the multiple selection view
*/
- (void)showMultipleSelectionView:(BOOL)shouldShow
{
    if (!viewMultipleSelection)
        return;

    if (shouldShow)
    {
        if ([viewMultipleSelection superview])
            return;

        [viewMultipleSelection setFrame:[[self view] bounds]];
        [[self view] addSubview:viewMultipleSelection];
    }
    else
    {
        if (![viewMultipleSelection superview])
            return;

        [viewMultipleSelection removeFromSuperview];
    }
}


#pragma mark -
#pragma mark Delegate Management

/*! Set the delegate

    - (BOOL)editorController:(NUEditorsViewController)anEditorController shouldShowEditor:(NUModule)anEditor forObject:(NURESTObject)anObject
*/
- (void)setDelegate:(id)aDelegate
{
    if (aDelegate == _delegate)
        return;

    _delegate = aDelegate;
    _implementedDelegateMethods = 0;

    if ([_delegate respondsToSelector:@selector(editorController:shouldShowEditor:forObject:)])
        _implementedDelegateMethods |= NUEditorsViewController_editorController_shouldShowEditor_forObject_;
}

/*! @ignore
*/
- (BOOL)_sendDelegateShouldShowEditor:(NUModel)anEditor forObject:(NURESTObject)anObject
{
    if (_implementedDelegateMethods & NUEditorsViewController_editorController_shouldShowEditor_forObject_)
        return [_delegate editorController:self shouldShowEditor:anEditor forObject:anObject];
    else
        return YES;
}


#pragma mark -
#pragma mark Responder Chain

/*! Returns the initial first reponder for the editor.
    That will be the initialFirstResponder of the current visible editor.
*/
- (CPResponder)initialFirstResponder
{
    if (!_currentController)
        return nil;

    return [_currentController initialFirstResponder];
}

@end
