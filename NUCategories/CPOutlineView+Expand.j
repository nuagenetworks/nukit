/*
****************************************************************************
*
*   Filename:         CPOutlineView+Expand.j
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

@import <AppKit/CPOutlineView.j>

@implementation CPOutlineView (ExpandAll)

/*! Expand all items in the view
*/
- (void)expandAll
{
    for (var count = 0; [self itemAtRow:count]; count++)
    {
        var item = [self itemAtRow:count];
        if ([self isExpandable:item])
            [self expandItem:item];
    }
}

/*! Collapse all items in the view
*/
- (void)collapseAll
{
    for (var count = 0; [self itemAtRow:count]; count++)
    {
        var item = [self itemAtRow:count];
        if ([self isExpandable:item])
            [self collapseItem:item];
    }
}

- (CPArray)itemsAtRows:(CPIndexSet)indexes
{
    var items = [CPArray array],
        i = [indexes firstIndex];

  while (i != CPNotFound)
  {
    [items addObject:[self itemAtRow:i]];
    i = [indexes indexGreaterThanIndex:i];
  }

  return items;
}

@end
