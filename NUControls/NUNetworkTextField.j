/*
*   Filename:         NUNUNetworkMACMode.j
*   Created:          Mon Oct 14 13:23:14 PDT 2013
*   Author:           Alexandre Wilhelm <alexandre.wilhelm@alcatel-lucent.com>
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
@import <AppKit/CPControl.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPSearchField.j>
@import <AppKit/CPPasteboard.j>

@class _NUNetworkElementTextField
@class _NUFakeTextField

@global CPApp
@global intFromHexa
@global isHexaCharac
@global isIntegerNumber

var CPZeroKeyCode = 48,
    CPNineKeyCode = 57,
    CPAKeyCode = 97,
    CPFKeyCode = 102,
    SELECTING_COLOR;

NUNetworkIPV4Mode = 0;
NUNetworkIPV6Mode = 1;
NUNetworkMACMode  = 2;

var NUNetworkTextField_noMathWithRegex_forValue_ = 1 << 1,
    NUNetworkTextField_mathWithRegex_forValue_   = 1 << 2,
    NUNetworkTextField_errorMessage_forValue_    = 1 << 3;


@implementation NUNetworkTextField : CPTextField
{
    BOOL                                        _mask                           @accessors(getter=hasMask, setter=setMask:);
    BOOL                                        _showCancelButton               @accessors(getter=isShownCancelButton, setter=setShowCancelButton:);
    CPColor                                     _textColorSeparator             @accessors(property=textColorSeparator);
    CPString                                    _separatorMaskValue             @accessors(property=separatorMaskValue);
    CPString                                    _separatorValue                 @accessors(property=separatorValue);
    id                                          _networkTextFieldDelegate       @accessors(property=delegate);
    id                                          _regexp                         @accessors(property=regexp);
    int                                         _mode                           @accessors(property=mode);
    int                                         _verticalOffset                 @accessors(property=_verticalOffset);

    BOOL                                        _doubleClick;
    BOOL                                        _selectAll;
    BOOL                                        _comesFromPrevious;
    CPButton                                    _cancelButton;
    CPMutableArray                              _IPDigits;
    CPMutableArray                              _MACDigits;
    CPMutableArray                              _separatorLabels;
    CPMutableArray                              _networkElementTextFields;
    CPString                                    _internObjectValue;
    CPTextField                                 _maskSeparatorLabesl;
    int                                         _maskValue;
    _NUNetworkElementTextField                  _currentNetworkTextField;
    _NUFakeTextField                            _fakeTextField;
    unsigned                                    _implementedNUNetworkTextFieldDelegateMethods;
}


#pragma mark -
#pragma mark Init methods

+ (void)initialize
{
    SELECTING_COLOR = [CPColor colorWithHexString:@"A2CCFE"];
}

- (id)init
{
    if (self = [super init])
    {
        [self _init];
    }

    return self;
}

- (id)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect])
    {
        [self _init];
    }

    return self;
}

- (void)_init
{
    _stringValue = @"";
    _internObjectValue = @"";
    _separatorValue = @".";
    _separatorMaskValue = @"/";
    _mode = NUNetworkIPV4Mode;
    _regexp = nil;
    _IPDigits = [];
    _MACDigits = [];
    _mask = YES;
    _verticalOffset = 0;
    _textColorSeparator = [CPColor colorWithCalibratedWhite:79.0 / 255.0 alpha:0.6];
    _comesFromPrevious = NO;
    _selectAll = NO;
    _showCancelButton = NO;

    [self setTheme:[CPTheme defaultTheme]];
    [self setBordered:YES];
    [self setBezeled:YES];
    [self setAlignment:CPLeftTextAlignment];
    [self setEditable:NO];
    [self setSelectable:NO];

    [self _populateNetworkElementTextFields];
    [self setNeedsLayout];

    _fakeTextField = [_NUFakeTextField textFieldWithStringValue:@"121" placeholder:@"" width:100];
    [_fakeTextField setNetworkTextField:self];

    // Used for the cancel button
    var tmpSearchField = [CPSearchField new];

    _cancelButton = [[CPButton alloc] initWithFrame:[self cancelButtonRectForBounds:[self bounds]]];
    _cancelButton._DOMElement.style.cursor = "default";

    [_cancelButton setBordered:NO];
    [_cancelButton setImageScaling:CPImageScaleAxesIndependently];
    [_cancelButton setButtonType:CPMomentaryChangeButton];
    [_cancelButton setImage:[tmpSearchField valueForThemeAttribute:@"image-cancel"]];
    [_cancelButton setAlternateImage:[tmpSearchField valueForThemeAttribute:@"image-cancel-pressed"]];
    [_cancelButton setAutoresizingMask:CPViewMinXMargin];
    [_cancelButton setTarget:self];
    [_cancelButton setAction:@selector(_cancelOperation:)];

    [self _updateCancelButtonVisibility];
    [self addSubview:_cancelButton];
}


#pragma mark -
#pragma mark Responder methods

- (BOOL)becomeFirstResponder
{
    if (!_currentNetworkTextField)
    {
        if (_comesFromPrevious)
            _currentNetworkTextField = [_networkElementTextFields lastObject];
        else
            _currentNetworkTextField = [_networkElementTextFields firstObject];

        if (_doubleClick)
        {
            setTimeout(function(){
                [[self window] makeFirstResponder:_currentNetworkTextField];
                [self selectAll];
            },0);
        }
        else
        {
            setTimeout(function(){
                [[self window] makeFirstResponder:_currentNetworkTextField];
            },0);
        }
    }

    [super becomeFirstResponder];
    [self setNeedsLayout];

    return NO;
}

- (BOOL)acceptsFirstResponder
{
    var currentFirstResponder = [[self window] firstResponder];

    if ([currentFirstResponder isKindOfClass:[_NUNetworkElementTextField class]])
        currentFirstResponder = currentFirstResponder._delegate;

    if (currentFirstResponder === [self nextKeyView] && [self nextKeyView] != [self previousKeyView])
        _comesFromPrevious = YES;
    else
        _comesFromPrevious = NO;

    return [self isEnabled];
}

- (BOOL)isFirstResponder
{
    var firstResponder = [[self window] firstResponder];

    if (firstResponder == self || firstResponder == _fakeTextField)
        return YES;

    for (var i = [_networkElementTextFields count] - 1; i >= 0; i--)
    {
        if (_networkElementTextFields[i] == firstResponder)
            return YES;
    }

    return NO;
}

#pragma mark -
#pragma mark Accessors

- (void)setMode:(int)aMode
{
    if (aMode == _mode)
        return;

    [self willChangeValueForKey:@"mode"];
    _mode = aMode;
    [self didChangeValueForKey:@"mode"];

    [self setSeparatorValue:(_mode == NUNetworkMACMode || _mode == NUNetworkIPV6Mode) ? @":" : @"."]
    [self _populateNetworkElementTextFields]
}

- (void)setMask:(BOOL)aMask
{
    if (aMask == _mask)
        return;

    [self willChangeValueForKey:@"mask"];
    _mask = aMask;
    [self didChangeValueForKey:@"mask"];

    [self _populateNetworkElementTextFields]
}

/*!
    Make sure the control won't be editable
*/
- (void)setEditable:(BOOL)aBoolean
{
    [super setEditable:NO];
}

