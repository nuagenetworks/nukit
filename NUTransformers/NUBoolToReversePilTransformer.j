/*
*   Filename:         NUBoolToReversePilTransformer.j
*   Created:          Wed Mar 19 10:41:25 PDT 2014
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
@import <AppKit/CPImage.j>

@global NUImageInKit

var NUBoolToPilTransformerPilGreen,
    NUBoolToPilTransformerPilRed;


@implementation NUBoolToReversePilTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPImage;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (!NUBoolToPilTransformerPilGreen)
    {
        NUBoolToPilTransformerPilGreen  = NUImageInKit(@"pil-green.png", CGSizeMake(16.0, 16.0));
        NUBoolToPilTransformerPilRed    = NUImageInKit(@"pil-square-red.png", CGSizeMake(16.0, 16.0));
    }

    return value ? NUBoolToPilTransformerPilRed : NUBoolToPilTransformerPilGreen;
}

@end


// registration
NUBoolToReversePilTransformerName = @"NUBoolToReversePilTransformerName";
[CPValueTransformer setValueTransformer:[NUBoolToReversePilTransformer new] forName:NUBoolToReversePilTransformerName];
