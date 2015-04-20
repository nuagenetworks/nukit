/*
*   Filename:         NUCompoundTransformer.j
*   Created:          Fri Mar 28 17:58:55 PDT 2014
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

@implementation NUCompoundTransformer: CPValueTransformer
{
    CPArray _transformers   @accessors(property=transformers);
}

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)init
{
    if (self = [super init])
        _transformers = [];

    return self;
}

- (id)transformedValue:(id)value
{
    for (var i = 0, c = [_transformers count]; i < c; i ++)
    {
        var transformerName = _transformers[i],
            transformer = [CPValueTransformer valueTransformerForName:transformerName];

        if (!transformer)
            [CPException raise:CPInvalidArgumentException reason:@"NUCompoundTransformer: One given cannot be found in the registry"];

        value = [transformer transformedValue:value];
    }

    return value;
}

@end


// registration
NUCompoundTransformerName = @"NUCompoundTransformerName";
[CPValueTransformer setValueTransformer:[NUCompoundTransformer new] forName:NUCompoundTransformerName];