- (void)setNextKeyView:(CPView)aView
{
    [[_networkElementTextFields lastObject] setNextKeyView:aView];
    [super setNextKeyView:aView];
}

- (void)setShowCancelButton:(BOOL)aBoolean
{
    if (_showCancelButton == aBoolean)
        return;

    [self willChangeValueForKey:@"showCancelButton"];
    _showCancelButton = aBoolean;
    [self didChangeValueForKey:@"showCancelButton"];

    [self _updateCancelButtonVisibility];
}

#pragma mark -
#pragma mark Delegate

/*!
    Set the delegate
*/
- (void)setDelegate:(id)aDelegate
{
    if (aDelegate == _networkTextFieldDelegate)
        return;

    _networkTextFieldDelegate = aDelegate;
    _implementedNUNetworkTextFieldDelegateMethods = 0;

    if ([_networkTextFieldDelegate respondsToSelector:@selector(networkTextField:noMatchWithRegex:forValue:)])
        _implementedNUNetworkTextFieldDelegateMethods |= NUNetworkTextField_noMathWithRegex_forValue_;

    if ([_networkTextFieldDelegate respondsToSelector:@selector(networkTextField:matchWithRegex:forValue:)])
        _implementedNUNetworkTextFieldDelegateMethods |= NUNetworkTextField_mathWithRegex_forValue_;

    if ([_networkTextFieldDelegate respondsToSelector:@selector(networkTextField:errorMessage:forValue:)])
        _implementedNUNetworkTextFieldDelegateMethods |= NUNetworkTextField_errorMessage_forValue_;

    [super setDelegate:aDelegate];
}


#pragma mark -
#pragma mark IP Utilities

/*!
    Return an array with the digits of the objectValue.
    Call the delegateif there is an error
*/
- (CPArray)_digitsForIPValue:(id)anObjectValue
{
    var ips = (_mode === NUNetworkIPV6Mode) ? anObjectValue.split(@":") : anObjectValue.split(@"."),
        numberDigits = [ips count];

    if (_mode === NUNetworkIPV6Mode && numberDigits != 8)
    {
        [self _errorMessage:[CPString stringWithFormat:"ERROR: Invalid ip format IPV6: %@", anObjectValue]];
        return [];
    }

    if (_mode === NUNetworkIPV4Mode && numberDigits != 4)
    {
        [self _errorMessage:[CPString stringWithFormat:"ERROR: Invalid ip format IPV4: %@", anObjectValue]];
        return [];
    }

    return ips;
}

- (CPArray)_digitsForMACValue:(id)anObjectValue
{
    var macs = anObjectValue.split(@":"),
        numberDigits = [macs count];

    if (_mode === NUNetworkMACMode && numberDigits != 6)
    {
        [self _errorMessage:[CPString stringWithFormat:"ERROR: Invalid mac format: %@", anObjectValue]];
        return [];
    }

    return macs;
}

/*!
    Return a boolean to know if the value is an ip value
*/
- (BOOL)_isIPValue:(id)aValue
{
    if (aValue === null || aValue === undefined || [aValue length] == 0)
        return YES;

    if (_mode == NUNetworkIPV6Mode && [aValue length] > 4 && (aValue.search(/^[0-9A-Fa-f]{0,1,2,3,4}$/gi) == -1 || intFromHexa(aValue) > 65535))
    {
        [self _errorMessage:[CPString stringWithFormat:@"ERROR: Invalid IPV6 ip format : %@", aValue]];
        return NO;
    }

    if (_mode == NUNetworkIPV4Mode && !isIntegerNumber(aValue))
    {
        [self _errorMessage:[CPString stringWithFormat:@"ERROR: Invalid IPV4 ip format : %@", aValue]];
        return NO;
    }

    if (_mode == NUNetworkIPV4Mode && ([aValue length] > 3 || aValue > 255))
    {
        [self _errorMessage:[CPString stringWithFormat:@"ERROR: Invalid IPV4 ip format : %@", aValue]];
        return NO;
    }

    return YES;
}

/*!
    Return a boolean to know if the value is mask value
*/
- (BOOL)_isMaskValue:(id)aValue
{
    if (_mode == NUNetworkIPV6Mode)
    {
        if ([aValue length] > 3 || aValue > 128)
        {
            [self _errorMessage:[CPString stringWithFormat:@"ERROR: Invalid IPV6 mask ip format : %@", aValue]];
            return NO;
        }

        return YES
    }

    if (_mode == NUNetworkIPV4Mode)
    {
        if ([aValue length] > 2 || aValue > 32)
        {
            [self _errorMessage:[CPString stringWithFormat:@"ERROR: Invalid mask ip format : %@", aValue]];
            return NO;
        }

        return YES;
    }

    return YES;
}

- (BOOL)_isMACValue:(id)aValue
{
    if (!aValue)
        return YES;

    var isOk = aValue.search(/^[0-9A-Fa-f]{1,2}$/gi);

    if (isOk == -1)
    {
        [self _errorMessage:[CPString stringWithFormat:@"ERROR: Invalid mac format : %@", aValue]];
        return NO;
    }

    return YES;
}

/*!
    Return a boolean to know if the objectValue match the regexp
*/
- (BOOL)_checkValueWithRegex
{
    if (!_regexp)
        return YES;

    var stringValue = [self stringValue],
        match = stringValue.match(_regexp);

    if (match)
        [self _matchWithRegex:_regexp forValue:stringValue];
    else
        [self _noMatchWithRegex:_regexp forValue:stringValue];

    return match;
}


#pragma mark -
#pragma mark Accessors objectValue stringValue

- (CPString)stringValue
{
    return [self objectValue];
}

- (id)objectValue
{
    return _internObjectValue;
}

/*!
    Set the stringValue of the control
*/
- (void)setStringValue:(CPString)aStringValue
{
    [self setObjectValue:aStringValue];
}

