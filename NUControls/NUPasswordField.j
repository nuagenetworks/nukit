/*
* Copyright (c) 2017, Nokia Corporation
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
@import <AppKit/CPSecureTextField.j>
@import <AppKit/CPButton.j>

@import "NUUtilities.j"

var CPTextFieldDOMCurrentElement = nil;

NUPasswordModeSecure = 0;
NUPasswordModeClear  = 1;

/*! Custom delegate
*/

@protocol TogglePasswordFieldDelegate <CPObject>

@optional
- (void)passwordFieldModeChanged:(int)aMode;

@end

TogglePasswordFieldModeIsChangingNotification = @"TogglePasswordFieldModeIsChangingNotification";

var TogglePasswordFieldDelegate_passwordFieldModeChanged_      = 1 << 1;


/*! NUPasswordField is a secure textfield that only allows to see the text in clear password as well
*/
@implementation NUPasswordField : CPSecureTextField <TogglePasswordFieldDelegate>
{
    BOOL                                _clearText         @accessors(getter=allowClearText, setter=setClearText);
    int                                 _mode              @accessors(property=mode);

    CPButton                            _showHidePasswordButton;

    id<TogglePasswordFieldDelegate>     _passwordDelegate;

    unsigned                            _implementedPasswordDelegateMethods;
}


#pragma mark -
#pragma mark Init methods

/*! @ignore
*/
- (id)init
{
    if (self = [super init])
    {
        [self _init];
    }

    return self;
}

/*! @ignore
*/
- (id)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect])
    {
        [self _init];
    }

    return self;
}

-(void)_init
{
    _clearText                          = NO;
    _mode                               = NUPasswordModeSecure;
    _showHidePasswordButton             = [[CPButton alloc] initWithFrame:[self _buttonRectForBounds:[self bounds]]];

    _implementedPasswordDelegateMethods = 0;

    [_showHidePasswordButton setBordered:NO];
    [_showHidePasswordButton setButtonType:CPMomentaryChangeButton];
    [_showHidePasswordButton setValue:NUImageInKit(@"button-view.png", 16.0, 16.0) forThemeAttribute:@"image"];
    [_showHidePasswordButton setAutoresizingMask:CPViewMinXMargin];
    [_showHidePasswordButton setTarget:self];
    [_showHidePasswordButton setAction:@selector(_toggleMode:)];

    [self addSubview:_showHidePasswordButton];
    [self _toggleButtonVisibility];
    _cucappID(_showHidePasswordButton, @"button-show-hide-password");
}

- (BOOL)_shouldShow
{
    return [self mode] == NUPasswordModeClear;
}

-(void)reset
{
    [self setMode:NUPasswordModeSecure];
    [self setClearText:NO];
}


#pragma mark -
#pragma mark Delegate methods

/*!
    Sets the NUPasswordField TogglePasswordFieldDelegate delegate.
*/
- (void)setDelegate:(id <TogglePasswordFieldDelegate>)aDelegate
{
    if (_passwordDelegate === aDelegate)
        return;

    if ([aDelegate respondsToSelector:@selector(passwordFieldModeChanged:)])
    {
        _passwordDelegate = aDelegate;
        _implementedPasswordDelegateMethods |= TogglePasswordFieldDelegate_passwordFieldModeChanged_;
    }

    [super setDelegate:aDelegate];
}


#pragma mark -
#pragma mark Accessors

/*!
    Sets the flag to allow field's text to be seen in clear text.
    @param aFlag \c YES makes the text be displayed in clear text
*/
- (void)setClearText:(BOOL)aFlag
{
    if (_clearText === aFlag)
        return;
    [self willChangeValueForKey:@"clearText"]
    _clearText = aFlag;
    [self didChangeValueForKey:@"clearText"];

    [self _toggleButtonVisibility];
}

