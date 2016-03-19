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


/*! Usage indicator is progress indicator
    with color changing accordint to its value.

    - between 0% and 10%: normal color
    - between 80% and 89% : orange
    - 90% and above: red;
*/
@implementation NUUsageIndicator : CPProgressIndicator

- (void)setDoubleValue:(double)aValue
{
    [super setDoubleValue:aValue];

    var percentage = parseFloat(aValue) / parseFloat([self maxValue]);

    if (percentage < 0.8)
        [self setValue:NUSkinColorBlue forThemeAttribute:@"bar-color"];
    else if (percentage >= 0.8 && percentage < 0.9)
        [self setValue:NUSkinColorOrange forThemeAttribute:@"bar-color"];
    else
        [self setValue:NUSkinColorRed forThemeAttribute:@"bar-color"];
}

@end