/*!
    Set the objectValue of the control
    Here we check if the objectValue is a IP Value
*/
- (void)setObjectValue:(id)anObjectValue
{
    if (anObjectValue == nil)
        anObjectValue = @"";

    if (anObjectValue == @"" || anObjectValue == nil)
    {
        var number = [_networkElementTextFields count];

        for (var i = 0; i < number; i++)
        {
            var textField = _networkElementTextFields[i];
            [textField setNetworkValue:@""];
        }
    }
    else
    {
        if (_mode == NUNetworkMACMode)
        {
            var macs = [self _digitsForMACValue:anObjectValue],
                numberDigits = [macs count];

            if (numberDigits && [self _checkValueWithRegex])
            {
                _MACDigits = macs;

                for (var i = 0; i < numberDigits; i++)
                {
                    var digit = macs[i],
                        isMac = [self _setObjectValue:digit atIndex:i];

                    if (!isMac)
                    {
                        [self setObjectValue:_internObjectValue];
                        return;
                    }
                }
            }
            else
            {
                [self setObjectValue:_internObjectValue];
                return;
            }
        }
        else
        {
            var ips = [self _digitsForIPValue:anObjectValue],
                numberDigits = [ips count];

            if (numberDigits && [self _checkValueWithRegex])
            {
                _IPDigits = ips;

                for (var i = 0; i < numberDigits; i++)
                {
                    var digit = ips[i],
                        isIP = [self _setObjectValue:digit atIndex:i];

                    if (!isIP)
                    {
                        [self setObjectValue:_internObjectValue];
                        return;
                    }
                }
            }
            else
            {
                [self setObjectValue:_internObjectValue];
                return;
            }
        }

    }

    [self willChangeValueForKey:@"objectValue"];
    _internObjectValue = anObjectValue;
    [self didChangeValueForKey:@"objectValue"];

    [self setNeedsLayout];
}

/*!
    Set the objectValue of a textField
    @param anObjectValue the objectValue
    @param anIndex the index of the textField
    @return a boolean to know if the ip value was good or not
*/
- (BOOL)_setObjectValue:(id)anObjectValue atIndex:(int)anIndex
{
    var networkTextField = _networkElementTextFields[anIndex];

    if (_mode != NUNetworkMACMode && anIndex == ([_networkElementTextFields count] - 2) && _mask)
    {
        var elements = anObjectValue.split(@"/"),
            numberElements = [elements count];

        if (numberElements != 2)
        {
            [self _errorMessage:[CPString stringWithFormat:@"ERROR: Invalid ip/mask format : %@", anObjectValue]];
            return NO;
        }
        else if ([self _isIPValue:elements[0]] && [self _isMaskValue:elements[1]])
        {
            [[_networkElementTextFields lastObject] setNetworkValue:elements[1]];
            [networkTextField setNetworkValue:elements[0]];
        }
        else
        {
            return NO;
        }
    }
    else if (_mode != NUNetworkMACMode)
    {
        if (![self _isIPValue:anObjectValue])
            return NO;

        [networkTextField setNetworkValue:anObjectValue];
    }
    else if (_mode == NUNetworkMACMode)
    {
        if (![self _isMACValue:anObjectValue])
            return NO;

        [networkTextField setNetworkValue:anObjectValue];
    }

    return YES;
}


#pragma mark -
#pragma mark Layout methods

/*!
    Modifies the bounding rectangle for the cancel button.
    @param rect The updated bounding rectangle to use for the cancel button. The default value is the value passed into the rect parameter.
    Subclasses can override this method to return a new bounding rectangle for the cancel button. You might use this method to provide a custom layout for the search field control.
*/
- (CGRect)cancelButtonRectForBounds:(CGRect)rect
{
    var size = CGSizeMake(CGRectGetHeight(rect) - 8, CGRectGetHeight(rect) - 8);

    return CGRectMake(CGRectGetWidth(rect) - size.width - 5, (CGRectGetHeight(rect) - size.width) / 2, size.height, size.height);
}

- (void)_updateCancelButtonVisibility
{
    [_cancelButton setHidden:(!_showCancelButton || [_internObjectValue length] === 0 || ![self isEnabled])];
}

- (void)layoutSubviews
{
    [self _themeTextFields];
    [self _updatePlaceholderState];
    [self _updateCancelButtonVisibility];

    [super layoutSubviews];

    var contentView = [self layoutEphemeralSubviewNamed:@"content-view"
                                                 positioned:CPWindowAbove
                            relativeToEphemeralSubviewNamed:@"bezel-view"],
        showPlaceHolder = !(_internObjectValue && _internObjectValue.length > 0) && ![self isFirstResponder],
        firstNetWorkTextField = [_networkElementTextFields firstObject];

    [contentView setHidden:!showPlaceHolder];

    for (var i = [_separatorLabels count] - 1; i >= 0; i--)
    {
        var separatorLabel = _separatorLabels[i];
        [separatorLabel setHidden:showPlaceHolder];
    }

    if (showPlaceHolder)
    {
        [firstNetWorkTextField setAlignment:CPLeftTextAlignment];

        if ([[self window] firstResponder] == firstNetWorkTextField)
            [firstNetWorkTextField _inputElement].style.textAlign = "left";
    }
    else
    {
        [firstNetWorkTextField setAlignment:CPCenterTextAlignment];

        if ([[self window] firstResponder] == firstNetWorkTextField)
            [firstNetWorkTextField _inputElement].style.textAlign = "center";
    }

    // Trick to select the firstElement when nothing is set
    if (_currentNetworkTextField && _internObjectValue == @"")
    {
        var currentResponder = [[self window] firstResponder];
        _currentNetworkTextField = [_networkElementTextFields firstObject];

        if (currentResponder === [self nextKeyView])
        {
            _currentNetworkTextField = nil;
            [[self window] makeFirstResponder:[self nextKeyView]];
        }
        else
        {
            [[self window] makeFirstResponder:_currentNetworkTextField];
        }

        var number = [_networkElementTextFields count];

        for (var i = 0; i < number; i++)
        {
            var textField = _networkElementTextFields[i];
            [textField setStringValue:@""];
        }
    }
}

/*!
    Populate the control with several textFields
*/
- (void)_populateNetworkElementTextFields
{
    [_networkElementTextFields makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_separatorLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];

    var number = 4,
        size;

    _networkElementTextFields = [];
    _separatorLabels = [];

    if (_mode === NUNetworkIPV6Mode)
        number = 8;
    else if (_mode == NUNetworkMACMode)
        number = 6;

    if (_mask && _mode != NUNetworkMACMode)
        number++;

    for (var i = 0; i < number; i++)
    {
        var textField = [_NUNetworkElementTextField textFieldWithStringValue:@"" placeholder:@"" width:15];
        [textField _init];
        [textField setDelegate:self];
        [textField setTarget:self];
        [textField setAction:@selector(_networkTextFieldAction:)];
        //[textField setSendsActionOnEndEditing:YES];

        if (_mask && i == (number - 1) && _mode != NUNetworkMACMode)
            [textField setMask:YES];

        [_networkElementTextFields addObject:textField];
        [self addSubview:textField];

        if (i > 0)
        {
            var previousTextField = _networkElementTextFields[i - 1];

            [previousTextField setNextTextField:textField];
            [previousTextField setNextKeyView:textField];

            if (i == (number - 1))
               [textField setNextKeyView:[self nextKeyView]];
        }

        if (i == 0)
        {
            size = [textField frameSize];
            continue;
        }

        var separator;

        if (!_mask || i < (number - 1) || _mode == NUNetworkMACMode)
            separator = [_NUBasicNetworktextField labelWithTitle:_separatorValue || @"."];
        else
            separator = [_NUBasicNetworktextField labelWithTitle:_separatorMaskValue || @"/"];

        [separator setFrameSize:CGSizeMake([separator frameSize].width, size.height)];
        [separator setDelegate:self];
        [_separatorLabels addObject:separator];
        [self addSubview:separator];
    }

    [self setNeedsLayout];
}

