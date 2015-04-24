/*
*   Filename:         CPButton+Colors.j
*   Created:          Thu Oct 16 16:40:04 PDT 2014
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

@import <AppKit/CPButton.j>
@import "NUSkin.j"


@implementation CPButton (color)

- (void)setRed
{
    [self setValue:[CPColor colorWithHexString:@"E1414F"] forThemeAttribute:@"bezel-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithHexString:@"911E22"] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateNormal];

    [self setValue:[CPColor colorWithHexString:@"BC2F3E"] forThemeAttribute:@"bezel-color" inState:CPThemeStateHighlighted];
    [self setValue:[CPColor colorWithHexString:@"911E22"] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateHighlighted];
    [self setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateHighlighted];

    [self setValue:NUSkinColorGreyLight forThemeAttribute:@"bezel-color" inState:CPThemeStateDisabled];
    [self setValue:[CPColor colorWithCalibratedWhite:240.0 / 255.0 alpha:0.6] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateDisabled];
    [self setValue:[CPColor colorWithCalibratedWhite:79.0 / 255.0 alpha:0.6] forThemeAttribute:@"text-color" inState:CPThemeStateDisabled];


    [self setNeedsLayout];
}

- (void)setBGColor:(CPString)aColor
{
    switch (aColor)
    {
        case @"red":
            [self setRed];
            break;
    }
}

@end
