/*
*   Filename:         CPMenuItem+Better
*   Created:          Wed Jan 29 21:44:02 PST 2014
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
