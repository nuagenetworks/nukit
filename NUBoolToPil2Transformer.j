/*
*   Filename:         NUBoolToPil2Transformer.j
*   Created:          Wed Apr 23 16:49:02 PDT 2014
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

var NUBoolToPilTransformerPilGreen,
    NUBoolToPilTransformerPilGrey;


@implementation NUBoolToPil2Transformer: CPValueTransformer

+ (void)initialize
{
    NUBoolToPilTransformerPilGreen = CPImageInBundle(@"pil-green.png", CGSizeMake(16.0, 16.0));
    NUBoolToPilTransformerPilGrey = CPImageInBundle(@"pil-square-grey.png", CGSizeMake(16.0, 16.0));
}

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
    return value ? NUBoolToPilTransformerPilGreen : NUBoolToPilTransformerPilGrey;
}

@end


// registration
NUBoolToPil2TransformerName = @"NUBoolToPil2TransformerName";
[CPValueTransformer setValueTransformer:[NUBoolToPil2Transformer new] forName:NUBoolToPil2TransformerName];
