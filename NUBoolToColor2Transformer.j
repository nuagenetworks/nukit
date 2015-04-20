/*
*   Filename:         NUBoolToColor2Transformer.j
*   Created:          Wed Apr 23 16:48:16 PDT 2014
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
@import "NUSkin.j"

@implementation NUBoolToColor2Transformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPColor;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return value ? NUSkinColorGreen : NUSkinColorGreyDark;
}

@end


// registration
NUBoolToColor2TransformerName = @"NUBoolToColor2TransformerName";
[CPValueTransformer setValueTransformer:[NUBoolToColor2Transformer new] forName:NUBoolToColor2TransformerName];
