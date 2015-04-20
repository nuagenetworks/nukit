/*
*   Filename:         NUMillisecondsToDateTransformer.j
*   Created:          Fri Mar 28 10:11:52 PDT 2014
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

@implementation NUMillisecondsToDateTransformer: CPValueTransformer

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
    if (!aValue || aValue == @"" || ([aValue isKindOfClass:CPString] && [aValue lowercaseString] == "no information"))
        return @"No information"

    var date = [CPDate dateWithTimeIntervalSince1970:(parseInt(aValue) / 1000)];

    return date.format("mmm dd yyyy HH:MM:ss");
}

@end


// registration
NUMillisecondsToDateTransformerName = @"NUMillisecondsToDateTransformerName";
[CPValueTransformer setValueTransformer:[NUMillisecondsToDateTransformer new] forName:NUMillisecondsToDateTransformerName];