/*!
    Theme the textFields
*/
- (void)_themeTextFields
{
    if ((_currentNetworkTextField || _selectAll) && [self isEnabled])
         [self setThemeState:CPThemeStateEditing];
    else
         [self unsetThemeState:CPThemeStateEditing];

    var number = [_networkElementTextFields count],
        textColor = _textColorSeparator;

    for (var i = 0; i < number; i++)
    {
        var textField = _networkElementTextFields[i],
            separator = _separatorLabels[i];

        [textField setEnabled:[self isEnabled]];
        [textField setAlignment:CPCenterTextAlignment];
        [textField setFont:[self font]];
        [textField setTextColor:[self textColor]];
        [textField setBordered:NO];
        [textField setBezeled:NO];

        [separator setEnabled:[self isEnabled]];
        [separator setFont:[self font]];
        [separator setTextColor:textColor];
        [separator setAlignment:CPCenterTextAlignment];
        [separator setBordered:NO];
        [separator setBezeled:NO];

        if (_currentNetworkTextField || _internObjectValue != @"")
            [separator setHidden:NO];
        else
            [separator setHidden:YES];
    }

    [self _updatePositionTextFields];
}

/*!
    Update the position of the textFields
*/
- (void)_updatePositionTextFields
{
    var number = [_networkElementTextFields count],
        contentInset = [self currentValueForThemeAttribute:@"content-inset"],
        sizeTextField = _mode == NUNetworkMACMode ? [[CPString stringWithString:@"12 "] sizeWithFont:[self font]] : _mode == NUNetworkIPV6Mode ? [[CPString stringWithString:@"1234 "] sizeWithFont:[self font]] : [[CPString stringWithString:@"123 "] sizeWithFont:[self font]],
        height = ([self frameSize].height - 2) / 2 - sizeTextField.height / 2;

    for (var i = 0; i < number; i++)
    {
        var textField = _networkElementTextFields[i],
            separator = _separatorLabels[i],
            x = i == 0 ? 0 + contentInset.left : CGRectGetMaxX([_separatorLabels[i - 1] frame]);

        [textField setFrame:CGRectMake(x, height, sizeTextField.width, [textField frameSize].height)];

        if (i < (number - 1))
            [separator setFrameOrigin:CGPointMake(CGRectGetMaxX([textField frame]), height + _verticalOffset)];
    }
}


#pragma mark -
#pragma mark Select textField methods

/*!
    Select the previous textField
*/
- (void)_selectPreviousTextField
{
    var index = [_networkElementTextFields indexOfObject:_currentNetworkTextField];

    if (index > 0)
        [self selectTextField:[_networkElementTextFields objectAtIndex:(index - 1)]];
}

/*!
    Select the next textField
*/
- (void)_selectNextTextField
{
    var index = [_networkElementTextFields indexOfObject:_currentNetworkTextField];

    if (index < ([_networkElementTextFields count] - 1))
        [self selectTextField:[_networkElementTextFields objectAtIndex:(index + 1)]];
}

/*!
    Select the given textField
*/
- (void)selectTextField:(_NUNetworkElementTextField)aTextField
{
    if (!aTextField || aTextField === _currentNetworkTextField)
        return;

    _currentNetworkTextField = aTextField;
    [[self window] makeFirstResponder:aTextField];
}


#pragma mark -
#pragma mark Override

- (void)_updatePlaceholderState
{
    if ([self _showPlaceHolder])
        [self setThemeState:CPTextFieldStatePlaceholder];
    else
        [self unsetThemeState:CPTextFieldStatePlaceholder];
}

- (void)_showPlaceHolder
{
    return (!_internObjectValue || _internObjectValue.length === 0) && ![self isFirstResponder];
}

#pragma mark -
#pragma mark Private delegate

/*!
    Delegate _textDidChange
    Here we change the objectValue of th control
*/
- (void)_textDidChange:(_NUNetworkElementTextField)aNetworkTextField
{
    var number = [_networkElementTextFields count],
        value = @"",
        isEmpty = YES;

    for (var i = 0; i < number; i++)
    {
        var textField = _networkElementTextFields[i],
            stringValue = [textField stringValue];

        value += stringValue;

        if (stringValue != @"")
            isEmpty = NO;

        if (i < number - 1)
            value += [_separatorLabels[i] stringValue];
    }

    [self setObjectValue:(isEmpty ? @"" : value)];
    [self textDidChange:[CPNotification notificationWithName:CPControlTextDidChangeNotification object:self userInfo:nil]];
}

- (void)_networkTextFieldAction:(id)sender
{
    [self sendAction:[self action] to:[self target]];
}

- (void)selectText:(id)sender
{
    [self selectAll];
}

- (void)selectAll
{
    if ([_internObjectValue length] == 0)
        return;

    _selectAll = YES;

    for (var i = [_networkElementTextFields count] - 1; i >= 0; i--)
    {
        var textField = _networkElementTextFields[i];
        [textField setNeedsDisplay:YES];
    }

    for (var i = [_separatorLabels count] - 1; i >= 0; i--)
    {
        var textField = _separatorLabels[i];
        [textField setNeedsDisplay:YES];
    }

    [[self superview] addSubview:_fakeTextField];
    [_fakeTextField setStringValue:_internObjectValue];
    [_fakeTextField selectAll:self];
}

- (void)_deselectAll
{
    for (var i = [_networkElementTextFields count] - 1; i >= 0; i--)
    {
        var textField = _networkElementTextFields[i];
        [textField setNeedsDisplay:YES];
    }

    for (var i = [_separatorLabels count] - 1; i >= 0; i--)
    {
        var textField = _separatorLabels[i];
        [textField setNeedsDisplay:YES];
    }

    if ([_fakeTextField superview])
        [_fakeTextField removeFromSuperview];
}

