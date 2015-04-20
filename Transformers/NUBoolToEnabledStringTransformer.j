/*
*   Filename:         NUBoolToEnabledStringTransformer.j
*   Created:          Thu Mar 27 14:22:22 PDT 2014
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

@implementation NUBoolToEnabledStringTransformer: CPValueTransformer

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
    return value ? @"Enabled" : @"Disabled";
}

@end


// registration
NUBoolToEnabledStringTransformerName = @"NUBoolToEnabledStringTransformerName";
[CPValueTransformer setValueTransformer:[NUBoolToEnabledStringTransformer new] forName:NUBoolToEnabledStringTransformerName];