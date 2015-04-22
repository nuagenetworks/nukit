/*
*   Filename:         NUNumericTextField.j
*   Created:          Fri Jun 20 16:51:28 PDT 2014
*   Author:           Alexandre Wilhelm <alexandre.wilhelm@alcatel-lucent.com>
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
@import <AppKit/CPTextField.j>

@global isNumber


@implementation NUNumericTextField : CPTextField

- (BOOL)_setStringValue:(CPString)aValue isNewValue:(BOOL)isNewValue errorDescription:(CPStringRef)anError
{
    if (!(isNumber(aValue)) || [aValue rangeOfString:@"."].length > 0 || (aValue.length > 1 && [self stringValue] == @"0"))
    {
        var value = [aValue length] ? [self objectValue] : @"";

        if (!value)
            value = @"";

        [self _inputElement].value = value.toString();

        return [super _setStringValue:value.toString() isNewValue:isNewValue errorDescription:anError];
    }

    return [super _setStringValue:[aValue intValue].toString() isNewValue:isNewValue errorDescription:anError];
}

@end
