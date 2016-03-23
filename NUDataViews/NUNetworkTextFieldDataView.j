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

@import "NUAbstractDataView.j"
@import "NUNetworkTextField.j"

@implementation NUNetworkTextFieldDataView : NUAbstractDataView
{
    @outlet NUNetworkTextField  fieldNetwork;

    BOOL _isObservedFirstResponder;
}


#pragma mark -
#pragma mark Data View Protocol

- (void)bindDataView
{
    [super bindDataView];
    [fieldNetwork bind:CPValueBinding toObject:_objectValue withKeyPath:@"self" options:nil];
}

- (void)setObjectValue:(id)anObjectValue
{
    if (!anObjectValue)
        [fieldNetwork setObjectValue:nil];

    [super setObjectValue:anObjectValue]
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Mouse event

- (void)_startObservingFirstResponderForWindow:(CPWindow)aWindow
{
    _isObservedFirstResponder = YES;
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_firstResponderDidChange:) name:_CPWindowDidChangeFirstResponderNotification object:aWindow];
}

- (void)_stopObservingFirstResponderForWindow:(CPWindow)aWindow
{
    _isObservedFirstResponder = NO;
    [[CPNotificationCenter defaultCenter] removeObserver:self name:_CPWindowDidChangeFirstResponderNotification object:aWindow];
}

- (void)viewWillMoveToWindow:(CPWindow)aWindow
{
    [self _stopObservingFirstResponderForWindow:[self window]];
}

- (void)_firstResponderDidChange:(CPNotification)aNotification
{
    [self setNeedsLayout];

    if ([fieldNetwork isFirstResponder])
        return;

    [fieldNetwork setBezeled:NO];
    [fieldNetwork setEnabled:NO];
    [fieldNetwork setSelectable:NO];
    [fieldNetwork setEditable:NO];
}

- (void)mouseDown:(CPEvent)anEvent
{
    var window = [self window];

    if (!_isObservedFirstResponder)
        [self _startObservingFirstResponderForWindow:window];

    if ([anEvent clickCount] == 2 && ![fieldNetwork isFirstResponder])
    {
        [fieldNetwork setSelectable:YES];
        [fieldNetwork setBezeled:YES];
        [fieldNetwork setEnabled:YES];
        [fieldNetwork setEditable:YES];
        fieldNetwork._doubleClick = YES;
        [window makeFirstResponder:fieldNetwork];
        return;
    }

    [super mouseDown:anEvent];
}


#pragma mark -
#pragma mark Override

- (void)layoutSubviews
{
    if ([fieldNetwork isFirstResponder])
    {
        [fieldNetwork setFrameOrigin:CGPointMake(-1, -1)];
    }
    else
    {
        var inset = [fieldNetwork valueForThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];

        if ([fieldNetwork _shouldShowPlaceHolder])
            [fieldNetwork setFrameOrigin:CGPointMake(inset.left - 1, inset.top)];
        else
            [fieldNetwork setFrameOrigin:CGPointMake(inset.left - 1, -1)];
    }

    if (![fieldNetwork isFirstResponder] && [self hasThemeState:CPThemeStateSelectedDataView])
    {
        [fieldNetwork setTextColor:[CPColor whiteColor]];
        [fieldNetwork setTextColorSeparator:[CPColor whiteColor]];
    }
    else
    {
        [fieldNetwork setTextColor:[CPColor blackColor]];
        [fieldNetwork setTextColorSeparator:[CPColor blackColor]];
    }
}

#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldNetwork = [aCoder decodeObjectForKey:@"fieldNetwork"];
        [fieldNetwork setMask:NO];
        [fieldNetwork setBezeled:NO];
        [fieldNetwork setEnabled:NO];
        [fieldNetwork setSelectable:NO];
        [fieldNetwork setEditable:NO];
        fieldNetwork._isTableViewNetworktextField = YES;
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldNetwork forKey:@"fieldNetwork"];
}

@end
