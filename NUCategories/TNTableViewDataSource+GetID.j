/*
*   Filename:         TNTableViewDataSource+GetID.j
*   Created:          Wed Apr 22 12:10:10 PDT 2015
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

@import <TNKit/TNTableViewDataSource.j>
@import <NUKit/NUOutlineViewDataSource.j>


@implementation TNTableViewDataSource (GetID)

- (id)objectWithID:(id)anID
{
    for (var i = [_filteredContent count] - 1; i >= 0; i--)
    {
        var object = _filteredContent[i];

        if ([object respondsToSelector:@"ID"] && [object ID] == anID)
            return object;
    }

    return nil;
}

@end


@implementation NUOutlineViewDataSource (GetID)

- (id)objectWithID:(id)anID
{
    var ret = [self _getChildrenOfObject:nil usingPredicate:[CPPredicate predicateWithFormat:@"ID == %@", anID]];
    return [ret count] == 1 ? ret[0] : nil;
}

@end
