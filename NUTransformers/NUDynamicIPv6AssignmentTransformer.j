/*
*   Filename:         NUDynamicIPv6AssignmentTransformer.j
*   Created:          Thu Jul 5, 2018
*   Author:           Natalia Balus <natalia.balus@nokia.com>
*   Description:      VSA
*   Project:          VSD - Nuage - Data Center Service Delivery - IPD
*
* Copyright (c) 2018-2019 Nokia. All Rights Reserved.
*
* This source code contains confidential information which is proprietary to Nokia.
* No part of its contents may be used, copied, disclosed or conveyed to any party
* in any manner whatsoever without prior written permission from Nokia
*/


@import <Foundation/Foundation.j>

@implementation NUDynamicIPv6AssignmentTransformer: CPValueTransformer

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
    return value ? @"Auto IPv6 assignment" : @"";
}

- (id)reverseTransformedValue:(id)aValue
{
    return NO;
}

@end


// registration
NUDynamicIPv6AssignmentTransformerName = @"NUDynamicIPv6AssignmentTransformerName";
[CPValueTransformer setValueTransformer:[NUDynamicIPv6AssignmentTransformer new] forName:NUDynamicIPv6AssignmentTransformerName];
