/*
*   Filename:         NUSpeedToStringTransformer.j
*   Created:          Tue Sep 16 10:09:10 PDT 2014
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

@implementation NUSpeedToStringTransformer: CPValueTransformer

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
    return !value || !value.length ? @"Auto" : value + @" Mbps";
}

@end


// registration
NUSpeedToStringTransformerName = @"NUSpeedToStringTransformerName";
[CPValueTransformer setValueTransformer:[NUSpeedToStringTransformer new] forName:NUSpeedToStringTransformerName];
