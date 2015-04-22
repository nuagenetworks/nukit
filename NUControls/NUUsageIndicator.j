/*
*   Filename:         NUUsageIndicator.j
*   Created:          Fri Mar 28 10:29:43 PDT 2014
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
@import <AppKit/CPProgressIndicator.j>
@import "NUSkin.j"


@implementation NUUsageIndicator : CPProgressIndicator

- (void)setDoubleValue:(double)aValue
{
    if (aValue < 80)
        [self setValue:NUSkinColorBlue forThemeAttribute:@"bar-color"];
    else if (aValue >= 80 && aValue < 90)
        [self setValue:NUSkinColorOrange forThemeAttribute:@"bar-color"];
    else
        [self setValue:NUSkinColorRed forThemeAttribute:@"bar-color"];

    [super setDoubleValue:aValue];
}


@end
