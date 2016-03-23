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
