/*
*   Filename:         NUHoverView.j
*   Created:          Fri Jul 26 14:03:00 PDT 2013
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
@import <AppKit/CPControl.j>
@import <AppKit/CPView.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPViewAnimation.j>

@global CPApp

NUHoverViewTriggerWidth = 10;

var NUHoverViewDelegate_hoverViewDidShow    = 1 << 1,
    NUHoverViewDelegate_hoverViewDidHide    = 1 << 2;


@implementation NUHoverView : CPControl
{
    BOOL                _animates       @accessors(property=animates);
    BOOL                _visible        @accessors(getter=isVisible, setter=setVisible:);
    CPView              _documentView   @accessors(getter=documentView);
    id                  _delegate       @accessors(property=delegate);
    int                 _width          @accessors(property=width);

    CPImageView         _handleView;
    CPTimer             _timerShow;
    CPView              _contentView;
    CPView              _triggerView;
    CPViewAnimation     _animation;
    int                 _implementedDelegateMethods;
}


#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
        [self _init];

    return self;
}

- (void)_init
{
    _visible = YES;
    _animates = YES;
    _width = 150;

    var frame = [self frame];

    _contentView = [[CPView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    [_contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [self addSubview:_contentView];

    _triggerView = [[CPView alloc] initWithFrame:CGRectMake(frame.size.width - NUHoverViewTriggerWidth, 0.0, NUHoverViewTriggerWidth, frame.size.height)];
    [_triggerView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];
    [self addSubview:_triggerView];

    _handleView = [[CPImageView alloc] initWithFrame:CGRectMake(0, 0, 3, 13)];
    [_handleView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [_handleView setImage:CPImageInBundle(@"hoover-view-handle.png", 3, 13)];
    [_handleView setCenter:CGPointMake(CGRectGetMidX([_triggerView bounds]), CGRectGetMidY([_triggerView bounds]))];
    [_triggerView addSubview:_handleView];

    [_triggerView setBorderRightColor:NUSkinColorGreyLight];
    [_triggerView setBackgroundColor:NUSkinColorGreyLight];

    _animation = [[CPViewAnimation alloc] init];
    [_animation setDelegate:self];
    [_animation setAnimationCurve:CPAnimationLinear];
    [_animation setDuration:0.1];

    [self hideWithAnimation:NO];
}


#pragma mark -
#pragma mark Visibility

- (void)hideWithAnimation:(BOOL)shouldAnimate
{
    if (!_visible)
        return;

    if ([self window] != [CPApp keyWindow])
        return;

    if (shouldAnimate && [_animation isAnimating])
        return;

    _visible = NO;

    self._DOMElement.style.boxShadow = "";

    [_triggerView setHidden:NO];

    var frame = [self frame];
    frame.size.width = NUHoverViewTriggerWidth;

    if (shouldAnimate)
    {
        var animInfo = @{CPViewAnimationTargetKey: self, CPViewAnimationStartFrameKey: [self frame], CPViewAnimationEndFrameKey: frame};
        [_animation setViewAnimations:[animInfo]]
        [_animation startAnimation];
    }
    else
        [self setFrame:frame];

    [self _sendDelegateDidHide];
}

- (void)showWithAnimation:(BOOL)shouldAnimate
{
    if (_visible)
        return;

    if (shouldAnimate && [_animation isAnimating])
        return;

    _visible = YES;
    self._DOMElement.style.boxShadow = "0 0 10px " + [NUSkinColorGrey cssString];

    [_triggerView setHidden:YES];

    var frame = [self frame];
    frame.size.width = _width;

    if (shouldAnimate)
    {
        var animInfo = @{ CPViewAnimationTargetKey: self, CPViewAnimationStartFrameKey: [self frame], CPViewAnimationEndFrameKey: frame};
        [_animation setViewAnimations:[animInfo]]
        [_animation startAnimation];
    }
    else
        [self setFrame:frame];

    [self _sendDelegateDidShow];
}


#pragma mark -
#pragma mark Delegate Management

- (void)setDelegate:(id)aDelegate
{
    if (aDelegate == _delegate)
        return;

    _delegate = aDelegate;
    _implementedDelegateMethods = 0;

    if ([_delegate respondsToSelector:@selector(hoverViewDidShow:)])
        _implementedDelegateMethods |= NUHoverViewDelegate_hoverViewDidShow;

    if ([_delegate respondsToSelector:@selector(hoverViewDidHide:)])
        _implementedDelegateMethods |= NUHoverViewDelegate_hoverViewDidHide;
}

- (void)_sendDelegateDidShow
{
    if (_implementedDelegateMethods & NUHoverViewDelegate_hoverViewDidShow)
        [_delegate hoverViewDidShow:self];
}

- (void)_sendDelegateDidHide
{
    if (_implementedDelegateMethods & NUHoverViewDelegate_hoverViewDidHide)
        [_delegate hoverViewDidHide:self];
}


#pragma mark -
#pragma mark Content Management

- (void)setDocumentView:(CPView)aView
{
    if (aView == _documentView)
        return;

    _documentView = aView;

    [_contentView addSubview:_documentView];
}

- (CGSize)contentSize
{
    return [_contentView frameSize];
}


#pragma mark -
#pragma mark Mouse Management

- (void)timerDidEnd:(CPTimer)aTimer
{
    if (![self isEnabled])
        return;

    [self showWithAnimation:_animates];
}

- (void)mouseEntered:(CPEvent)anEvent
{
    [_timerShow invalidate];

    [super mouseEntered:anEvent];

    if (![self isEnabled])
        return;

    if ([CPApp keyWindow] != [self window])
        return;

    var point = [self convertPointFromBase:[anEvent locationInWindow]],
        frame = [_triggerView frame];

    frame.size.height -= 30;

    if (CGRectContainsPoint(frame, point))
    {
        var middlePart = CGRectInset(frame, 0, frame.size.height / 3);

        if (CGRectContainsPoint(middlePart, point))
            [self showWithAnimation:_animates];
        else
            _timerShow = [CPTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(timerDidEnd:) userInfo:nil repeats:NO];
    }
}

- (void)mouseExited:(CPEvent)anEvent
{
    [super mouseExited:anEvent];

    if (![self isEnabled])
        return;

    var point = [self convertPointFromBase:[anEvent locationInWindow]];

    if (!CGRectContainsPoint(CGRectInsetByInset([self frame], CGInsetMake(-100, 0, -100, 0)), point))
    {
        [_timerShow invalidate];
        [self hideWithAnimation:_animates];
    }
}

- (void)setEnabled:(BOOL)isEnabled
{
    [super setEnabled:isEnabled];

    var color = [NUSkinColorGrey cssString];

    if (_visible)
        self._DOMElement.style.boxShadow = !isEnabled ? "0 0 1px " + color  :  "0 0 10px " + color;
    else
        self._DOMElement.style.boxShadow = !isEnabled ? "0 0 1px " + color :  "";
}


#pragma mark -
#pragma mark CPCoding

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
        [self _init];
    return self;
}

@end
