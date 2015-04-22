/*
****************************************************************************
*
*   Filename:         CPView+Border.j
*
*   Created:          Mon Apr  2 11:23:45 PST 2012
*
*   Description:      Cappuccino UI
*
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
*
*
***************************************************************************
*
*                 Source Control System Information
*
*   $Id: something $
*
*
*
****************************************************************************
*
* Copyright (c) 2011-2012 Alcatel, Alcatel-Lucent, Inc. All Rights Reserved.
*
* This source code contains confidential information which is proprietary to Alcatel.
* No part of its contents may be used, copied, disclosed or conveyed to any party
* in any manner whatsoever without prior written permission from Alcatel.
*
* Alcatel-Lucent is a trademark of Alcatel-Lucent, Inc.
*
*
*****************************************************************************
*/

@import <AppKit/CPView.j>
@import <AppKit/CPMenu.j>

@class CPTextField
@class CPCheckBox


var __origin_removeFromSuperview_Implementation = class_getMethodImplementation(CPView, @selector(removeFromSuperview));

/*! @ingroup categories
    Categories that allows CPView with border
*/
@implementation CPView (BorderedView)

- (void)_setBoxSizing
{
    self._DOMElement.style.boxSizing = @"border-box";
    self._DOMElement.style.MozBoxSizing = @"border-box";
    self._DOMElement.style.WebkitBoxSizing = @"border-box";
}

- (void)setBorderTopColor:(CPColor)aColor
{
    if (!aColor)
        self._DOMElement.style.borderTop = "";
    else
        self._DOMElement.style.borderTop = "1px solid " + [aColor cssString];
}

- (void)setBorderBottomColor:(CPColor)aColor
{
    [self _setBoxSizing];

    if (!aColor)
        self._DOMElement.style.borderBottom = "";
    else
        self._DOMElement.style.borderBottom = "1px solid " + [aColor cssString];
}

- (void)setBorderRightColor:(CPColor)aColor
{
    [self _setBoxSizing];

    if (!aColor)
        self._DOMElement.style.borderRight = "";
    else
        self._DOMElement.style.borderRight = "1px solid " + [aColor cssString];
}

- (void)setBorderLeftColor:(CPColor)aColor
{
    [self _setBoxSizing];

    if (!aColor)
        self._DOMElement.style.borderLeft = "";
    else
        self._DOMElement.style.borderLeft = "1px solid " + [aColor cssString];
}

- (void)setBorderColor:(CPColor)aColor
{
    [self _setBoxSizing];

    if (!aColor)
        self._DOMElement.style.border = "";
    else
        self._DOMElement.style.border = "1px solid " + [aColor cssString];
}

- (void)setBorderRadius:(int)aRadius
{
    [self _setBoxSizing];
    self._DOMElement.style.borderRadius = aRadius + "px";
}

- (void)setTopBorderRadius:(int)aRadius
{
    [self _setBoxSizing];
    self._DOMElement.style.borderTopLeftRadius = aRadius + "px";
    self._DOMElement.style.borderTopRightRadius = aRadius + "px";
}

- (void)setBottomBorderRadius:(int)aRadius
{
    [self _setBoxSizing];
    self._DOMElement.style.borderBottomLeftRadius = aRadius + "px";
    self._DOMElement.style.borderBottomRightRadius = aRadius + "px";
}



- (CPArray)subviewsWithTagLike:(id)aTag recursive:(BOOL)shouldLookTree
{
    var ret = [CPArray array],
        subviews = [self subviews];

    for (var i = [subviews count] - 1; i >= 0; i--)
    {
        var currentSubview = subviews[i];

        if ([currentSubview tag] && [[currentSubview tag] isKindOfClass:CPString] && [currentSubview tag].indexOf(aTag) != -1)
            [ret addObject:currentSubview];
        else if (shouldLookTree)
            [ret addObjectsFromArray:[currentSubview subviewsWithTagLike:aTag recursive:YES]];
    }

    return ret;
}

- (CPArray)subviewsWithTagLike:(id)aTag
{
    return [self subviewWithTagLike:aTag recursive:NO];
}


