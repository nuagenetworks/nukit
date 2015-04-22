/*
*   Filename:         CPComboBox+CaseInsensiteComplete.j
*   Created:          Tue Nov  4 20:23:08 PST 2014
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
@import <AppKit/CPComboBox.j>


var NUComboBoxCompletionTest = function(object, index, context)
{
    return object.toString().toLowerCase().indexOf(context.toLowerCase()) === 0;
};

@implementation CPComboBox (CaseInsensitiveComplete)

- (CPString)completedString:(CPString)substring
{
    if (_usesDataSource)
        return [self comboBoxCompletedString:substring];
    else
    {
        var index = [_items indexOfObjectPassingTest:NUComboBoxCompletionTest context:substring];

        return index !== CPNotFound ? _items[index] : nil;
    }
}

@end
