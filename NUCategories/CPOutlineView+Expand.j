/*
*   Filename:         CPOutlineView+Expand.j
*   Created:          Wed Apr 22 12:08:29 PDT 2015
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

@import <AppKit/CPOutlineView.j>


@implementation CPOutlineView (ExpandAll)

- (void)expandAll
{
    for (var count = 0; [self itemAtRow:count]; count++)
    {
        var item = [self itemAtRow:count];
        if ([self isExpandable:item])
            [self expandItem:item];
    }
}

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

- (CGRect)_frameOfOutlineDataViewAtRow:(CPInteger)aRow
 {
     var columnIndex = [[self tableColumns] indexOfObject:_outlineTableColumn],
         frame = [super frameOfDataViewAtColumn:columnIndex row:aRow],
         indentationWidth = [self levelForRow:aRow] * [self indentationPerLevel];

     frame.origin.x += indentationWidth;
     frame.size.width -= indentationWidth;

     return frame;
 }
@end
