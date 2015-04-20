/*
*   Filename:         NUInfinityTransformer.j
*   Created:          Thu May  2 18:36:54 PDT 2013
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

@implementation NUInfinityTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)aValue
{
    return aValue == @"INFINITY" ? nil : aValue;
}

- (id)reverseTransformedValue:(id)aValue
{
    return !aValue ? @"INFINITY" : aValue;
}

@end


// registration
NUInfinityTransformerName = @"NUInfinityTransformerName";
[CPValueTransformer setValueTransformer:[NUInfinityTransformer new] forName:NUInfinityTransformerName];