- (void)_cancelOperation:(id)sender
{
    _selectAll = NO;
    [self _deselectAll];
    [self setStringValue:@""];
    [self selectTextField:[_networkElementTextFields firstObject]];

    [self textDidChange:[CPNotification notificationWithName:CPControlTextDidChangeNotification object:self userInfo:nil]];
}


#pragma mark -
#pragma mark Mouse events

- (void)mouseDown:(CPEvent)anEvent
{
    [super mouseDown:anEvent];

    _doubleClick = YES;

    setTimeout(function(){_doubleClick = NO;}, 300);
}

#pragma mark -
#pragma mark Past Copy Cut methods

- (void)pasteString:(CPString)aString
{
    [self setStringValue:aString];

    var textField;

    for (var i = [_networkElementTextFields count] - 1; i >= 0; i--)
    {
        textField = _networkElementTextFields[i];

        if ([[textField stringValue] length])
            break;
    }

    [self selectTextField:textField];
    [textField setSelectedRange:CPMakeRange([[textField stringValue] length], 0)];
    [self textDidChange:[CPNotification notificationWithName:CPControlTextDidChangeNotification object:self userInfo:nil]];
}

@end


var NUNetworkMaskKey = @"NUNetworkMaskKey",
    NUNetworkMaskValueKey = @"NUNetworkMaskValueKey",
    NUNetworkSeparatorValueKey = @"NUNetworkSeparatorValueKey",
    NUNetworkModeKey = @"NUNetworkModeKey";

@implementation NUNetworkTextField (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
         [self _init];

         if ([aCoder containsValueForKey:NUNetworkMaskKey])
             [self setMask:[aCoder decodeBoolForKey:NUNetworkMaskKey]];

         [self setSeparatorMaskValue:[aCoder decodeObjectForKey:NUNetworkMaskValueKey] || @"/"];
         [self setSeparatorValue:[aCoder decodeObjectForKey:NUNetworkSeparatorValueKey] || @"."];
         [self setMode:[aCoder decodeIntForKey:NUNetworkModeKey] || NUNetworkIPV4Mode];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [self setSubviews:[]];

    [super encodeWithCoder:aCoder];

    [aCoder encodeBool:_mask forKey:NUNetworkMaskKey];
    [aCoder encodeObject:_separatorMaskValue forKey:NUNetworkMaskValueKey];
    [aCoder encodeObject:_separatorValue forKey:NUNetworkSeparatorValueKey];
    [aCoder encodeInt:_mode forKey:NUNetworkModeKey];
}

@end


@implementation NUNetworkTextField (NUNetworkTextFieldDelegate)

/*!
    Delegate _noMatchWithRegex:forValue:
    @param the regex
    @param aValue
*/
- (void)_noMatchWithRegex:(id)aRegex forValue:(CPString)aValue
{
    if (!(_implementedNUNetworkTextFieldDelegateMethods & NUNetworkTextField_noMathWithRegex_forValue_))
        return;

    [_networkTextFieldDelegate networkTextField:self noMatchWithRegex:aRegex forValue:aValue];
}

/*!
    Delegate _matchWithRegex:forValue:
    @param the regex
    @param aValue
*/
- (void)_matchWithRegex:(id)aRegex forValue:(CPString)aValue
{
    if (!(_implementedNUNetworkTextFieldDelegateMethods & NUNetworkTextField_mathWithRegex_forValue_))
        return;

    [_networkTextFieldDelegate networkTextField:self matchWithRegex:aRegex forValue:aValue];
}

/*!
    Delegate errorMessage
    @param aString the message
*/
- (void)_errorMessage:(CPString)aString
{
    if (!(_implementedNUNetworkTextFieldDelegateMethods & NUNetworkTextField_errorMessage_forValue_))
        return;

    [_networkTextFieldDelegate networkTextField:self errorMessage:aString];
}

@end

@implementation _NUBasicNetworktextField : CPTextField
{

}

- (BOOL)acceptsFirstResponder
{
    if (![_delegate isEditable] || ![_delegate isEnabled])
        return NO;

    var firstResponder = [[self window] firstResponder];

    if (![firstResponder isKindOfClass:_NUNetworkElementTextField] || [firstResponder delegate] != [self delegate])
    {
        var parent = [self delegate],
            index = [parent._separatorLabels indexOfObject:self],
            textField = parent._networkElementTextFields[index];

        setTimeout(function(){
            [[self window] makeFirstResponder:textField];
        }, 0);
    }

    return [super acceptsFirstResponder];
}

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        fontSize = [@" " sizeWithFont:[_delegate font] inWidth:0].height,
        bounds = [self bounds];

    if (_delegate._selectAll)
    {
        CGContextBeginPath(context);
        CGContextSetStrokeColor(context, SELECTING_COLOR);
        CGContextSetFillColor(context, SELECTING_COLOR);
        CGContextFillRect(context, CGRectMake(0, 1, bounds.size.width, fontSize));
        CGContextClosePath(context);
        CGContextStrokePath(context);
        CGContextFillPath(context);
    }
}

@end


@implementation _NUNetworkElementTextField : CPTextField
{
    _NUNetworkElementTextField  _nextTextField  @accessors(property=nextTextField);
    BOOL                        _mask           @accessors(getter=isMask, setter=setMask:);

    BOOL        _isPast;
    CPString    _lastValue;
}

+ (CPTextField)textFieldWithStringValue:(CPString)aStringValue placeholder:(CPString)aPlaceholder width:(float)aWidth
{
    return [super textFieldWithStringValue:aStringValue placeholder:aPlaceholder width:aWidth];
}

- (void)_init
{
    _mask = NO;
    _lastValue = [self stringValue];
}

/*!
    This method will set the _currentNetworkTextField of the delegate
*/
- (BOOL)becomeFirstResponder
{
    if (_delegate._selectAll)
        return NO;

    _delegate._currentNetworkTextField = self;

    if (_delegate._mode != NUNetworkMACMode && _mask && ![[self stringValue] length] && [[_delegate stringValue] length])
    {
        // TODO: compute the algo for the mask
        var networkElementTextFields = _delegate._networkElementTextFields,
            mask = (_delegate._mode == NUNetworkIPV4Mode) ? 32 : 128,
            stopMask = NO;

        for (var i = [networkElementTextFields count] - 1; i >= 0; i--)
        {
            var networkElementTextField = networkElementTextFields[i];

            if (![[networkElementTextField stringValue] length])
                [networkElementTextField setNetworkValue:@"0"];

            if (![networkElementTextField isMask] && [networkElementTextField stringValue] == @"0" && !stopMask)
                mask -= (_delegate._mode == NUNetworkIPV4Mode) ? 8 : 16;
            else if (parseInt([networkElementTextField stringValue]) > 0)
                stopMask = YES;
        }

        [self setNetworkValue:mask];
        [_delegate _textDidChange:self];
    }

    [_delegate setNeedsLayout];

    return [super becomeFirstResponder];
}

