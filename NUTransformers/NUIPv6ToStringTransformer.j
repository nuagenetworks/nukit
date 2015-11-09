/*
*   Filename:         NUIPv6ToStringTransformer.j
*   Created:          Thu Nov  6 10:43:29 PDT 2015
*   Author:           Christophe Serafin <christophe.serafin@alcatel-lucent.com>
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

@implementation NUIPv6ToStringTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)aValue
{
    switch (aValue)
    {
        case nil:
        case @"":
            return @"Not specified";

        default:
            return aValue;
    }
}

@end


// registration
NUIPv6ToStringTransformerName = @"NUIPv6ToStringTransformerName";
[CPValueTransformer setValueTransformer:[NUIPv6ToStringTransformer new] forName:NUIPv6ToStringTransformerName];
