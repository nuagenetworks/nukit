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
@import <AppKit/CPView.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPButton.j>

@import "NUSkin.j"


/*! NUOverlayTextField is a field used
    by NUModuleSelfParent to display general validation
    error. It's not meant to be used.
*/
@implementation NUOverlayTextField : CPView
{
    CPTextField _targetTextField    @accessors(getter=targetTextField);
    CPView      _targetView         @accessors(property=targetView);
    id          _delegate           @accessors(property=delegate);

    CPButton    _buttonDismiss;
    BOOL        _visible;

    CPButton    _previousDefaultButton;
    CPTextField _fieldDescription;
    CPTextField _fieldTitle;
    CPView      _viewContainer;
}

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        _visible = NO;

        // self
        var color = NUSkinColorWhite;
        [self setBackgroundColor:[CPColor colorWithCalibratedRed:[color redComponent] green:[color greenComponent] blue:[color blueComponent] alpha:0.9]];
        [self setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

        var containerFrame = CGRectMake(10, aFrame.size.height / 2 - 80, aFrame.size.width - 20, 160);
        _viewContainer = [[CPView alloc] initWithFrame:containerFrame];
        [_viewContainer setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin | CPViewMaxYMargin];
        [_viewContainer setBackgroundColor:NUSkinColorGreyLighter];
        [_viewContainer setBorderRadius:3.0];
        [_viewContainer setBorderColor:NUSkinColorGrey];
        [self addSubview:_viewContainer];

        // field title
        _fieldTitle = [CPTextField labelWithTitle:@""];
        [_fieldTitle setTextColor:NUSkinColorRed];
        [_fieldTitle setAlignment:CPCenterTextAlignment];
        [_fieldTitle setAutoresizingMask:CPViewWidthSizable];
        [_fieldTitle setLineBreakMode:CPLineBreakByTruncatingTail];
        [_fieldTitle setFont:[CPFont boldSystemFontOfSize:12]];

        var frame = [_fieldTitle frame];
        frame.origin.x = 10;
        frame.origin.y = 10;
        frame.size.width = containerFrame.size.width - 20;
        [_fieldTitle setFrame:frame];
        [_viewContainer addSubview:_fieldTitle];

        // field description
        _fieldDescription = [CPTextField labelWithTitle:@""];
        [_fieldDescription setTextColor:NUSkinColorBlack];
        [_fieldDescription setAlignment:CPCenterTextAlignment];
        [_fieldDescription setFrame:frame];
        [_fieldDescription setAutoresizingMask:CPViewWidthSizable];
        [_fieldDescription setLineBreakMode:CPLineBreakByWordWrapping];

        var frame = [_fieldDescription frame];
        frame.origin.y = 40;
        frame.origin.x = 10;
        frame.size.height = 100;
        frame.size.width = containerFrame.size.width - 20;
        [_fieldDescription setFrame:frame];
        [_viewContainer addSubview:_fieldDescription];

        // button dismiss
        _buttonDismiss = [CPButton buttonWithTitle:@"Dismiss"];
        [_buttonDismiss setTarget:self];
        [_buttonDismiss setAction:@selector(hide:)];
        [_buttonDismiss setCenter:[_viewContainer center]];
        [_buttonDismiss setAutoresizingMask:CPViewMinYMargin | CPViewMinXMargin | CPViewMaxXMargin];
        var buttonFrame = [_buttonDismiss frame];
        buttonFrame.size.width = 80;
        buttonFrame.origin.y = containerFrame.size.height - buttonFrame.size.height - 10;
        buttonFrame.origin.x = containerFrame.size.width / 2 - buttonFrame.size.width / 2;
        [_buttonDismiss setFrame:buttonFrame];
        [_viewContainer addSubview:_buttonDismiss];
    }

    return self;
}

- (void)setTargetTextField:(CPTextField)aTextField
{
    if (_targetTextField === aTextField)
        return;

    _targetTextField = aTextField;

    if (_targetTextField)
    {
        [_targetTextField addObserver:self forKeyPath:@"objectValue" options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
        [_targetTextField addObserver:self forKeyPath:@"toolTip" options:CPKeyValueObservingOptionNew | CPKeyValueObservingOptionOld context:nil];
        [_targetTextField setHidden:YES];
    }
    else
    {
        [_targetTextField removeObserver:self forKeyPath:@"objectValue"];
        [_targetTextField removeObserver:self forKeyPath:@"toolTip"];
    }
}

- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    if ([change objectForKey:CPKeyValueChangeOldKey] == [change objectForKey:CPKeyValueChangeNewKey])
        return;

    if ([[_targetTextField stringValue] length])
    {
         if (!_visible)
             [self show:nil];

         [_fieldTitle setStringValue:[_targetTextField toolTip]];
         [_fieldTitle setToolTip:[_targetTextField toolTip]];
         [_fieldDescription setStringValue:[_targetTextField stringValue]];
    }
    else
        [self hide:nil];
}

- (@action)show:(id)aSender
{
    if (!_targetView)
        return;

    [self setCenter:[_targetView center]];
    [self setFrame:[_targetView bounds]];
    [_targetView addSubview:self positioned:CPWindowAbove relativeTo:nil];

    var currentWindow = [self window];
    _previousDefaultButton = [currentWindow defaultButton];
    [currentWindow setDefaultButton:_buttonDismiss];

    _visible = YES;

    if (_delegate && [_delegate respondsToSelector:@selector(overlayTextFieldDidShow:)])
        [_delegate overlayTextFieldDidShow:self];
}

- (@action)hide:(id)aSender
{
    if (!_targetView)
        return;

    var currentWindow = [self window];
    [currentWindow setDefaultButton:_previousDefaultButton];

    _previousDefaultButton = nil;

    [self removeFromSuperview];
    _visible = NO;

    if (_delegate && [_delegate respondsToSelector:@selector(overlayTextFieldDidHide:)])
        [_delegate overlayTextFieldDidHide:self];
}

@end