/*!
    This method will unset the _currentNetworkTextField of the delegate
*/
- (BOOL)resignFirstResponder
{
    _delegate._currentNetworkTextField = nil;
    [_delegate setNeedsLayout];

    return [super resignFirstResponder];
}

- (BOOL)acceptsFirstResponder
{
    return [_delegate acceptsFirstResponder];
}

/*!
    Key down method
    Here we check if we use the right/left arrow and the position of the cursor
*/
- (void)keyDown:(CPEvent)anEvent
{
    if (![self isEnabled])
        return;

    var key = [anEvent charactersIgnoringModifiers],
        keyCode =  [anEvent keyCode];

    if (key == CPSpaceFunctionKey)
    {
        if (_delegate._internObjectValue != @"")
        {
            [_delegate _deselectAll];
            [_delegate selectTextField:_nextTextField];
        }

        return;
    }

    [super keyDown:anEvent];
}

- (void)moveLeft:(id)sender
{
    var inputElement = [self _inputElement],
        value = inputElement.value,
        lastPosition = value.slice(0, inputElement.selectionStart).length;

    if (lastPosition === 0 && _delegate._internObjectValue != @"")
    {
        [_delegate _deselectAll];
        [_delegate _selectPreviousTextField];
    }
}

- (void)moveRight:(id)sender
{
    var inputElement = [self _inputElement],
        value = inputElement.value,
        lastPosition = value.slice(0, inputElement.selectionStart).length,
        length = [[self stringValue] length];

    if (lastPosition === length && _delegate._internObjectValue != @"")
    {
        [_delegate _deselectAll];
        [_delegate selectTextField:_nextTextField];
    }
}

- (void)cancelOperation:(id)sender
{
    [_delegate _deselectAll];
}

- (void)deleteBackward:(id)sender
{
    if (![[self stringValue] length])
    {
        [_delegate _selectPreviousTextField];
        [[[self window] platformWindow] _propagateCurrentDOMEvent:NO];
    }
}

- (BOOL)performKeyEquivalent:(CPEvent)anEvent
{
    var key = [anEvent charactersIgnoringModifiers],
        modifierFlags = [anEvent modifierFlags];

    if ([[self window] firstResponder] == self && key == @"a" && (modifierFlags & (CPCommandKeyMask | CPControlKeyMask)))
    {
        [_delegate selectAll];
        return YES;
    }

    return [super performKeyEquivalent:anEvent];
}

- (void)keyUp:(CPEvent)anEvent
{
    if (!_isPast)
    {
        [super keyUp:anEvent];
    }
    else
    {
        _isPast = NO;
        [_delegate pasteString:[self _inputElement].value];

        var textField;

        for (var i = [_delegate._networkElementTextFields count] - 1; i >= 0; i--)
        {
            textField = _delegate._networkElementTextFields[i];

            if ([[textField stringValue] length])
                break;
        }

        textField._willBecomeFirstResponderByClick = YES;
        [textField setSelectedRange:CPMakeRange([[textField stringValue] length],0)];
    }
}

- (void)textDidEndEditing:(CPNotification)aNotification
{
    if ([aNotification object] !== self || _delegate._selectAll)
        return;

    var textMovement = [[aNotification userInfo] objectForKey:@"CPTextMovement"],
        stringValue = [self stringValue],
        lengthStringValue = [[self stringValue] length],
        currentEvent = [CPApp currentEvent];

    switch (textMovement)
    {
        case CPCancelTextMovement:
            break;

        case CPLeftTextMovement:
        case CPRightTextMovement:

            if (!lengthStringValue && !_mask && _delegate._mode == NUNetworkIPV4Mode)
            {
                [self setNetworkValue:@"0"]
                [_delegate _textDidChange:self];
            }

            break;

        case CPUpTextMovement:
            break;

        case CPDownTextMovement:
            break;

        case CPReturnTextMovement:
            break;

        case CPBacktabTextMovement:

            if (!lengthStringValue && !_mask && _delegate._mode == NUNetworkIPV4Mode && [_delegate._internObjectValue length] > 0)
            {
                [self setNetworkValue:@"0"]
                [_delegate _textDidChange:self];
            }

            if (self == [_delegate._networkElementTextFields firstObject])
            {
                [_delegate textDidEndEditing:[CPNotification notificationWithName:CPControlTextDidEndEditingNotification object:_delegate userInfo:@{"CPTextMovement": textMovement}]];

                if ([_delegate sendsActionOnEndEditing])
                    [_delegate sendAction:[_delegate action] to:[_delegate target]]
            }

            break;

        case CPTabTextMovement:

            if (!lengthStringValue && !_mask && _delegate._mode == NUNetworkIPV4Mode && [_delegate._internObjectValue length] > 0)
            {
                [self setNetworkValue:@"0"]
                [_delegate _textDidChange:self];
            }

            if (self == [_delegate._networkElementTextFields lastObject])
            {
                [_delegate textDidEndEditing:[CPNotification notificationWithName:CPControlTextDidEndEditingNotification
                                                                           object:_delegate
                                                                         userInfo:@{"CPTextMovement": textMovement}]];

                if ([_delegate sendsActionOnEndEditing])
                    [_delegate sendAction:[_delegate action] to:[_delegate target]]
            }

            break;

        case CPOtherTextMovement:

            if ([currentEvent charactersIgnoringModifiers] == CPSpaceFunctionKey)
            {
                if (!lengthStringValue && !_mask && _delegate._mode == NUNetworkIPV4Mode)
                {
                    [self setNetworkValue:@"0"]
                    [_delegate _textDidChange:self];
                }

                break;
            }

            var lastClickPoint = [[CPApp currentEvent] locationInWindow],
                frame = [[_delegate superview] convertRectToBase:[_delegate frame]];

            if (!CGRectContainsPoint(frame, lastClickPoint))
            {
                [_delegate textDidEndEditing:[CPNotification notificationWithName:CPControlTextDidEndEditingNotification
                                                                           object:_delegate
                                                                         userInfo:@{"CPTextMovement": textMovement}]];

                if ([_delegate sendsActionOnEndEditing])
                    [_delegate sendAction:[_delegate action] to:[_delegate target]]
            }

            break;

        default:
            break;
    }
}