- (void)setMode:(int)aMode
{
    if (_mode === aMode)
        return;

    [self willChangeValueForKey:@"mode"];
    _mode = aMode;
    [self didChangeValueForKey:@"mode"];

    [self _toggleButtonVisibility];
}


#pragma mark -
#pragma mark Actions

- (void)_toggleMode:(id)aSender
{
    [self setMode:[self _shouldShow] ? NUPasswordModeSecure : NUPasswordModeClear];
}

/*!
    Returns \c YES if the field's text is to be displayed in clear text (password entry).
*/
- (BOOL)isClearText
{
    return _clearText;
}

#pragma mark -
#pragma mark Layout methods

/*! Modifies the bounding rectangle for the show/hide button.
    Subclasses can override this method to return a new bounding rectangle for the cancel button. You might use this method to provide a custom layout for the search field control.
*/
- (CGRect)_buttonRectForBounds:(CGRect)rect
{
    var size = CGSizeMake(CGRectGetHeight(rect), CGRectGetHeight(rect));

    return CGRectMake(CGRectGetWidth(rect) - size.height, 0, size.height, size.height);
}

/*! @ignore
*/
- (void)_toggleButtonVisibility
{
    var isButtonVisible = [self isClearText] && [self isEnabled],
        buttonImage     = [self mode] == NUPasswordModeSecure ? @"button-view.png" : @"button-message-checkbox-ok-on.png";

    [_showHidePasswordButton setHidden:!isButtonVisible];
    if (!isButtonVisible)
        return;

    [_showHidePasswordButton setValue:NUImageInKit(buttonImage, 16.0, 16.0) forThemeAttribute:@"image"];
    [self _sendDelegatePasswordFieldModeChanged];
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Override

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (![self _shouldShow])
        return;

    var contentView = [self layoutEphemeralSubviewNamed:@"content-view"
                                             positioned:CPWindowAbove
                        relativeToEphemeralSubviewNamed:@"bezel-view"];

    if (contentView && ![contentView isHidden])
    {
        var string = "";

        if ([self hasThemeState:CPTextFieldStatePlaceholder])
            string = [self placeholderString];
        else
        {
            string = _stringValue;
        }

        [contentView setText:string];
    }
}

- (DOMElement)_inputElement
{
    var element = [super _inputElement];

    if (![self isClearText])
        return element;

        // hack to turn on/off text on the password input
#if PLATFORM(DOM)
        if (element)
            element.type = [self _shouldShow] ? "text" : "password";
#endif
    return element;
}

@end

var NUPasswordFieldClearTextKey = @"NUPasswordFieldClearTextKey",
    NUPasswordFieldDelegateKey  = @"NUPasswordFieldDelegateKey",
    NUPasswordFieldModeKey      = @"NUPasswordFieldModeKey";



@implementation NUPasswordField (CPCoding)

/*! @ignore
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        [self _init];

         if ([aCoder containsValueForKey:NUPasswordFieldModeKey])
             [self setMode:[aCoder decodeIntForKey:NUPasswordFieldModeKey] || NUPasswordModeSecure];

         if ([aCoder containsValueForKey:NUPasswordFieldClearTextKey])
             [self setClearText:[aCoder decodeBoolForKey:NUPasswordFieldClearTextKey] || NO];
    }

    return self;
}

/*! @ignore
*/
- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeBool:_clearText forKey:NUPasswordFieldClearTextKey];
    [aCoder encodeInt:_mode forKey:NUPasswordFieldModeKey];
}

@end

@implementation NUPasswordField (TogglePasswordFieldDelegate)

- (void)_sendDelegatePasswordFieldModeChanged
{
    if (!(_implementedPasswordDelegateMethods & TogglePasswordFieldDelegate_passwordFieldModeChanged_) || ![_passwordDelegate respondsToSelector:@selector(passwordFieldModeChanged:)])
        return;

    [_passwordDelegate passwordFieldModeChanged:[self mode]];
}

@end
