/*
*   Filename:         NUNullToNotApplicableStringTransformer.j
*   Created:          Fri May 15 17:25:03 PDT 2015
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

@implementation NUNullToNotApplicableStringTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return value === nil || value == @"" ? @"Not applicable" : value;
}

@end


// registration
NUNullToNotApplicableStringTransformerName = @"NUNullToNotApplicableStringTransformerName";
[CPValueTransformer setValueTransformer:[NUNullToNotApplicableStringTransformer new] forName:NUNullToNotApplicableStringTransformerName];