/*!
    Notification when the text change
    We check here what is the new character and how to handle it
    Here we may select the next/previous textField or send a message to the superIPtextField for saying that the ip just changed
*/
- (void)textDidChange:(CPNotification)aNotification
{
    if (_delegate._selectAll)
        return;

    [super textDidChange:aNotification];

    var currentValue = [self stringValue],
        length = [currentValue length],
        lastCharacter = [currentValue characterAtIndex:(length - 1)],
        firstCharacter = [currentValue characterAtIndex:0];

    if (_delegate._mode == NUNetworkMACMode)
    {
        if (self == [_delegate._networkElementTextFields lastObject] && length > 2)
            [self setObjectValue:[currentValue substringToIndex:2]];

        if (self != [_delegate._networkElementTextFields lastObject] && length == 2)
        {
            if (![_delegate _isMACValue:currentValue])
                [self setObjectValue:[currentValue substringToIndex:1]];
            else
                [_delegate selectTextField:_nextTextField];
        }

        [_delegate _textDidChange:self];

        return;
    }

    if (self != [_delegate._networkElementTextFields lastObject]
        && length > 1
        && (lastCharacter === _delegate._separatorValue && ![_nextTextField isMask]) || (lastCharacter === @"/" && [_delegate hasMask]))
    {
        if (lastCharacter === @"/")
        {
            [self setObjectValue:_lastValue];

            var networkElementTextFields = _delegate._networkElementTextFields;

            for (var i = [networkElementTextFields count] - 1; i >= 0; i--)
            {
                var networkElementTextField = networkElementTextFields[i];

                if ([networkElementTextField stringValue] === @"")
                    [networkElementTextField setObjectValue:@"0"];
            }

            [_delegate _textDidChange:self];
            [_delegate selectTextField:[networkElementTextFields lastObject]];
            return;
        }

        [self setObjectValue:_lastValue];
        [_delegate _textDidChange:self];
        [_delegate selectTextField:_nextTextField];
        return;
    }

    if (length == 1 && firstCharacter == @"0")
    {
        [self setObjectValue:@"0"];
        [_delegate _textDidChange:self];

        if (self != [_delegate._networkElementTextFields lastObject])
            [_delegate selectTextField:_nextTextField];

        return;
    }

    if (_delegate._mode == NUNetworkIPV4Mode)
    {
        if ((_mask && [currentValue length] > 2 || !isIntegerNumber(currentValue) || currentValue === @"")
            || (!_mask && [currentValue length] > 3 || !isIntegerNumber(currentValue) || currentValue === @"" || lastCharacter === @"."))
        {
            if (currentValue === @"")
                _lastValue = @"";
            else
                [self setObjectValue:_lastValue];
        }
        else
        {
            _lastValue = currentValue;

            if (length == 3 && self != [_delegate._networkElementTextFields lastObject])
            {
                [_delegate _textDidChange:self];
                [_delegate selectTextField:_nextTextField];
                return;
            }
        }
    }
    else if (_delegate._mode == NUNetworkIPV6Mode)
    {
        if ((_mask && ([currentValue length] > 3 || !isIntegerNumber(currentValue) || currentValue === @""))
            || (!_mask && [currentValue length] > 4 || currentValue === @"" || lastCharacter === @":" || !isHexaCharac(lastCharacter)))
        {
            if (currentValue === @"")
                _lastValue = @"";
            else
                [self setObjectValue:_lastValue];
        }
        else
        {
            _lastValue = currentValue;

            if (length == 4 && self != [_delegate._networkElementTextFields lastObject])
            {
                [_delegate _textDidChange:self];
                [_delegate selectTextField:_nextTextField];
                return;
            }
        }
    }

    [_delegate _textDidChange:self];
}

/*!
    Set the ip value to the control
    @param the ip value
*/
- (void)setNetworkValue:(CPString)aStringValue
{
    [self setObjectValue:aStringValue];
    _lastValue = aStringValue;
}

/*!
    Set the object value to the control. This method guarantes to only have integer
*/
- (void)setObjectValue:(id)anObjectValue
{
    anObjectValue = anObjectValue.toString();

    var length = [anObjectValue.toString() length];

    //Make sure to have an interger
    if (_delegate
        && _delegate._mode != NUNetworkMACMode
        && [anObjectValue characterAtIndex:(length - 1)] != _delegate._separatorValue
        && [anObjectValue characterAtIndex:(length - 1)] != @"/")
        {
            anObjectValue = (anObjectValue && _delegate._mode == NUNetworkIPV4Mode) ? parseInt(anObjectValue) : anObjectValue;
        }

    [super setObjectValue:anObjectValue];
}

/*!
    Return the previousKeyView who is the nextKeyView of the superNetworkTextField
    @return a view
*/
- (CPView)previousKeyView
{
    if (self === [_delegate._networkElementTextFields firstObject])
        return [_delegate previousKeyView];

    return [super previousKeyView];
}

- (CPView)nextKeyView
{
    if (_delegate._internObjectValue == @"")
        return [_delegate nextKeyView];

    return [super nextKeyView];
}


#pragma mark -
#pragma mark Copy methods

- (void)paste:(id)sender
{
    [self setStringValue:@""];
    _isPast = YES;
    [super paste:sender];
}


#pragma mark -
#pragma mark mouseDown event

- (void)mouseDown:(CPEvent)anEvent
{
    if (_delegate._doubleClick && [_delegate isSelectable])
        [_delegate selectAll];
    else if (![_delegate isEditable] && ![_delegate isEnabled] && ![_delegate isSelectable])
        [[self nextResponder] mouseDown:anEvent];
    else
        [super mouseDown:anEvent];

    _delegate._doubleClick = YES;

    setTimeout(function(){_delegate._doubleClick = NO;}, 300);
}


#pragma mark -
#pragma mark DrawRect

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        fontSize = [@" " sizeWithFont:[_delegate font] inWidth:0].height,
        bounds = [self bounds];

    if (_delegate._selectAll)
    {
        CGContextBeginPath(context);
        CGContextSetStrokeColor(context, SELECTING_COLOR);
        CGContextSetFillColor(context, SELECTING_COLOR);
        CGContextFillRect(context, CGRectMake(0, 1, bounds.size.width, fontSize));
        CGContextClosePath(context);
        CGContextStrokePath(context);
        CGContextFillPath(context);
    }
}

@end

/*! _NUFakeTextField is used for the event ctrl + a and ctrl + c.
    This create a textField with an opacity 0, and we redirect all the events to the real networktextField if needed
*/
@implementation _NUFakeTextField : CPTextField
{
    NUNetworkTextField _networkTextField @accessors(property=networkTextField);

    BOOL    _isPast;
    BOOL    _cursorToLastPosition;
}

- (id)init
{
    if (self = [super init])
    {
    }

    return self;
}

- (BOOL)acceptsFirstResponder
{
    return [super acceptsFirstResponder];
}

- (BOOL)resignFirstResponder
{
    if (!([super resignFirstResponder]))
        return NO;

    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // This is the trick to not display the textField, only way otherwise we can't catch up the events
    self._DOMElement.style.opacity = '0';
}

