/*
*   Filename:         NUStackView.j
*   Created:          Wed Jul 17 13:22:26 PDT 2013
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
@import <AppKit/CPView.j>


NUStackViewModeHorizontal = 1;
NUStackViewModeVertical   = 2;


/*! NUStackView allows to always layout its subviews
    in a ordered stack. It has two modes:

    [stackView setMode:NUStackViewModeHorizontal];
    [stackView setMode:NUStackViewModeVertical];

    And the margin between the stacked subview can be set using:

    [stackView setMargin:CGInsetMake(3, 3, 3, 3)];
*/
@implementation NUStackView : CPView
{
    int     _mode   @accessors(property=mode);
    CGInset _margin @accessors(property=margin);
}


#pragma mark -
#pragma mark Initialization

/*! @ignore
*/
- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
        [self _init];

    return self;
}

/*! @ignore
*/
- (void)_init
{
    _mode = _mode || NUStackViewModeVertical;
    _margin = _margin || CGInsetMakeZero();
}


#pragma mark -
#pragma mark Layout

/*! @ignore
*/
- (void)layoutSubviews
{
    if (_mode == NUStackViewModeVertical)
        [self _layoutVertical];
    else
        [self _layoutHorizontal];
}

/*! @ignore
*/
- (void)_layoutVertical
{
    var views     = [self subviews],
        frame     = [self frame],
        width     = frame.size.width,
        currentY  = _margin.top;

    for (var i = 0, c = [views count]; i < c; i++)
    {
        var currentView  = views[i],
            currentFrame = [currentView frame];

        currentFrame.origin.x   = _margin.left;
        currentFrame.origin.y   = currentY;
        currentFrame.size.width = width - _margin.left - _margin.right;

        [currentView setAutoresizingMask:CPViewWidthSizable];
        [currentView setFrame:currentFrame];

        currentY += currentFrame.size.height + _margin.bottom;
    }

    frame.size.height = currentY;

    [self setFrame:frame];
}

/*! @ignore
*/
- (void)_layoutHorizontal
{
    var views     = [self subviews],
        frame     = [self frame],
        height    = frame.size.height,
        currentX  = _margin.left;

    for (var i = 0, c = [views count]; i < c; i++)
    {
        var currentView  = views[i],
            currentFrame = [currentView frame];

        currentFrame.origin.x   = currentX;
        currentFrame.origin.y   = _margin.top;
        currentFrame.size.height = height - _margin.top - _margin.bottom;

        [currentView setAutoresizingMask:CPViewHeightSizable];
        [currentView setFrame:currentFrame];

        currentX += currentFrame.size.width + _margin.right;
    }

    frame.size.width = currentX;

    [self setFrame:frame];
}

#pragma mark -
#pragma mark CPCoding compliance

/*! @ignore
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
        [self _init]

    return self;
}

@end
