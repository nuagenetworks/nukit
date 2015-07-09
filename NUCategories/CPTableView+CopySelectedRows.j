/*
*   Filename:         CPTableView+CopySelectedRows.j
*   Created:          Wed Apr 22 12:08:54 PDT 2015
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

@import <AppKit/CPTableView.j>
@import <AppKit/CPOutlineView.j>


@implementation CPTableView (copySelectedRows)

- (CPColor)_unfocusedSelectionColorFromColor:(CPColor)aColor saturation:(float)saturation
{
    return [aColor colorWithAlphaComponent:0.65];
}


- (CPView)_unarchiveViewWithIdentifier:(CPString)anIdentifier owner:(id)anOwner
{
    _unavailable_custom_cibs[anIdentifier] = YES;
    return nil;
}

@end


@implementation CPTableView (selectionRightClick)

- (CPMenu)menuForEvent:(CPEvent)theEvent
{
    if (!([self _delegateRespondsToMenuForTableColumnRow]))
        return [super menuForEvent:theEvent];

    var location = [self convertPoint:[theEvent locationInWindow] fromView:nil],
        row = [self rowAtPoint:location],
        column = [self columnAtPoint:location],
        tableColumn = [[self tableColumns] objectAtIndex:column];

    if ([self _sendDelegateSelectionShouldChangeInTableView])
    {
        if (row >= 0)
        {
            if ([[self selectedRowIndexes] containsIndex:row])
            {
                [self sendAction:_action to:_target];
                return [self _sendDelegateMenuForTableColumn:tableColumn row:row];
            }

            var indexSet = [self _sendDelegateSelectionIndexesForProposedSelection:[CPIndexSet indexSetWithIndex:row]];

            if (_allowsEmptySelection || [indexSet count])
            {
                [self _noteSelectionIsChanging];
                [self selectRowIndexes:indexSet byExtendingSelection:NO];
            }
        }
        else
        {
            [self deselectAll:self];
        }

        [self sendAction:_action to:_target];

        return [self _sendDelegateMenuForTableColumn:tableColumn row:row];
    }

    [self sendAction:_action to:_target];

    return nil;
}

@end
