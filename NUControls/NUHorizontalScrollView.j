/*
*   Filename:         NUHorizontalScrollView.j
*   Created:          Thu Feb 27 19:42:36 PST 2014
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

@import <AppKit/CPScrollView.j>


/*! NUHorizontalScrollView is a scroll view that will scroll horizontally
    when the user is scrolling vertically.
*/
@implementation NUHorizontalScrollView : CPScrollView

- (void)_respondToScrollWheelEventWithDeltaX:(float)deltaX deltaY:(float)deltaY
{
    [super _respondToScrollWheelEventWithDeltaX:deltaY deltaY:deltaY];
}

@end
