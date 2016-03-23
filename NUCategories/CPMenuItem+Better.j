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

@import <AppKit/CPMenuItem.j>

@global CPApp


@implementation CPMenuItem (noview)

- (CPView)view
{
    return nil;
}

@end


@implementation _CPMenuItemView (trick)

- (void)synchronizeWithMenuItem
{
    var menuItemView = _menuItem._view; // the trick is here. all the rest is the same than the original class

    if ([_menuItem isSeparatorItem])
    {
        if (![_view isKindOfClass:[_CPMenuItemSeparatorView class]])
        {
            [_view removeFromSuperview];
            _view = [_CPMenuItemSeparatorView view];
        }
    }
    else if (menuItemView)
    {
        if (_view !== menuItemView)
        {
            [_view removeFromSuperview];
            _view = menuItemView;
        }
    }
    else if ([_menuItem menu] == [CPApp mainMenu])
    {
        if (![_view isKindOfClass:[_CPMenuItemMenuBarView class]])
        {
            [_view removeFromSuperview];
            _view = [_CPMenuItemMenuBarView view];
        }

        [_view setMenuItem:_menuItem];
    }
    else
    {
        if (![_view isKindOfClass:[_CPMenuItemStandardView class]])
        {
            [_view removeFromSuperview];
            _view = [_CPMenuItemStandardView view];
        }

        [_view setMenuItem:_menuItem];
    }

    if ([_view superview] !== self)
        [self addSubview:_view];

    if ([_view respondsToSelector:@selector(update)])
        [_view update];

    _minSize = [_view frame].size;
    [self setAutoresizesSubviews:NO];
    [self setFrameSize:_minSize];
    [self setAutoresizesSubviews:YES];
}

@end