- (void)subviewWithTag:(id)aTag recursive:(BOOL)shouldLookTree
{
    var subviews = [self subviews];

    for (var i = [subviews count] - 1; i >= 0; i--)
    {
        var currentSubview = subviews[i];

        if ([currentSubview tag] == aTag)
            return currentSubview;
        else if (shouldLookTree)
        {
            var s = [currentSubview subviewWithTag:aTag recursive:YES];
            if (s)
                return s;
        }
    }
}

- (void)subviewWithTag:(id)aTag
{
    return [self subviewWithTag:aTag recursive:NO];
}

- (void)subviewsWithTag:(id)aTag recursive:(BOOL)shouldLookTree
{
    var ret = [CPArray array],
        subviews = [self subviews];

    for (var i = [subviews count] - 1; i >= 0; i--)
    {
        var currentSubview = subviews[i];

        if ([currentSubview tag] == aTag)
            [ret addObject:currentSubview];
        else if (shouldLookTree)
            [ret addObjectsFromArray:[currentSubview subviewsWithTag:aTag recursive:YES]];
    }

    return ret;
}

- (void)subviewsWithTag:(id)aTag
{
    return [self subviewsWithTag:aTag recursive:NO];
}

- (void)subviewWithIdentifier:(id)anIdentifier
{
    var subviews = [self subviews];

    for (var i = [subviews count] - 1; i >= 0; i--)
    {
        var currentSubview = subviews[i];

        if ([currentSubview identifier] == anIdentifier)
            return currentSubview;
    }
}


#pragma mark -
#pragma mark Animations

- (void)setInAnimation:(CPString)anAnimationName duration:(float)aDuration
{
    self.__in_animation_name = anAnimationName;
    self.__in_animation_duration = aDuration + @"s";
}

- (void)setOutAnimation:(CPString)anAnimationName duration:(float)aDuration
{
    self.__out_animation_name = anAnimationName;
    self.__out_animation_duration = aDuration + @"s";
}

- (void)viewDidMoveToSuperview
{
    if (self.__in_animation_name)
    {
        self._DOMElement.style.WebkitAnimationName = self.__in_animation_name;
        self._DOMElement.style.WebkitAnimationDuration = self.__in_animation_duration;
        self._DOMElement.style.MozAnimationName = self.__in_animation_name;
        self._DOMElement.style.MozAnimationDuration = self.__in_animation_duration;
        self._DOMElement.style.animationName = self.__in_animation_name;
        self._DOMElement.style.animationDuration = self.__in_animation_duration;
    }

    [self setNeedsDisplay:YES];
}

- (void)removeFromSuperview
{
    if (!_superview)
        return;

    if (!self.__out_animation_name)
    {
        __origin_removeFromSuperview_Implementation(self, nil);
        return;
    }

    var onAnimatinonEnd = function() {
        this.removeEventListener("webkitAnimationEnd", arguments.callee, NO);
        this.removeEventListener("animationend", arguments.callee, NO);
        __origin_removeFromSuperview_Implementation(self, nil);
    }

    self._DOMElement.addEventListener("webkitAnimationEnd", onAnimatinonEnd, NO);
    self._DOMElement.addEventListener("animationend", onAnimatinonEnd, NO);

    self._DOMElement.style.WebkitAnimationName = self.__out_animation_name;
    self._DOMElement.style.WebkitAnimationDuration = self.__out_animation_duration;
    self._DOMElement.style.MozAnimationName = self.__out_animation_name;
    self._DOMElement.style.MozAnimationDuration = self.__out_animation_duration;
    self._DOMElement.style.animationName = self.__out_animation_name;
    self._DOMElement.style.animationDuration = self.__out_animation_duration;
}

- (void)setValueTransformerName:(CPString)aTransformerName
{
    self.__valueTransformerName = aTransformerName;
}

- (CPString)valueTransformerName
{
    return self.__valueTransformerName;
}

- (void)rightMouseDown:(CPEvent)anEvent
{
    var menu = [self menuForEvent:anEvent];

    if (menu)
        [CPMenu popUpContextMenu:menu withEvent:anEvent forView:self];
    else if ([self isKindOfClass:CPTextField] && [self isEditable] && [self isEnabled])
        [[[anEvent window] platformWindow] _propagateContextMenuDOMEvent:YES];
    else if ([[self nextResponder] isKindOfClass:CPView])
        [super rightMouseDown:anEvent];
}
@end
