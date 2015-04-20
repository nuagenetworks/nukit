/*
*   Filename:         NUNullToBoolTransformer.j
*   Created:          Mon Oct 20 17:50:40 PDT 2014
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

@implementation NUNullToBoolTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return BOOL;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (value && value.length == 0)
        return NO;

    return !!value;
}

@end


// registration
NUNullToBoolTransformerName = @"NUNullToBoolTransformerName";
[CPValueTransformer setValueTransformer:[NUNullToBoolTransformer new] forName:NUNullToBoolTransformerName];


@import <Foundation/Foundation.j>

@implementation NUNullToNegateBoolTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return BOOL;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (!value || value.length == 0)
        return YES;

    return !!!value;
}

@end


// registration
NUNullToNegateBoolTransformerName = @"NUNullToNegateBoolTransformerName";
[CPValueTransformer setValueTransformer:[NUNullToNegateBoolTransformer new] forName:NUNullToNegateBoolTransformer];