- (BOOL)performKeyEquivalent:(CPEvent)anEvent
{
    var key = [anEvent charactersIgnoringModifiers],
        modifierFlags = [anEvent modifierFlags];

    if ([[self window] firstResponder] == self && key == @"x" && (modifierFlags & (CPCommandKeyMask | CPControlKeyMask)))
    {
        setTimeout(function(){
            var textField = [_networkTextField._networkElementTextFields firstObject];
            [self _selectTextField:textField range:CPMakeRange(0,0)];

            [_networkTextField setStringValue:@""];
            [_networkTextField textDidChange:[CPNotification notificationWithName:CPControlTextDidChangeNotification object:_networkTextField userInfo:nil]];
        },0);

        return [super performKeyEquivalent:anEvent];
    }

    return [super performKeyEquivalent:anEvent];
}

- (void)moveLeft:(id)sender
{
    [self _selectFirstTextField];
}

- (void)moveDown:(id)sender
{
    [self _selectFirstTextField];
}

- (void)moveRight:(id)sender
{
    [self _selectLastValidTextField];
}

- (void)moveUp:(id)sender
{
    [self _selectLastValidTextField];
}

- (void)_selectLastValidTextField
{
    var textField;

    for (var i = [_networkTextField._networkElementTextFields count] - 1; i >= 0; i--)
    {
        textField = _networkTextField._networkElementTextFields[i];

        if ([[textField stringValue] length])
            break;
    }

    [self _selectTextField:textField range:CPMakeRange([[textField stringValue] length],0)];
}

- (void)_selectFirstTextField
{
    var textField = [_networkTextField._networkElementTextFields firstObject];
    [self _selectTextField:textField range:CPMakeRange(0,0)];
}

- (void)cancelOperation:(id)sender
{
    [self _selectFirstTextField];
}

- (void)deleteBackward:(id)sender
{
    if (![_networkTextField isEnabled])
        return;

    var textField = [_networkTextField._networkElementTextFields firstObject];
    [self _selectTextField:textField range:CPMakeRange(0,0)];
    [_networkTextField setStringValue:@""];
    [_networkTextField textDidChange:[CPNotification notificationWithName:CPControlTextDidChangeNotification object:_networkTextField userInfo:nil]];
}

- (void)keyDown:(CPEvent)anEvent
{
    var key = [anEvent charactersIgnoringModifiers],
        keyCode =  [anEvent keyCode],
        modifierFlags = [anEvent modifierFlags],
        mode = _networkTextField._mode;

    if (key == @"c" && (modifierFlags & (CPCommandKeyMask | CPControlKeyMask)))
        return;

    if (key == @"x" && (modifierFlags & (CPCommandKeyMask | CPControlKeyMask)))
        return;

    [self interpretKeyEvents:[anEvent]];

    if (![_networkTextField isEnabled])
        return;

    if (keyCode >= CPZeroKeyCode && keyCode <= CPNineKeyCode
        || ((mode == NUNetworkMACMode || mode == NUNetworkIPV6Mode) && ((keyCode >= CPZeroKeyCode && keyCode <= CPNineKeyCode) || (keyCode >= CPAKeyCode && keyCode <= CPFKeyCode))))
    {
        for (var i = [_networkTextField._networkElementTextFields count] - 1; i >= 0; i--)
        {
            var textField = _networkTextField._networkElementTextFields[i];

            if ([[textField stringValue] length] && i < [_networkTextField._networkElementTextFields count] - 1)
                [textField setStringValue:@""];
        }

        var textField = [_networkTextField._networkElementTextFields firstObject];

        [self _selectTextField:textField range:CPMakeRange(1,0)];

        if (mode == NUNetworkIPV4Mode)
            key += @"...";
        else if (mode == NUNetworkIPV6Mode)
            key += @":::::::";
        else if (mode == NUNetworkMACMode)
            key += @":::::";

        if (_networkTextField._mask && _networkTextField._mode != NUNetworkMACMode)
            key += @"/";

        [_networkTextField setStringValue:key];
        [_networkTextField textDidChange:[CPNotification notificationWithName:CPControlTextDidChangeNotification object:_networkTextField userInfo:nil]];
    }
}

- (void)keyUp:(CPEvent)anEvent
{
    if (!_isPast)
    {
        [super keyUp:anEvent];
    }
    else
    {
        _isPast = NO;
        _cursorToLastPosition = YES;
        [_networkTextField pasteString:[self _inputElement].value];
    }
}

/*! Needed when we lost the focus (tab or mouse event) when we have selected all
*/
- (void)textDidEndEditing:(CPNotification)aNotification
{
    if ([aNotification object] !== self || !_networkTextField._selectAll)
        return;

    var textMovement = [[aNotification userInfo] objectForKey:@"CPTextMovement"];

    switch (textMovement)
    {
        case CPCancelTextMovement:
        case CPDownTextMovement:
        case CPUpTextMovement:
        case CPLeftTextMovement:
            break;

        case CPRightTextMovement:
            break;

        case CPReturnTextMovement:
            break;

        case CPBacktabTextMovement:
        case CPTabTextMovement:
        case CPOtherTextMovement:

            if (_cursorToLastPosition)
            {
                _cursorToLastPosition = NO;

                var textField;

                for (var i = [_networkTextField._networkElementTextFields count] - 1; i >= 0; i--)
                {
                    textField = _networkTextField._networkElementTextFields[i];

                    if ([[textField stringValue] length])
                        break;
                }

                [self _selectTextField:textField range:CPMakeRange([[textField stringValue] length],0)];
            }
            else
            {
                [self _selectTextField:nil range:nil];
                [_networkTextField setNeedsLayout];
            }

            break;

        default:
            break;
    }
}

- (CPView)nextKeyView
{
    return [_networkTextField nextKeyView];
}

- (CPView)nextValidKeyView
{
    return [_networkTextField nextValidKeyView];
}

- (CPView)previousKeyView
{
    return [_networkTextField previousKeyView];
}

- (CPView)previousValidKeyView
{
    return [_networkTextField previousValidKeyView];
}

/*! This select the given textField of the networkTextField and put the position of the cursor to the given range
*/
- (void)_selectTextField:(_NUNetworkElementTextField)aNetworkTextField range:(CPRange)aRange
{
    _networkTextField._selectAll = NO;
    [_networkTextField _deselectAll];

    if (aNetworkTextField)
    {
        aNetworkTextField._willBecomeFirstResponderByClick = YES;
        [_networkTextField selectTextField:aNetworkTextField];
    }

    if (aRange)
        [aNetworkTextField setSelectedRange:aRange];
}

#pragma mark -
#pragma mark Copy methods

- (void)paste:(id)sender
{
    _isPast = YES;
    [super paste:sender];
}

@end
