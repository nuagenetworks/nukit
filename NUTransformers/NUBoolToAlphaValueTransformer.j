/*
*   Filename:         NUBoolToAlphaValueTransformer.j
*   Created:          Tue Sep 10 19:22:48 PDT 2013
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

@implementation NUBoolToAlphaValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPNumber;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)aValue
{
    return aValue ? 1.0 : 0.5;
}

@end


// registration
NUBoolToAlphaValueTransformerName = @"NUBoolToAlphaValueTransformerName";
[CPValueTransformer setValueTransformer:[NUBoolToAlphaValueTransformer new] forName:NUBoolToAlphaValueTransformerName];
