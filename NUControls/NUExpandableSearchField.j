/*
*   Filename:         NUExpandableSearchField.j
*   Created:          Thu Jul 3 13:09:18 PDT 2014
*   Author:           Christophe Serafin <christophe.serafin@alcatel-lucent.com>
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
@import <AppKit/CPSearchField.j>
@import <AppKit/CPViewAnimation.j>

@class _CPPopoverWindow

@global CPApp


@implementation NUExpandableSearchField : CPSearchField
{
    BOOL                _isExpanded         @accessors(property=isExpanded);
    CPViewAnimation     _animation;
    int                 _contractedWidth;
    int                 _expandedWidth;

    id                  _timeout;
}

- (void)awakeFromCib
{
    _expandedWidth = 150;
    _contractedWidth = 22;
    _timeout = nil;

    _animation = [[CPViewAnimation alloc] initWithDuration:0.2 animationCurve:CPAnimationEaseInOut];
    [_animation setDelegate:self];

    [self _contractWithAnimation:NO];
}


#pragma mark -
#pragma mark Overrides

- (void)textDidBlur:(CPNotification)aNotification
{
    if ([self isExpanded] && [[self stringValue] length] == 0)
        [self _contractWithAnimation:YES];

    [super textDidBlur:aNotification];
}

- (BOOL)becomeFirstResponder
{
    if ([self isExpanded])
        return [super becomeFirstResponder];

    return NO;
}

- (CPView)hitTest:(CGPoint)aPoint
{
    var keyWindow = [CPApp keyWindow];

    if ([keyWindow isKindOfClass:_CPPopoverWindow] && keyWindow != [self window])
        return nil;

    return [super hitTest:aPoint];
}


#pragma mark -
#pragma mark Mouse and Keyboard events

- (void)mouseDown:(CPEvent)anEvent
{
    if (_timeout || [_animation isAnimating])
        return;

    if (![self isExpanded])
    {
        _timeout = setTimeout(function()
        {
            if ([[CPApp currentEvent] clickCount] === 1)
                [self _expandWithAnimation:YES];

            else if ([[CPApp currentEvent] clickCount] === 2 && [[self searchButton] target] && [[self searchButton] action])
                [[self searchButton] mouseDown:[CPApp currentEvent]];

            _timeout = nil;
        }, 300);
    }
    else
    {
        [super mouseDown:anEvent];
    }
}

- (BOOL)performKeyEquivalent:(CPEvent)anEvent
{
    var key = [anEvent charactersIgnoringModifiers];

    if (key === CPEscapeFunctionKey && [[self window] firstResponder] == self)
    {
        [self _simulateCancelOperation];
    }

    return [super performKeyEquivalent:anEvent];
}

- (void)setStringValue:(CPString)aString
{
    if ([aString length] > 0 && ![self isExpanded])
        [self _expandWithAnimation:YES];

    if ([aString length] == 0 && [self isExpanded])
    {
        [self _simulateCancelOperation];
        [self _contractWithAnimation:YES];
    }

    [super setStringValue:aString];
}

- (void)_simulateCancelOperation
{
    if ([[self stringValue] length] > 0)
        [self cancelOperation:[self cancelButton]];

    [[self window] makeFirstResponder:nil];
}


#pragma mark -
#pragma mark Animations

- (void)_contractWithAnimation:(bool)shouldAnimate
{
    var frame = [self frame],
        mask = [self autoresizingMask];

    _expandedWidth = [self _widthFromSuperView];

    if (!(mask & CPViewMaxXMargin))
        frame.origin.x = frame.origin.y + _expandedWidth - _contractedWidth;

    frame.size.width = _contractedWidth;

    if (shouldAnimate)
    {
        var animationInfo = @{
                CPViewAnimationTargetKey: self,
                CPViewAnimationStartFrameKey: [self frame],
                CPViewAnimationEndFrameKey: frame,
                CPViewAnimationEffectKey: CPAnimationEaseInOut
            };

        [_animation setViewAnimations:[animationInfo]];
        [_animation startAnimation];
    }
    else
        [self setFrame:frame];

    [self setIsExpanded:NO];

}

- (void)_expandWithAnimation:(bool)shouldAnimate
{
    var frame = [self frame],
        mask = [self autoresizingMask];

    _expandedWidth = [self _widthFromSuperView];
    frame.size.width = _expandedWidth;

    if (!(mask & CPViewMinXMargin))
        frame.size.width = _expandedWidth - frame.origin.x;

    if (!(mask & CPViewMaxXMargin))
        frame.origin.x = frame.origin.x - _expandedWidth + _contractedWidth;

    if (shouldAnimate)
    {
        var animationInfo = @{
                CPViewAnimationTargetKey: self,
                CPViewAnimationStartFrameKey: [self frame],
                CPViewAnimationEndFrameKey: frame,
                CPViewAnimationEffectKey: CPAnimationEaseInOut
            };

        [_animation setViewAnimations:[animationInfo]];
        [_animation startAnimation];
    }
    else
    {
        [self setFrame:frame];
        [self becomeFirstResponder];
    }

    [self setIsExpanded:YES];

}

- (void)animationDidEnd:(CPAnimation)anAnimation
{
    var mask = [self autoresizingMask];

    if ([self isExpanded])
    {
        [[self window] makeFirstResponder:self];
        [self setAutoresizingMask: mask | CPViewMinXMargin | CPViewWidthSizable];
    }
    else
    {
        [self setAutoresizingMask: mask & ~CPViewWidthSizable];
    }

}


#pragma mark -
#pragma mark Private methods

- (int)_widthFromSuperView
{
    // Left and right margins are set to top margin to center the input field
    return [[self superview] frameSize].width - (2 * [self frameOrigin].y);
}

@end
